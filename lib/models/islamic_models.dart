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
    return QuranVerseItem(
      surahNumber: (json['surahNumber'] as num?)?.toInt() ?? 1,
      surahName: (json['surahName'] as String?)?.trim() ?? '',
      ayahNumber: (json['ayahNumber'] as num?)?.toInt() ?? 1,
      text: (json['text'] as String?) ?? '',
    );
  }
}

class QuranPageData {
  final int page;
  final int juz;
  final List<QuranVerseItem> verses;

  const QuranPageData({
    required this.page,
    required this.juz,
    required this.verses,
  });

  factory QuranPageData.fromJson(Map<String, dynamic> json) {
    final List<QuranVerseItem> parsedVerses = <QuranVerseItem>[];
    final rawVerses = json['verses'];
    if (rawVerses is List) {
      for (final item in rawVerses) {
        if (item is Map<String, dynamic>) {
          parsedVerses.add(QuranVerseItem.fromJson(item));
        }
      }
    }
    return QuranPageData(
      page: (json['page'] as num?)?.toInt() ?? 1,
      juz: (json['juz'] as num?)?.toInt() ?? 1,
      verses: parsedVerses,
    );
  }
}

class DhikrItem {
  final String id;
  final String text;
  final int repeatCount;
  final String? reference;

  const DhikrItem({
    required this.id,
    required this.text,
    required this.repeatCount,
    this.reference,
  });

  factory DhikrItem.fromJson(Map<String, dynamic> json) {
    return DhikrItem(
      id: (json['id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      repeatCount: (json['repeatCount'] as num?)?.toInt() ?? 1,
      reference: json['reference'] as String?,
    );
  }
}

class AzkarChapter {
  final String id;
  final String title;
  final List<DhikrItem> items;

  const AzkarChapter({
    required this.id,
    required this.title,
    required this.items,
  });

  factory AzkarChapter.fromJson(Map<String, dynamic> json) {
    final List<DhikrItem> parsedItems = <DhikrItem>[];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(DhikrItem.fromJson(item));
        }
      }
    }
    return AzkarChapter(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      items: parsedItems,
    );
  }
}

class LocalIslamicRepository {
  LocalIslamicRepository._();
  static final LocalIslamicRepository instance = LocalIslamicRepository._();

  Map<int, QuranPageData>? _quranPagesCache;
  List<AzkarChapter>? _azkarChaptersCache;

  Future> loadQuranPages() async {
    final cached = _quranPagesCache;
    if (cached != null) return cached;

    try {
      final rawString =
          await rootBundle.loadString('assets/data/quran_pages.json');
      final decoded = jsonDecode(rawString);
      final Map<int, QuranPageData> pagesMap = <int, QuranPageData>{};

      if (decoded is List) {
        for (final entry in decoded) {
          if (entry is Map<String, dynamic>) {
            final pageData = QuranPageData.fromJson(entry);
            pagesMap[pageData.page] = pageData;
          }
        }
      }

      _quranPagesCache = pagesMap;
      return pagesMap;
    } catch (_) {
      return const <int, QuranPageData>{};
    }
  }

  Future<List<AzkarChapter>> loadAzkarChapters() async {
    final cached = _azkarChaptersCache;
    if (cached != null) return cached;

    try {
      final rawString =
          await rootBundle.loadString('assets/data/hisn_al_muslim.json');
      final decoded = jsonDecode(rawString);
      final List<AzkarChapter> chapters = <AzkarChapter>[];

      if (decoded is List) {
        for (final entry in decoded) {
          if (entry is Map<String, dynamic>) {
            chapters.add(AzkarChapter.fromJson(entry));
          }
        }
      }

      _azkarChaptersCache = chapters;
      return chapters;
    } catch (_) {
      return const <AzkarChapter>[];
    }
  }
}
