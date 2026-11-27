import 'dart:convert';
import 'package:flutter/services.dart';

class QuranVerseItem {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String text;

  const QuranVerseItem({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.text,
  });

  factory QuranVerseItem.fromJson(Map<String, dynamic> json) {
    final surahNum = _parseInt(
      json['sura'] ?? json['surah'] ?? json['surah_number'] ?? json['sura_id'],
      fallback: 1,
    );
    final ayahNum = _parseInt(
      json['aya'] ?? json['ayah'] ?? json['verse'] ?? json['ayah_number'] ?? json['id'],
      fallback: 1,
    );
    final rawName = (json['surah_name'] ?? json['sura_name'] ?? json['name'] ?? '')
        .toString()
        .trim();
    final verseText = (json['uthmani'] ??
            json['text'] ??
            json['aya_text'] ??
            json['verse_text'] ??
            json['content'] ??
            '')
        .toString()
        .trim();

    return QuranVerseItem(
      surahNumber: surahNum,
      surahName: rawName,
      ayahNumber: ayahNum,
      text: verseText,
    );
  }
}

class QuranPageData {
  final int pageNumber;
  final int juz;
  final List<QuranVerseItem> verses;

  const QuranPageData({
    required this.pageNumber,
    required this.juz,
    required this.verses,
  });
}

class HisnItem {
  final int id;
  final String text;
  final int count;
  final String? audio;
  final String? filename;

  const HisnItem({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.filename,
  });

  factory HisnItem.fromJson(Map<String, dynamic> json, {int fallbackId = 1}) {
    return HisnItem(
      id: _parseInt(json['id'], fallback: fallbackId),
      text: (json['text'] ?? json['dhikr'] ?? json['content'] ?? '')
          .toString()
          .trim(),
      count: _parseInt(json['count'] ?? json['repeat'], fallback: 1),
      audio: json['audio']?.toString(),
      filename: json['filename']?.toString(),
    );
  }
}

class HisnCategory {
  final int id;
  final String category;
  final List<HisnItem> items;

  const HisnCategory({
    required this.id,
    required this.category,
    required this.items,
  });

  factory HisnCategory.fromJson(Map<String, dynamic> json, {int fallbackId = 1}) {
    final rawArray = json['array'] ?? json['items'] ?? json['zikr'] ?? const [];
    final List<HisnItem> parsedItems = <HisnItem>[];

    if (rawArray is List) {
      for (int i = 0; i < rawArray.length; i++) {
        final entry = rawArray[i];
        if (entry is Map<String, dynamic>) {
          parsedItems.add(HisnItem.fromJson(entry, fallbackId: i + 1));
        } else if (entry != null) {
          parsedItems.add(
            HisnItem(
              id: i + 1,
              text: entry.toString().trim(),
              count: 1,
            ),
          );
        }
      }
    }

    return HisnCategory(
      id: _parseInt(json['id'], fallback: fallbackId),
      category: (json['category'] ?? json['title'] ?? 'الأذكار')
          .toString()
          .trim(),
      items: parsedItems,
    );
  }
}

class LocalIslamicRepository {
  LocalIslamicRepository._();

  static final LocalIslamicRepository instance = LocalIslamicRepository._();

  Map<int, QuranPageData>? _cachedQuranPages;
  List<HisnCategory>? _cachedHisnCategories;

  Future> loadQuranPages() async {
    if (_cachedQuranPages != null) {
      return _cachedQuranPages!;
    }

    try {
      final rawJson =
          await rootBundle.loadString('assets/data/quran_pages.json');
      final decoded = jsonDecode(rawJson);
      final Map<int, List<QuranVerseItem>> groupedByPage =
          <int, List<QuranVerseItem>>{};

      if (decoded is List) {
        for (int i = 0; i < decoded.length; i++) {
          final item = decoded[i];
          if (item is Map<String, dynamic>) {
            final pageNum = _parseInt(
              item['page'] ?? item['page_number'],
              fallback: 1,
            ).clamp(1, 604);
            final verse = QuranVerseItem.fromJson(item);
            if (verse.text.isNotEmpty) {
              groupedByPage
                  .putIfAbsent(pageNum, () => <QuranVerseItem>[])
                  .add(verse);
            }
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        final pagesNode = decoded['pages'];
        if (pagesNode is Map) {
          pagesNode.forEach((key, value) {
            final pageNum = _parseInt(key, fallback: 1).clamp(1, 604);
            if (value is List) {
              for (final entry in value) {
                if (entry is Map<String, dynamic>) {
                  final verse = QuranVerseItem.fromJson(entry);
                  if (verse.text.isNotEmpty) {
                    groupedByPage
                        .putIfAbsent(pageNum, () => <QuranVerseItem>[])
                        .add(verse);
                  }
                }
              }
            }
          });
        }
      }

      final Map<int, QuranPageData> result = <int, QuranPageData>{};
      groupedByPage.forEach((pageNum, verses) {
        final juzNum = (((pageNum - 1) ~/ 20) + 1).clamp(1, 30);
        result[pageNum] = QuranPageData(
          pageNumber: pageNum,
          juz: juzNum,
          verses: verses,
        );
      });

      _cachedQuranPages = result;
      return result;
    } catch (_) {
      return const <int, QuranPageData>{};
    }
  }

  Future<List<HisnCategory>> loadHisnAlMuslim() async {
    if (_cachedHisnCategories != null) {
      return _cachedHisnCategories!;
    }

    try {
      final rawJson =
          await rootBundle.loadString('assets/data/hisn_al_muslim.json');
      final decoded = jsonDecode(rawJson);
      final List<HisnCategory> categories = <HisnCategory>[];

      if (decoded is List) {
        for (int i = 0; i < decoded.length; i++) {
          final entry = decoded[i];
          if (entry is Map<String, dynamic>) {
            final cat = HisnCategory.fromJson(entry, fallbackId: i + 1);
            if (cat.items.isNotEmpty) {
              categories.add(cat);
            }
          }
        }
      } else if (decoded is Map<String, dynamic>) {
        final listNode = decoded['categories'] ?? decoded['data'] ?? decoded['hisn'];
        if (listNode is List) {
          for (int i = 0; i < listNode.length; i++) {
            final entry = listNode[i];
            if (entry is Map<String, dynamic>) {
              final cat = HisnCategory.fromJson(entry, fallbackId: i + 1);
              if (cat.items.isNotEmpty) {
                categories.add(cat);
              }
            }
          }
        }
      }

      _cachedHisnCategories = categories;
      return categories;
    } catch (_) {
      return const <HisnCategory>[];
    }
  }
}

int _parseInt(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}
