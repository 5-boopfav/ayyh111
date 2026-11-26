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
    final rawVerses = (json['verses'] as List<dynamic>?) ?? const [];
    return QuranPageData(
      page: (json['page'] as num?)?.toInt() ?? 1,
      juz: (json['juz'] as num?)?.toInt() ?? 1,
      verses: rawVerses
          .whereType>()
          .map(QuranVerseItem.fromJson)
          .toList(),
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
    final rawItems = (json['items'] as List<dynamic>?) ?? const [];
    return AzkarChapter(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      items: rawItems
          .whereType>()
          .map(DhikrItem.fromJson)
          .toList(),
    );
  }
}

class LocalIslamicRepository {
  LocalIslamicRepository._();
  static final LocalIslamicRepository instance = LocalIslamicRepository._();

  Map<int, QuranPageData>? _quranPagesCache;
  List<AzkarChapter>? _azkarChaptersCache;

  Future> loadQuranPages() async {
    if (_quranPagesCache != null) return _quranPagesCache!;

    try {
      final rawString =
          await rootBundle.loadString('assets/data/quran_pages.json');
      final decoded = jsonDecode(rawString);
      final Map<int, QuranPageData> pagesMap = {};

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
    if (_azkarChaptersCache != null) return _azkarChaptersCache!;

    try {
      final rawString =
          await rootBundle.loadString('assets/data/hisn_al_muslim.json');
      final decoded = jsonDecode(rawString);
      final List<AzkarChapter> chapters = [];

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
