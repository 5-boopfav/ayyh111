import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_flip/page_flip.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BahmadApp());
}

class BahmadApp extends StatelessWidget {
  const BahmadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مصحف وأذان بحمد',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF235347),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MainThreeTabShell(),
      ),
    );
  }
}

class CityPreset {
  final String name;
  final double latitude;
  final double longitude;
  final String methodKey;

  const CityPreset({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.methodKey,
  });
}

const List<CityPreset> kCities = [
  CityPreset(
    name: 'الرياض',
    latitude: 24.7136,
    longitude: 46.6753,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'مكة المكرمة',
    latitude: 21.3891,
    longitude: 39.8579,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'المدينة المنورة',
    latitude: 24.5247,
    longitude: 39.5692,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'جدة',
    latitude: 21.4858,
    longitude: 39.1925,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'القاهرة',
    latitude: 30.0444,
    longitude: 31.2357,
    methodKey: 'egyptian',
  ),
  CityPreset(
    name: 'دبي',
    latitude: 25.2048,
    longitude: 55.2708,
    methodKey: 'dubai',
  ),
  CityPreset(
    name: 'عمان',
    latitude: 31.9539,
    longitude: 35.9106,
    methodKey: 'muslim_world_league',
  ),
];

CalculationParameters _calculationMethodFromKey(String key) {
  switch (key) {
    case 'egyptian':
      return CalculationMethod.egyptian.getParameters();
    case 'dubai':
      return CalculationMethod.dubai.getParameters();
    case 'muslim_world_league':
      return CalculationMethod.muslim_world_league.getParameters();
    case 'karachi':
      return CalculationMethod.karachi.getParameters();
    case 'north_america':
      return CalculationMethod.north_america.getParameters();
    case 'umm_al_qura':
    default:
      return CalculationMethod.umm_al_qura.getParameters();
  }
}

String _methodLabel(String key) {
  switch (key) {
    case 'egyptian':
      return 'الهيئة المصرية العامة للمساحة';
    case 'dubai':
      return 'دبي';
    case 'muslim_world_league':
      return 'رابطة العالم الإسلامي';
    case 'karachi':
      return 'جامعة العلوم الإسلامية بكراتشي';
    case 'north_america':
      return 'أمريكا الشمالية (ISNA)';
    case 'umm_al_qura':
    default:
      return 'أم القرى';
  }
}

class SurahInfo {
  final int number;
  final String name;
  final int startPage;
  final String revelationType;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.startPage,
    required this.revelationType,
  });
}

class JuzInfo {
  final int number;
  final String title;
  final int startPage;

  const JuzInfo({
    required this.number,
    required this.title,
    required this.startPage,
  });
}

class PageThemePreset {
  final String id;
  final String name;
  final double hue;
  final double shade;

  const PageThemePreset({
    required this.id,
    required this.name,
    required this.hue,
    required this.shade,
  });
}

const List<PageThemePreset> kPageThemePresets = [
  PageThemePreset(
      id: 'classic_cream', name: 'ورقي كلاسيكي', hue: 38.0, shade: 0.14),
  PageThemePreset(
      id: 'warm_ivory', name: 'عاجي دافئ', hue: 30.0, shade: 0.24),
  PageThemePreset(
      id: 'sage_calm', name: 'زيتوني هادئ', hue: 92.0, shade: 0.22),
  PageThemePreset(
      id: 'sky_mist', name: 'سماوي لطيف', hue: 202.0, shade: 0.20),
  PageThemePreset(
      id: 'sand_stone', name: 'رملي مريح', hue: 46.0, shade: 0.36),
];

const List<SurahInfo> kSurahs = [
  SurahInfo(number: 1, name: 'الفاتحة', startPage: 1, revelationType: 'مكية'),
  SurahInfo(number: 2, name: 'البقرة', startPage: 2, revelationType: 'مدنية'),
  SurahInfo(number: 3, name: 'آل عمران', startPage: 50, revelationType: 'مدنية'),
  SurahInfo(number: 4, name: 'النساء', startPage: 77, revelationType: 'مدنية'),
  SurahInfo(number: 5, name: 'المائدة', startPage: 106, revelationType: 'مدنية'),
  SurahInfo(number: 6, name: 'الأنعام', startPage: 128, revelationType: 'مكية'),
  SurahInfo(number: 7, name: 'الأعراف', startPage: 151, revelationType: 'مكية'),
  SurahInfo(number: 8, name: 'الأنفال', startPage: 177, revelationType: 'مدنية'),
  SurahInfo(number: 9, name: 'التوبة', startPage: 187, revelationType: 'مدنية'),
  SurahInfo(number: 10, name: 'يونس', startPage: 208, revelationType: 'مكية'),
  SurahInfo(number: 11, name: 'هود', startPage: 221, revelationType: 'مكية'),
  SurahInfo(number: 12, name: 'يوسف', startPage: 235, revelationType: 'مكية'),
  SurahInfo(number: 13, name: 'الرعد', startPage: 249, revelationType: 'مدنية'),
  SurahInfo(number: 14, name: 'إبراهيم', startPage: 255, revelationType: 'مكية'),
  SurahInfo(number: 15, name: 'الحجر', startPage: 262, revelationType: 'مكية'),
  SurahInfo(number: 16, name: 'النحل', startPage: 267, revelationType: 'مكية'),
  SurahInfo(number: 17, name: 'الإسراء', startPage: 282, revelationType: 'مكية'),
  SurahInfo(number: 18, name: 'الكهف', startPage: 293, revelationType: 'مكية'),
  SurahInfo(number: 19, name: 'مريم', startPage: 305, revelationType: 'مكية'),
  SurahInfo(number: 20, name: 'طه', startPage: 312, revelationType: 'مكية'),
  SurahInfo(number: 21, name: 'الأنبياء', startPage: 322, revelationType: 'مكية'),
  SurahInfo(number: 22, name: 'الحج', startPage: 332, revelationType: 'مدنية'),
  SurahInfo(number: 23, name: 'المؤمنون', startPage: 342, revelationType: 'مكية'),
  SurahInfo(number: 24, name: 'النور', startPage: 350, revelationType: 'مدنية'),
  SurahInfo(number: 25, name: 'الفرقان', startPage: 359, revelationType: 'مكية'),
  SurahInfo(number: 26, name: 'الشعراء', startPage: 367, revelationType: 'مكية'),
  SurahInfo(number: 27, name: 'النمل', startPage: 377, revelationType: 'مكية'),
  SurahInfo(number: 28, name: 'القصص', startPage: 385, revelationType: 'مكية'),
  SurahInfo(number: 29, name: 'العنكبوت', startPage: 396, revelationType: 'مكية'),
  SurahInfo(number: 30, name: 'الروم', startPage: 404, revelationType: 'مكية'),
  SurahInfo(number: 31, name: 'لقمان', startPage: 411, revelationType: 'مكية'),
  SurahInfo(number: 32, name: 'السجدة', startPage: 415, revelationType: 'مكية'),
  SurahInfo(number: 33, name: 'الأحزاب', startPage: 418, revelationType: 'مدنية'),
  SurahInfo(number: 34, name: 'سبأ', startPage: 428, revelationType: 'مكية'),
  SurahInfo(number: 35, name: 'فاطر', startPage: 434, revelationType: 'مكية'),
  SurahInfo(number: 36, name: 'يس', startPage: 440, revelationType: 'مكية'),
  SurahInfo(number: 37, name: 'الصافات', startPage: 446, revelationType: 'مكية'),
  SurahInfo(number: 38, name: 'ص', startPage: 453, revelationType: 'مكية'),
  SurahInfo(number: 39, name: 'الزمر', startPage: 458, revelationType: 'مكية'),
  SurahInfo(number: 40, name: 'غافر', startPage: 467, revelationType: 'مكية'),
  SurahInfo(number: 41, name: 'فصلت', startPage: 477, revelationType: 'مكية'),
  SurahInfo(number: 42, name: 'الشورى', startPage: 483, revelationType: 'مكية'),
  SurahInfo(number: 43, name: 'الزخرف', startPage: 489, revelationType: 'مكية'),
  SurahInfo(number: 44, name: 'الدخان', startPage: 496, revelationType: 'مكية'),
  SurahInfo(number: 45, name: 'الجاثية', startPage: 499, revelationType: 'مكية'),
  SurahInfo(number: 46, name: 'الأحقاف', startPage: 502, revelationType: 'مكية'),
  SurahInfo(number: 47, name: 'محمد', startPage: 507, revelationType: 'مدنية'),
  SurahInfo(number: 48, name: 'الفتح', startPage: 511, revelationType: 'مدنية'),
  SurahInfo(number: 49, name: 'الحجرات', startPage: 515, revelationType: 'مدنية'),
  SurahInfo(number: 50, name: 'ق', startPage: 518, revelationType: 'مكية'),
  SurahInfo(number: 51, name: 'الذاريات', startPage: 520, revelationType: 'مكية'),
  SurahInfo(number: 52, name: 'الطور', startPage: 523, revelationType: 'مكية'),
  SurahInfo(number: 53, name: 'النجم', startPage: 526, revelationType: 'مكية'),
  SurahInfo(number: 54, name: 'القمر', startPage: 528, revelationType: 'مكية'),
  SurahInfo(number: 55, name: 'الرحمن', startPage: 531, revelationType: 'مدنية'),
  SurahInfo(number: 56, name: 'الواقعة', startPage: 534, revelationType: 'مكية'),
  SurahInfo(number: 57, name: 'الحديد', startPage: 537, revelationType: 'مدنية'),
  SurahInfo(number: 58, name: 'المجادلة', startPage: 542, revelationType: 'مدنية'),
  SurahInfo(number: 59, name: 'الحشر', startPage: 545, revelationType: 'مدنية'),
  SurahInfo(number: 60, name: 'الممتحنة', startPage: 549, revelationType: 'مدنية'),
  SurahInfo(number: 61, name: 'الصف', startPage: 551, revelationType: 'مدنية'),
  SurahInfo(number: 62, name: 'الجمعة', startPage: 553, revelationType: 'مدنية'),
  SurahInfo(number: 63, name: 'المنافقون', startPage: 554, revelationType: 'مدنية'),
  SurahInfo(number: 64, name: 'التغابن', startPage: 556, revelationType: 'مدنية'),
  SurahInfo(number: 65, name: 'الطلاق', startPage: 558, revelationType: 'مدنية'),
  SurahInfo(number: 66, name: 'التحريم', startPage: 560, revelationType: 'مدنية'),
  SurahInfo(number: 67, name: 'الملك', startPage: 562, revelationType: 'مكية'),
  SurahInfo(number: 68, name: 'القلم', startPage: 564, revelationType: 'مكية'),
  SurahInfo(number: 69, name: 'الحاقة', startPage: 566, revelationType: 'مكية'),
  SurahInfo(number: 70, name: 'المعارج', startPage: 568, revelationType: 'مكية'),
  SurahInfo(number: 71, name: 'نوح', startPage: 570, revelationType: 'مكية'),
  SurahInfo(number: 72, name: 'الجن', startPage: 572, revelationType: 'مكية'),
  SurahInfo(number: 73, name: 'المزمل', startPage: 574, revelationType: 'مكية'),
  SurahInfo(number: 74, name: 'المدثر', startPage: 575, revelationType: 'مكية'),
  SurahInfo(number: 75, name: 'القيامة', startPage: 577, revelationType: 'مكية'),
  SurahInfo(number: 76, name: 'الإنسان', startPage: 578, revelationType: 'مدنية'),
  SurahInfo(number: 77, name: 'المرسلات', startPage: 580, revelationType: 'مكية'),
  SurahInfo(number: 78, name: 'النبأ', startPage: 582, revelationType: 'مكية'),
  SurahInfo(number: 79, name: 'النازعات', startPage: 583, revelationType: 'مكية'),
  SurahInfo(number: 80, name: 'عبس', startPage: 585, revelationType: 'مكية'),
  SurahInfo(number: 81, name: 'التكوير', startPage: 586, revelationType: 'مكية'),
  SurahInfo(number: 82, name: 'الانفطار', startPage: 587, revelationType: 'مكية'),
  SurahInfo(number: 83, name: 'المطففين', startPage: 587, revelationType: 'مكية'),
  SurahInfo(number: 84, name: 'الانشقاق', startPage: 589, revelationType: 'مكية'),
  SurahInfo(number: 85, name: 'البروج', startPage: 590, revelationType: 'مكية'),
  SurahInfo(number: 86, name: 'الطارق', startPage: 591, revelationType: 'مكية'),
  SurahInfo(number: 87, name: 'الأعلى', startPage: 591, revelationType: 'مكية'),
  SurahInfo(number: 88, name: 'الغاشية', startPage: 592, revelationType: 'مكية'),
  SurahInfo(number: 89, name: 'الفجر', startPage: 593, revelationType: 'مكية'),
  SurahInfo(number: 90, name: 'البلد', startPage: 594, revelationType: 'مكية'),
  SurahInfo(number: 91, name: 'الشمس', startPage: 595, revelationType: 'مكية'),
  SurahInfo(number: 92, name: 'الليل', startPage: 595, revelationType: 'مكية'),
  SurahInfo(number: 93, name: 'الضحى', startPage: 596, revelationType: 'مكية'),
  SurahInfo(number: 94, name: 'الشرح', startPage: 596, revelationType: 'مكية'),
  SurahInfo(number: 95, name: 'التين', startPage: 597, revelationType: 'مكية'),
  SurahInfo(number: 96, name: 'العلق', startPage: 597, revelationType: 'مكية'),
  SurahInfo(number: 97, name: 'القدر', startPage: 598, revelationType: 'مكية'),
  SurahInfo(number: 98, name: 'البينة', startPage: 598, revelationType: 'مدنية'),
  SurahInfo(number: 99, name: 'الزلزلة', startPage: 599, revelationType: 'مدنية'),
  SurahInfo(number: 100, name: 'العاديات', startPage: 599, revelationType: 'مكية'),
  SurahInfo(number: 101, name: 'القارعة', startPage: 600, revelationType: 'مكية'),
  SurahInfo(number: 102, name: 'التكاثر', startPage: 600, revelationType: 'مكية'),
  SurahInfo(number: 103, name: 'العصر', startPage: 601, revelationType: 'مكية'),
  SurahInfo(number: 104, name: 'الهمزة', startPage: 601, revelationType: 'مكية'),
  SurahInfo(number: 105, name: 'الفيل', startPage: 601, revelationType: 'مكية'),
  SurahInfo(number: 106, name: 'قريش', startPage: 602, revelationType: 'مكية'),
  SurahInfo(number: 107, name: 'الماعون', startPage: 602, revelationType: 'مكية'),
  SurahInfo(number: 108, name: 'الكوثر', startPage: 602, revelationType: 'مكية'),
  SurahInfo(number: 109, name: 'الكافرون', startPage: 603, revelationType: 'مكية'),
  SurahInfo(number: 110, name: 'النصر', startPage: 603, revelationType: 'مدنية'),
  SurahInfo(number: 111, name: 'المسد', startPage: 603, revelationType: 'مكية'),
  SurahInfo(number: 112, name: 'الإخلاص', startPage: 604, revelationType: 'مكية'),
  SurahInfo(number: 113, name: 'الفلق', startPage: 604, revelationType: 'مكية'),
  SurahInfo(number: 114, name: 'الناس', startPage: 604, revelationType: 'مكية'),
];

const List<JuzInfo> kJuzList = [
  JuzInfo(number: 1, title: 'الجزء الأول', startPage: 1),
  JuzInfo(number: 2, title: 'الجزء الثاني', startPage: 22),
  JuzInfo(number: 3, title: 'الجزء الثالث', startPage: 42),
  JuzInfo(number: 4, title: 'الجزء الرابع', startPage: 62),
  JuzInfo(number: 5, title: 'الجزء الخامس', startPage: 82),
  JuzInfo(number: 6, title: 'الجزء السادس', startPage: 102),
  JuzInfo(number: 7, title: 'الجزء السابع', startPage: 121),
  JuzInfo(number: 8, title: 'الجزء الثامن', startPage: 142),
  JuzInfo(number: 9, title: 'الجزء التاسع', startPage: 162),
  JuzInfo(number: 10, title: 'الجزء العاشر', startPage: 182),
  JuzInfo(number: 11, title: 'الجزء الحادي عشر', startPage: 201),
  JuzInfo(number: 12, title: 'الجزء الثاني عشر', startPage: 222),
  JuzInfo(number: 13, title: 'الجزء الثالث عشر', startPage: 242),
  JuzInfo(number: 14, title: 'الجزء الرابع عشر', startPage: 262),
  JuzInfo(number: 15, title: 'الجزء الخامس عشر', startPage: 282),
  JuzInfo(number: 16, title: 'الجزء السادس عشر', startPage: 302),
  JuzInfo(number: 17, title: 'الجزء السابع عشر', startPage: 322),
  JuzInfo(number: 18, title: 'الجزء الثامن عشر', startPage: 342),
  JuzInfo(number: 19, title: 'الجزء التاسع عشر', startPage: 362),
  JuzInfo(number: 20, title: 'الجزء العشرون', startPage: 382),
  JuzInfo(number: 21, title: 'الجزء الحادي والعشرون', startPage: 402),
  JuzInfo(number: 22, title: 'الجزء الثاني والعشرون', startPage: 422),
  JuzInfo(number: 23, title: 'الجزء الثالث والعشرون', startPage: 442),
  JuzInfo(number: 24, title: 'الجزء الرابع والعشرون', startPage: 462),
  JuzInfo(number: 25, title: 'الجزء الخامس والعشرون', startPage: 482),
  JuzInfo(number: 26, title: 'الجزء السادس والعشرون', startPage: 502),
  JuzInfo(number: 27, title: 'الجزء السابع والعشرون', startPage: 522),
  JuzInfo(number: 28, title: 'الجزء الثامن والعشرون', startPage: 542),
  JuzInfo(number: 29, title: 'الجزء التاسع والعشرون', startPage: 562),
  JuzInfo(number: 30, title: 'الجزء الثلاثون', startPage: 582),
];

class PageThemePalette {
  final Color background;
  final Color paper;
  final Color ink;
  final Color accent;
  final Color outerFrame;
  final Color innerFrame;

  const PageThemePalette({
    required this.background,
    required this.paper,
    required this.ink,
    required this.accent,
    required this.outerFrame,
    required this.innerFrame,
  });

  factory PageThemePalette.fromHueAndShade({
    required double hue,
    required double shade,
  }) {
    final double h = hue % 360.0;
    final double s = shade.clamp(0.0, 1.0);

    final double paperLightness = ui.lerpDouble(0.975, 0.80, s)!;
    final double paperSat = ui.lerpDouble(0.28, 0.48, s)!;

    final double bgLightness = ui.lerpDouble(0.945, 0.74, s)!;
    final double bgSat = ui.lerpDouble(0.24, 0.42, s)!;

    final Color paper =
        HSLColor.fromAHSL(1.0, h, paperSat, paperLightness).toColor();
    final Color background =
        HSLColor.fromAHSL(1.0, h, bgSat, bgLightness).toColor();

    final double inkLightness = ui.lerpDouble(0.16, 0.11, s)!;
    final Color ink = HSLColor.fromAHSL(1.0, h, 0.22, inkLightness).toColor();

    final Color accent = HSLColor.fromAHSL(1.0, h, 0.52, 0.34).toColor();
    final Color outerFrame = HSLColor.fromAHSL(1.0, h, 0.48, 0.33).toColor();
    final Color innerFrame = HSLColor.fromAHSL(1.0, h, 0.42, 0.49).toColor();

    return PageThemePalette(
      background: background,
      paper: paper,
      ink: ink,
      accent: accent,
      outerFrame: outerFrame,
      innerFrame: innerFrame,
    );
  }
}

class ThikrItem {
  final String id;
  final String category;
  final String title;
  final String text;
  final int targetCount;

  const ThikrItem({
    required this.id,
    required this.category,
    required this.title,
    required this.text,
    required this.targetCount,
  });
}

const List<String> kThikrCategories = [
  'أذكار الصباح',
  'أذكار المساء',
  'أذكار بعد الصلاة',
  'أدعية واستغفار',
];

const List<ThikrItem> kThikrItems = [
  ThikrItem(
    id: 'm_1',
    category: 'أذكار الصباح',
    title: 'سَيِّدُ الِاسْتِغْفَارِ وَالذِّكْرُ',
    text: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'm_2',
    category: 'أذكار الصباح',
    title: 'ذِكْرُ الصَّبَاحِ',
    text: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'm_3',
    category: 'أذكار الصباح',
    title: 'رِضَا اللَّهِ',
    text: 'رضيت بالله رباً، وبالإسلام ديناً، وبمحمد صلى الله عليه وسلم نبياً.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'm_4',
    category: 'أذكار الصباح',
    title: 'تَسْبِيحُ الصَّبَاحِ',
    text: 'سبحان الله وبحمده، عدد خلقه، ورضا نفسه، وزنة عرشه، ومداد كلماته.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'm_5',
    category: 'أذكار الصباح',
    title: 'الِاسْتِغْفَارُ الْعَظِيمُ',
    text: 'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'e_1',
    category: 'أذكار المساء',
    title: 'ذِكْرُ الْمَسَاءِ',
    text: 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'e_2',
    category: 'أذكار المساء',
    title: 'الْمَصِيرُ إِلَى اللَّهِ',
    text: 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت وإليك المصير.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'e_3',
    category: 'أذكار المساء',
    title: 'كَلِمَاتُ اللَّهِ التَّامَّاتُ',
    text: 'أعوذ بكلمات الله التامات من شر ما خلق.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'e_4',
    category: 'أذكار المساء',
    title: 'الْحِفْظُ بِاسْمِ اللَّهِ',
    text: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'p_1',
    category: 'أذكار بعد الصلاة',
    title: 'الِاسْتِغْفَارُ وَالسَّلَامُ',
    text: 'أستغفر الله، أستغفر الله، أستغفر الله. اللهم أنت السلام ومنك السلام، تباركت يا ذا الجلال والإكرام.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'p_2',
    category: 'أذكار بعد الصلاة',
    title: 'سُبْحَانَ اللَّهِ',
    text: 'سبحان الله.',
    targetCount: 33,
  ),
  ThikrItem(
    id: 'p_3',
    category: 'أذكار بعد الصلاة',
    title: 'الْحَمْدُ لِلَّهِ',
    text: 'الحمد لله.',
    targetCount: 33,
  ),
  ThikrItem(
    id: 'p_4',
    category: 'أذكار بعد الصلاة',
    title: 'اللَّهُ أَكْبَرُ',
    text: 'الله أكبر.',
    targetCount: 33,
  ),
  ThikrItem(
    id: 'd_1',
    category: 'أدعية واستغفار',
    title: 'حَسَنَةُ الدُّنْيَا وَالْآخِرَةِ',
    text: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'd_2',
    category: 'أدعية واستغفار',
    title: 'الْهُدَى وَالتُّقَى',
    text: 'اللهم إني أسألك الهدى والتقى والعفاف والغنى.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'd_3',
    category: 'أدعية واستغفار',
    title: 'تَسْبِيحُ يُونُسَ عَلَيْهِ السَّلَامُ',
    text: 'لا إله إلا أنت سبحانك إني كنت من الظالمين.',
    targetCount: 3,
  ),
];

class MainThreeTabShell extends StatefulWidget {
  const MainThreeTabShell({super.key});

  @override
  State<MainThreeTabShell> createState() => _MainThreeTabShellState();
}

class _MainThreeTabShellState extends State<MainThreeTabShell> {
  int _selectedTab = 0;
  int _currentMushafPage = 1;
  int _dailyWirdGoal = 20;
  int _wirdReadToday = 0;

  @override
  void initState() {
    super.initState();
    _loadSharedProgress();
  }

  Future<void> _loadSharedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _currentMushafPage = (prefs.getInt('current_page') ?? 1).clamp(1, 604);
      _dailyWirdGoal = prefs.getInt('daily_wird_goal') ?? 20;
      _wirdReadToday = prefs.getInt('wird_read_today') ?? 0;
    });
  }

  void _syncKhatmaStats(int page, int readToday, int goal) {
    if (!mounted) return;
    setState(() {
      _currentMushafPage = page;
      _wirdReadToday = readToday;
      _dailyWirdGoal = goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: [
          AdhanHomeTab(
            khatmaPage: _currentMushafPage,
            wirdRead: _wirdReadToday,
            wirdGoal: _dailyWirdGoal,
            onOpenKhatma: () => setState(() => _selectedTab = 1),
            onOpenAthkar: () => setState(() => _selectedTab = 2),
          ),
          KhatmaMushafTab(
            onProgressChanged: _syncKhatmaStats,
          ),
          const AthkarTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (idx) => setState(() => _selectedTab = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'الأذان',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'الختمة',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'الأذكار',
          ),
        ],
      ),
    );
  }
}

class AdhanHomeTab extends StatefulWidget {
  final int khatmaPage;
  final int wirdRead;
  final int wirdGoal;
  final VoidCallback onOpenKhatma;
  final VoidCallback onOpenAthkar;

  const AdhanHomeTab({
    super.key,
    required this.khatmaPage,
    required this.wirdRead,
    required this.wirdGoal,
    required this.onOpenKhatma,
    required this.onOpenAthkar,
  });

  @override
  State<AdhanHomeTab> createState() => _AdhanHomeTabState();
}

class _AdhanHomeTabState extends State<AdhanHomeTab> {
  CityPreset _selectedCity = kCities.first;
  String _methodKey = 'umm_al_qura';
  bool _azanAlertEnabled = true;
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadAdhanPrefs();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadAdhanPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cityName = prefs.getString('adhan_city') ?? kCities.first.name;
    final city = kCities.firstWhere(
      (c) => c.name == cityName,
      orElse: () => kCities.first,
    );
    final method = prefs.getString('adhan_method') ?? city.methodKey;
    final alert = prefs.getBool('adhan_alert') ?? true;
    if (!mounted) return;
    setState(() {
      _selectedCity = city;
      _methodKey = method;
      _azanAlertEnabled = alert;
    });
  }

  Future<void> _saveAdhanPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adhan_city', _selectedCity.name);
    await prefs.setString('adhan_method', _methodKey);
    await prefs.setBool('adhan_alert', _azanAlertEnabled);
  }

  PrayerTimes _computeTodayPrayerTimesForDate(DateTime dateTime) {
    final coords = Coordinates(_selectedCity.latitude, _selectedCity.longitude);
    final params = _calculationMethodFromKey(_methodKey);
    params.madhab = Madhab.shafi;
    final date = DateComponents.from(dateTime);
    return PrayerTimes(coords, date, params);
  }

  String _prayerArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.none:
        return 'الفجر';
    }
  }

  String _formatClock(DateTime dt) {
    final int hour24 = dt.hour;
    final int hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final String period = hour24 >= 12 ? 'م' : 'ص';
    final String min = dt.minute.toString().padLeft(2, '0');
    return '$hour12:$min $period';
  }

  String _formatRemaining(Duration diff) {
    if (diff.isNegative) return '00:00:00';
    final int h = diff.inHours;
    final int m = diff.inMinutes.remainder(60);
    final int s = diff.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final PrayerTimes pt = _computeTodayPrayerTimesForDate(_now);
    Prayer next = pt.nextPrayer();
    DateTime? nextTime = pt.timeForPrayer(next);
    DateTime? prevTime;

    final List<(Prayer, DateTime)> orderedToday = [
      (Prayer.fajr, pt.fajr),
      (Prayer.sunrise, pt.sunrise),
      (Prayer.dhuhr, pt.dhuhr),
      (Prayer.asr, pt.asr),
      (Prayer.maghrib, pt.maghrib),
      (Prayer.isha, pt.isha),
    ];

    if (next == Prayer.none || nextTime == null) {
      final tomorrow = _now.add(const Duration(days: 1));
      final tomorrowPt = _computeTodayPrayerTimesForDate(tomorrow);
      next = Prayer.fajr;
      nextTime = tomorrowPt.fajr;
      prevTime = pt.isha;
    } else {
      final int idx = orderedToday.indexWhere((e) => e.$1 == next);
      if (idx > 0) {
        prevTime = orderedToday[idx - 1].$2;
      } else {
        final yesterdayPt = _computeTodayPrayerTimesForDate(
            _now.subtract(const Duration(days: 1)));
        prevTime = yesterdayPt.isha;
      }
    }

    final Duration remaining = nextTime.difference(_now);
    final double windowProgress = () {
      if (prevTime == null) return 0.0;
      final int totalSec = nextTime!.difference(prevTime).inSeconds;
      if (totalSec <= 0) return 0.0;
      final int elapsedSec = _now.difference(prevTime).inSeconds;
      return (elapsedSec / totalSec).clamp(0.0, 1.0);
    }();

    const Color warmBg = Color(0xFFF6F1E7);
    const Color cardBg = Color(0xFFFFFCF6);
    const Color primary = Color(0xFF235347);
    const Color ink = Color(0xFF1E2421);

    final int khatmaPct = ((widget.khatmaPage / 604) * 100).round();

    return Scaffold(
      backgroundColor: warmBg,
      appBar: AppBar(
        backgroundColor: warmBg,
        elevation: 0,
        title: Text(
          'مواقيت الأذان — ${_selectedCity.name}',
          style: const TextStyle(
              color: ink, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip:
                _azanAlertEnabled ? 'تنبيه الأذان مفعّل' : 'تنبيه الأذان متوقف',
            icon: Icon(
              _azanAlertEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: primary,
            ),
            onPressed: () {
              setState(() => _azanAlertEnabled = !_azanAlertEnabled);
              _saveAdhanPrefs();
            },
          ),
          IconButton(
            tooltip: 'تغيير المدينة وطريقة الحساب',
            icon: const Icon(Icons.tune, color: primary),
            onPressed: _openLocationAndMethodSheet,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الصلاة القادمة: ${_prayerArabicName(next)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatClock(nextTime),
                      style: const TextStyle(
                        color: Color(0xFFE5F3EE),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'المتبقي على الأذان: ${_formatRemaining(remaining)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: windowProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFE5F3EE)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'الحساب: ${_methodLabel(_methodKey)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onOpenKhatma,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'الختمة: صفحة ${widget.khatmaPage} من 604 ($khatmaPct%) • الورد: ${widget.wirdRead}/${widget.wirdGoal}',
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...orderedToday.map((item) {
            final bool isNext = item.$1 == next;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isNext ? primary.withValues(alpha: 0.12) : cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNext ? primary : ink.withValues(alpha: 0.12),
                  width: isNext ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  isNext ? Icons.alarm_on : Icons.schedule,
                  color: isNext ? primary : ink.withValues(alpha: 0.65),
                ),
                title: Text(
                  _prayerArabicName(item.$1),
                  style: TextStyle(
                    color: ink,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  _formatClock(item.$2),
                  style: TextStyle(
                    color: isNext ? primary : ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: widget.onOpenKhatma,
                  icon: const Icon(Icons.menu_book),
                  label: Text('المصحف والختمة (ص ${widget.khatmaPage})'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: widget.onOpenAthkar,
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('الأذكار'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openLocationAndMethodSheet() {
    CityPreset tempCity = _selectedCity;
    String tempMethod = _methodKey;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFCF6),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'المدينة وطريقة الحساب',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kCities.map((c) {
                        final selected = tempCity.name == c.name;
                        return ChoiceChip(
                          label: Text(c.name),
                          selected: selected,
                          onSelected: (_) {
                            setLocal(() {
                              tempCity = c;
                              tempMethod = c.methodKey;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: tempMethod,
                      decoration: const InputDecoration(
                        labelText: 'طريقة الحساب',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'umm_al_qura', child: Text('أم القرى')),
                        DropdownMenuItem(
                            value: 'egyptian',
                            child: Text('الهيئة المصرية العامة للمساحة')),
                        DropdownMenuItem(
                            value: 'muslim_world_league',
                            child: Text('رابطة العالم الإسلامي')),
                        DropdownMenuItem(
                            value: 'dubai', child: Text('دبي')),
                        DropdownMenuItem(
                            value: 'karachi',
                            child: Text('جامعة العلوم الإسلامية بكراتشي')),
                        DropdownMenuItem(
                            value: 'north_america',
                            child: Text('أمريكا الشمالية (ISNA)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setLocal(() => tempMethod = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _selectedCity = tempCity;
                          _methodKey = tempMethod;
                        });
                        _saveAdhanPrefs();
                        Navigator.pop(ctx);
                      },
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class KhatmaMushafTab extends StatefulWidget {
  final void Function(int page, int readToday, int goal)? onProgressChanged;

  const KhatmaMushafTab({super.key, this.onProgressChanged});

  @override
  State<KhatmaMushafTab> createState() => _KhatmaMushafTabState();
}

class _KhatmaMushafTabState extends State<KhatmaMushafTab> {
  static const int totalPages = 604;

  // «نقطة التاج»: تفعيل سحب الرجوع باليد بانسيابية التقدم
  static const bool kCrownPointEnabled = true;

  static const Color _softBookmarkRed = Color(0xFFC94A4A);
  static const Color _softBookmarkRedLight = Color(0xFFD96B6B);
  static const Color _softBookmarkRedDark = Color(0xFF9E3434);

  GlobalKey<PageFlipWidgetState> _pageFlipKey =
      GlobalKey<PageFlipWidgetState>();

  int _currentPage = 1;
  int? _bookmarkedPage;
  int? _secondaryBookmarkPage;
  double _ribbonDropRatio = 0.34;
  int _dailyWirdGoalPages = 20;
  int _wirdReadToday = 0;
  String _lastWirdDate = '';
  double _pageScale = 1.0;

  String _selectedThemeId = 'classic_cream';
  double _themeHue = 38.0;
  double _themeShade = 0.14;
  bool _showBottomBar = false;

  Offset? _pointerDownPos;
  bool _movedDuringTouch = false;

  late final List<int> _allPageNumbers =
      List<int>.generate(totalPages, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDate = prefs.getString('last_wird_date') ?? today;
    final savedWird =
        savedDate == today ? (prefs.getInt('wird_read_today') ?? 0) : 0;

    if (!mounted) return;
    setState(() {
      _currentPage = (prefs.getInt('current_page') ?? 1).clamp(1, totalPages);
      _bookmarkedPage = prefs.getInt('bookmarked_page');
      _secondaryBookmarkPage = prefs.getInt('secondary_bookmark_page');
      _ribbonDropRatio =
          (prefs.getDouble('ribbon_drop_ratio') ?? 0.34).clamp(0.14, 0.78);
      _pageScale = (prefs.getDouble('page_scale') ?? 1.0).clamp(0.9, 1.25);
      _dailyWirdGoalPages = prefs.getInt('daily_wird_goal') ?? 20;
      _selectedThemeId = prefs.getString('theme_preset_id') ?? 'classic_cream';
      _themeHue = (prefs.getDouble('theme_hue') ?? 38.0).clamp(0.0, 360.0);
      _themeShade = (prefs.getDouble('theme_shade') ?? 0.14).clamp(0.0, 1.0);
      _showBottomBar = prefs.getBool('show_bottom_bar') ?? false;
      _lastWirdDate = today;
      _wirdReadToday = savedWird;
      _pageFlipKey = GlobalKey<PageFlipWidgetState>();
    });
    _notifyParent();
  }

  void _notifyParent() {
    widget.onProgressChanged
        ?.call(_currentPage, _wirdReadToday, _dailyWirdGoalPages);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_page', _currentPage);
    if (_bookmarkedPage != null) {
      await prefs.setInt('bookmarked_page', _bookmarkedPage!);
    } else {
      await prefs.remove('bookmarked_page');
    }
    if (_secondaryBookmarkPage != null) {
      await prefs.setInt('secondary_bookmark_page', _secondaryBookmarkPage!);
    } else {
      await prefs.remove('secondary_bookmark_page');
    }
    await prefs.setDouble('ribbon_drop_ratio', _ribbonDropRatio);
    await prefs.setDouble('page_scale', _pageScale);
    await prefs.setInt('daily_wird_goal', _dailyWirdGoalPages);
    await prefs.setString('theme_preset_id', _selectedThemeId);
    await prefs.setDouble('theme_hue', _themeHue);
    await prefs.setDouble('theme_shade', _themeShade);
    await prefs.setBool('show_bottom_bar', _showBottomBar);
    await prefs.setString('last_wird_date', _lastWirdDate);
    await prefs.setInt('wird_read_today', _wirdReadToday);
    _notifyParent();
  }

  void _advanceWirdOnce() {
    final today = _todayKey();
    if (_lastWirdDate != today) {
      _lastWirdDate = today;
      _wirdReadToday = 0;
    }
    if (_wirdReadToday < _dailyWirdGoalPages) {
      _wirdReadToday++;
    }
  }

  void _onPageChanged(int newPage) {
    final int clamped = newPage.clamp(1, totalPages);
    if (clamped == _currentPage) return;
    setState(() {
      if (clamped > _currentPage) {
        _advanceWirdOnce();
      }
      _currentPage = clamped;
    });
    _saveState();
  }

  void _jumpToPage(int page) {
    final int clamped = page.clamp(1, totalPages);
    setState(() {
      _currentPage = clamped;
      _pageFlipKey = GlobalKey<PageFlipWidgetState>();
    });
    _saveState();
  }

  void _toggleBookmark() {
    setState(() {
      _bookmarkedPage = _bookmarkedPage == _currentPage ? null : _currentPage;
    });
    _saveState();
  }

  void _toggleSecondaryBookmark() {
    setState(() {
      _secondaryBookmarkPage =
          _secondaryBookmarkPage == _currentPage ? null : _currentPage;
    });
    _saveState();
  }

  void _onPointerDown(PointerDownEvent e) {
    _pointerDownPos = e.localPosition;
    _movedDuringTouch = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    final start = _pointerDownPos;
    if (start == null) return;
    if ((e.localPosition - start).distance > 12.0) {
      _movedDuringTouch = true;
      if (_showBottomBar) {
        setState(() => _showBottomBar = false);
        _saveState();
      }
    }
  }

  void _onPointerUp() {
    if (_pointerDownPos != null && !_movedDuringTouch) {
      setState(() => _showBottomBar = !_showBottomBar);
      _saveState();
    }
    _pointerDownPos = null;
    _movedDuringTouch = false;
  }

  SurahInfo _surahForPage(int page) {
    SurahInfo res = kSurahs.first;
    for (final s in kSurahs) {
      if (s.startPage <= page) {
        res = s;
      } else {
        break;
      }
    }
    return res;
  }

  JuzInfo _juzForPage(int page) {
    JuzInfo res = kJuzList.first;
    for (final j in kJuzList) {
      if (j.startPage <= page) {
        res = j;
      } else {
        break;
      }
    }
    return res;
  }

  Widget _buildSheetForPage(int pageNumber, PageThemePalette palette) {
    return MushafSingleSheet(
      pageNumber: pageNumber,
      surahName: _surahForPage(pageNumber).name,
      juzTitle: _juzForPage(pageNumber).title,
      palette: palette,
      scale: _pageScale,
      wirdRead: _wirdReadToday,
      wirdGoal: _dailyWirdGoalPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PageThemePalette palette = PageThemePalette.fromHueAndShade(
      hue: _themeHue,
      shade: _themeShade,
    );

    final bool hasBookmarkOnCurrent = _bookmarkedPage == _currentPage;
    final bool hasSecondaryOnCurrent = _secondaryBookmarkPage == _currentPage;

    const double juzBoxWidth = 114.0;
    const double bookmarkRightOfJuzLeft = 16.0 + juzBoxWidth + 4.0;

    final int startIndex =
        kCrownPointEnabled ? 0 : (_currentPage - 1).clamp(0, totalPages - 1);
    final int remainingBeforeLast = (totalPages - 1) - startIndex;

    final List<Widget> flipChildren = List.generate(
      remainingBeforeLast,
      (offset) {
        final int pageNum = _allPageNumbers[startIndex + offset];
        return NotificationListener<ScrollNotification>(
          onNotification: (_) {
            if (pageNum != _currentPage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _onPageChanged(pageNum);
              });
            }
            return false;
          },
          child: _buildSheetForPage(pageNum, palette),
        );
      },
    );

    return Scaffold(
      backgroundColor: palette.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double height = constraints.maxHeight;

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: (_) => _onPointerUp(),
            onPointerCancel: (_) {
              _pointerDownPos = null;
              _movedDuringTouch = false;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: PageFlipWidget(
                    key: _pageFlipKey,
                    backgroundColor: palette.paper,
                    lastPage: _buildSheetForPage(totalPages, palette),
                    children: flipChildren,
                  ),
                ),
                if (hasBookmarkOnCurrent)
                  _RedBookmarkCordOverlay(
                    pageHeight: height,
                    dropRatio: _ribbonDropRatio,
                    onDropRatioChanged: (newRatio) {
                      setState(() => _ribbonDropRatio = newRatio);
                    },
                    onDragEnd: _saveState,
                    onTap: _toggleBookmark,
                  ),
                Positioned(
                  top: 3,
                  left: bookmarkRightOfJuzLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TopQuickChip(
                        icon: Icons.bookmark,
                        color: hasBookmarkOnCurrent
                            ? _softBookmarkRed
                            : palette.ink.withValues(alpha: 0.82),
                        bgColor: palette.paper,
                        borderColor: const Color(0xFFE67E22),
                        tooltip: hasBookmarkOnCurrent
                            ? 'إزالة الحبل الأحمر'
                            : 'إنزال الحبل الأحمر',
                        onTap: _toggleBookmark,
                      ),
                      if (_bookmarkedPage != null &&
                          !hasBookmarkOnCurrent) ...[
                        const SizedBox(width: 2),
                        _TopQuickChip(
                          icon: Icons.turned_in,
                          color: _softBookmarkRed,
                          bgColor: palette.paper,
                          borderColor: palette.outerFrame,
                          tooltip:
                              'الانتقال إلى الحبل الأحمر (ص $_bookmarkedPage)',
                          onTap: () => _jumpToPage(_bookmarkedPage!),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_showBottomBar)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _FloatingBottomBar(
                      palette: palette,
                      currentPage: _currentPage,
                      hasSecondaryBookmark: hasSecondaryOnCurrent,
                      secondaryBookmarkPage: _secondaryBookmarkPage,
                      wirdRead: _wirdReadToday,
                      wirdGoal: _dailyWirdGoalPages,
                      onJumpPage: _jumpToPage,
                      onOpenSurahs: () => _openSurahs(palette),
                      onOpenJuz: () => _openJuz(palette),
                      onOpenWird: _openWird,
                      onToggleSecondaryBookmark: _toggleSecondaryBookmark,
                      onJumpSecondaryBookmark: _secondaryBookmarkPage == null
                          ? null
                          : () => _jumpToPage(_secondaryBookmarkPage!),
                      onOpenScale: () => _openScale(palette),
                      onOpenTheme: () => _openThemeCustomizer(palette),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openThemeCustomizer(PageThemePalette currentPalette) {
    double tempHue = _themeHue;
    double tempShade = _themeShade;
    String tempPresetId = _selectedThemeId;

    showModalBottomSheet(
      context: context,
      backgroundColor: currentPalette.paper,
      isScrollControlled: true,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocal) {
              final livePalette = PageThemePalette.fromHueAndShade(
                hue: tempHue,
                shade: tempShade,
              );

              return Container(
                color: livePalette.paper,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ثيم الصفحة (اللون والتدريجة)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: livePalette.ink,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: livePalette.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: livePalette.accent, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kPageThemePresets.map((preset) {
                        final bool selected = tempPresetId == preset.id;
                        final pCol = PageThemePalette.fromHueAndShade(
                          hue: preset.hue,
                          shade: preset.shade,
                        );
                        return ChoiceChip(
                          selected: selected,
                          label: Text(preset.name),
                          selectedColor: pCol.accent.withValues(alpha: 0.22),
                          backgroundColor: pCol.background,
                          labelStyle: TextStyle(
                            color: livePalette.ink,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setLocal(() {
                              tempPresetId = preset.id;
                              tempHue = preset.hue;
                              tempShade = preset.shade;
                            });
                            setState(() {
                              _selectedThemeId = preset.id;
                              _themeHue = preset.hue;
                              _themeShade = preset.shade;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'اللون: ${tempHue.round()}°',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: livePalette.ink,
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: 360.0,
                      value: tempHue,
                      activeColor: livePalette.accent,
                      onChanged: (v) {
                        setLocal(() {
                          tempHue = v;
                          tempPresetId = 'custom';
                        });
                        setState(() {
                          _themeHue = v;
                          _selectedThemeId = 'custom';
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'التدريجة: ${(tempShade * 100).round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: livePalette.ink,
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      value: tempShade,
                      activeColor: livePalette.accent,
                      onChanged: (v) {
                        setLocal(() {
                          tempShade = v;
                          tempPresetId = 'custom';
                        });
                        setState(() {
                          _themeShade = v;
                          _selectedThemeId = 'custom';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: livePalette.accent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _saveState();
                          Navigator.pop(ctx);
                        },
                        child: const Text('حفظ الثيم'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openSurahs(PageThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.paper,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'فهرس السور',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: palette.ink),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kSurahs.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1, color: palette.ink.withValues(alpha: 0.12)),
                  itemBuilder: (_, i) {
                    final s = kSurahs[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: palette.ink.withValues(alpha: 0.12),
                        child: Text('${s.number}',
                            style: TextStyle(color: palette.ink, fontSize: 13)),
                      ),
                      title: Text(s.name,
                          style: TextStyle(
                              color: palette.ink, fontWeight: FontWeight.w600)),
                      subtitle: Text(s.revelationType,
                          style: TextStyle(
                              color: palette.ink.withValues(alpha: 0.68))),
                      trailing: Text('ص ${s.startPage}',
                          style: TextStyle(
                              color: palette.ink.withValues(alpha: 0.85))),
                      onTap: () {
                        Navigator.pop(ctx);
                        _jumpToPage(s.startPage);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openJuz(PageThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.paper,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'أجزاء المصحف الثلاثون',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: palette.ink),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kJuzList.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1, color: palette.ink.withValues(alpha: 0.12)),
                  itemBuilder: (_, i) {
                    final j = kJuzList[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: palette.ink.withValues(alpha: 0.12),
                        child: Text('${j.number}',
                            style: TextStyle(color: palette.ink, fontSize: 13)),
                      ),
                      title: Text(j.title,
                          style: TextStyle(
                              color: palette.ink, fontWeight: FontWeight.w600)),
                      trailing: Text('تبدأ من ص ${j.startPage}',
                          style: TextStyle(
                              color: palette.ink.withValues(alpha: 0.85))),
                      onTap: () {
                        Navigator.pop(ctx);
                        _jumpToPage(j.startPage);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWird() {
    int tempGoal = _dailyWirdGoalPages;
    final int khatmaPercent = ((_currentPage / totalPages) * 100).round();
    final int estimatedDays =
        tempGoal > 0 ? ((totalPages - _currentPage) / tempGoal).ceil() : 0;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: const Text('الختمة والورد اليومي'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    'موضع الختمة الحالي: صفحة $_currentPage من $totalPages ($khatmaPercent%)'),
                const SizedBox(height: 4),
                Text('الورد اليومي: $_wirdReadToday / $tempGoal صفحة'),
                const SizedBox(height: 4),
                Text(
                    'الأيام المتبقية لإتمام الختمة تقريباً: $estimatedDays يوم'),
                const SizedBox(height: 10),
                Slider(
                  min: 1,
                  max: 60,
                  divisions: 59,
                  value: tempGoal.toDouble(),
                  onChanged: (v) => setLocal(() => tempGoal = v.round()),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء')),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _dailyWirdGoalPages = tempGoal;
                    if (_wirdReadToday > _dailyWirdGoalPages) {
                      _wirdReadToday = _dailyWirdGoalPages;
                    }
                  });
                  _saveState();
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openScale(PageThemePalette palette) {
    double tempScale = _pageScale;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.paper,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocal) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'حجم عرض الصفحة: ${(tempScale * 100).round()}%',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: palette.ink),
                  ),
                  Slider(
                    min: 0.9,
                    max: 1.25,
                    divisions: 14,
                    value: tempScale,
                    activeColor: palette.accent,
                    onChanged: (v) {
                      setLocal(() => tempScale = v);
                      setState(() => _pageScale = v);
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _saveState();
                        Navigator.pop(ctx);
                      },
                      child: const Text('تم'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopQuickChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final String tooltip;
  final VoidCallback onTap;

  const _TopQuickChip({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: borderColor, width: 1.4),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Icon(icon, size: 14, color: color),
          ),
        ),
      ),
    );
  }
}

class _RedBookmarkCordOverlay extends StatelessWidget {
  final double pageHeight;
  final double dropRatio;
  final ValueChanged<double> onDropRatioChanged;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;

  const _RedBookmarkCordOverlay({
    required this.pageHeight,
    required this.dropRatio,
    required this.onDropRatioChanged,
    required this.onDragEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double usableH = math.max(120.0, pageHeight);
    final double cordLength = (usableH * dropRatio).clamp(64.0, usableH * 0.85);

    return Positioned(
      top: 0,
      left: 68,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onVerticalDragUpdate: (details) {
          final double nextLength =
              (cordLength + details.delta.dy).clamp(64.0, usableH * 0.85);
          onDropRatioChanged((nextLength / usableH).clamp(0.14, 0.82));
        },
        onVerticalDragEnd: (_) => onDragEnd(),
        child: CustomPaint(
          size: Size(24, cordLength + 18),
          painter: _RedCordPainter(cordLength: cordLength),
        ),
      ),
    );
  }
}

class _RedCordPainter extends CustomPainter {
  final double cordLength;

  _RedCordPainter({required this.cordLength});

  @override
  void paint(Canvas canvas, Size size) {
    const double cordWidth = 6.0;
    final double centerX = size.width * 0.5;
    final double leftX = centerX - cordWidth * 0.5;
    final double rightX = centerX + cordWidth * 0.5;

    final Path shadowPath = Path()
      ..moveTo(leftX + 1.5, 0)
      ..lineTo(rightX + 1.5, 0)
      ..lineTo(rightX + 1.5, cordLength)
      ..lineTo(centerX + 1.5, cordLength + 11)
      ..lineTo(leftX + 1.5, cordLength)
      ..close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final Paint cordPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(leftX, 0),
        Offset(rightX, 0),
        const [
          _KhatmaMushafTabState._softBookmarkRedDark,
          _KhatmaMushafTabState._softBookmarkRedLight,
          _KhatmaMushafTabState._softBookmarkRed,
        ],
        const [0.0, 0.45, 1.0],
      );

    final Path cordPath = Path()
      ..moveTo(leftX, 0)
      ..lineTo(rightX, 0)
      ..lineTo(rightX, cordLength)
      ..lineTo(centerX, cordLength + 11)
      ..lineTo(leftX, cordLength)
      ..close();

    canvas.drawPath(cordPath, cordPaint);

    canvas.drawCircle(
      Offset(centerX, cordLength + 12),
      2.5,
      Paint()..color = _KhatmaMushafTabState._softBookmarkRedDark,
    );
  }

  @override
  bool shouldRepaint(covariant _RedCordPainter oldDelegate) =>
      oldDelegate.cordLength != cordLength;
}

class MushafSingleSheet extends StatelessWidget {
  final int pageNumber;
  final String surahName;
  final String juzTitle;
  final PageThemePalette palette;
  final double scale;
  final int wirdRead;
  final int wirdGoal;

  const MushafSingleSheet({
    super.key,
    required this.pageNumber,
    required this.surahName,
    required this.juzTitle,
    required this.palette,
    required this.scale,
    required this.wirdRead,
    required this.wirdGoal,
  });

  @override
  Widget build(BuildContext context) {
    final String assetPath = 'assets/images/quran/$pageNumber.png';
    final double wirdRatio =
        wirdGoal > 0 ? (wirdRead / wirdGoal).clamp(0.0, 1.0) : 0.0;

    return Transform.scale(
      scale: scale,
      child: Container(
        color: palette.paper,
        child: CustomPaint(
          painter: _AuthenticQuranicFramePainter(
            outerColor: palette.outerFrame,
            innerColor: palette.innerFrame,
            paperColor: palette.paper,
            accentColor: palette.accent,
            inkColor: palette.ink,
            surahLabel: 'سورة $surahName',
            juzLabel: juzTitle,
            wirdRatio: wirdRatio,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 32, 10, 10),
            child: SizedBox.expand(
              child: Image.asset(
                assetPath,
                fit: BoxFit.fill,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 44,
                          color: palette.outerFrame.withValues(alpha: 0.75),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'صفحة الختمة رقم $pageNumber من 604',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: palette.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          assetPath,
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.ink.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthenticQuranicFramePainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;
  final Color paperColor;
  final Color accentColor;
  final Color inkColor;
  final String surahLabel;
  final String juzLabel;
  final double wirdRatio;

  _AuthenticQuranicFramePainter({
    required this.outerColor,
    required this.innerColor,
    required this.paperColor,
    required this.accentColor,
    required this.inkColor,
    required this.surahLabel,
    required this.juzLabel,
    required this.wirdRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 32 || size.height <= 32) return;

    const double topInset = 18.0;
    final Rect outer =
        Rect.fromLTRB(3, topInset, size.width - 3, size.height - 3);
    final Rect mid = outer.deflate(3.0);
    final Rect inner = outer.deflate(6.0);

    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint midPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint innerPaint = Paint()
      ..color = outerColor.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const double boxHeight = 25.0;
    const double surahBoxWidth = 118.0;
    const double juzBoxWidth = 114.0;

    final Rect surahRect = Rect.fromLTWH(
      outer.right - surahBoxWidth - 8,
      2,
      surahBoxWidth,
      boxHeight,
    );
    final Rect juzRect = Rect.fromLTWH(
      outer.left + 8,
      2,
      juzBoxWidth,
      boxHeight,
    );

    final Path outerPath = Path()
      ..moveTo(outer.right, outer.bottom)
      ..lineTo(outer.right, surahRect.bottom)
      ..lineTo(surahRect.right, surahRect.bottom)
      ..moveTo(surahRect.left, surahRect.bottom)
      ..lineTo(juzRect.right, outer.top)
      ..moveTo(juzRect.left, outer.top)
      ..lineTo(outer.left, outer.top)
      ..lineTo(outer.left, outer.bottom)
      ..lineTo(outer.right, outer.bottom);

    canvas.drawPath(outerPath, outerPaint);

    final double bridgeY = outer.top;
    canvas.drawLine(
      Offset(surahRect.left, bridgeY),
      Offset(juzRect.right, bridgeY),
      outerPaint,
    );
    final double midBridgeX = (surahRect.left + juzRect.right) * 0.5;
    _drawRosetteDiamond(
      canvas: canvas,
      center: Offset(midBridgeX, bridgeY),
      radius: 3.8,
      strokeColor: outerColor,
      fillColor: paperColor,
    );

    canvas.drawRect(mid, midPaint);
    canvas.drawRect(inner, innerPaint);

    final double barW = (inner.width * 0.42) * wirdRatio.clamp(0.0, 1.0);
    if (barW > 1) {
      canvas.drawLine(
        Offset(inner.center.dx - barW * 0.5, inner.bottom),
        Offset(inner.center.dx + barW * 0.5, inner.bottom),
        Paint()
          ..color = accentColor
          ..strokeWidth = 2.0,
      );
    }

    _drawCornerOrnament(
      canvas: canvas,
      corner: outer.topLeft,
      dirX: 1,
      dirY: 1,
      outerColor: outerColor,
      innerColor: innerColor,
      fillColor: paperColor,
    );
    _drawCornerOrnament(
      canvas: canvas,
      corner: outer.topRight,
      dirX: -1,
      dirY: 1,
      outerColor: outerColor,
      innerColor: innerColor,
      fillColor: paperColor,
    );
    _drawCornerOrnament(
      canvas: canvas,
      corner: outer.bottomLeft,
      dirX: 1,
      dirY: -1,
      outerColor: outerColor,
      innerColor: innerColor,
      fillColor: paperColor,
    );
    _drawCornerOrnament(
      canvas: canvas,
      corner: outer.bottomRight,
      dirX: -1,
      dirY: -1,
      outerColor: outerColor,
      innerColor: innerColor,
      fillColor: paperColor,
    );

    _drawRosetteDiamond(
      canvas: canvas,
      center: Offset(outer.left, outer.center.dy),
      radius: 4.5,
      strokeColor: outerColor,
      fillColor: paperColor,
    );
    _drawRosetteDiamond(
      canvas: canvas,
      center: Offset(outer.right, outer.center.dy),
      radius: 4.5,
      strokeColor: outerColor,
      fillColor: paperColor,
    );
    _drawRosetteDiamond(
      canvas: canvas,
      center: Offset(outer.center.dx, outer.bottom),
      radius: 4.5,
      strokeColor: outerColor,
      fillColor: paperColor,
    );

    _drawQuranHeaderBox(
      canvas: canvas,
      rect: surahRect,
      text: surahLabel,
    );
    _drawQuranHeaderBox(
      canvas: canvas,
      rect: juzRect,
      text: juzLabel,
    );
  }

  void _drawCornerOrnament({
    required Canvas canvas,
    required Offset corner,
    required double dirX,
    required double dirY,
    required Color outerColor,
    required Color innerColor,
    required Color fillColor,
  }) {
    const double arm = 13.0;
    final Path arch = Path()
      ..moveTo(corner.dx + dirX * arm, corner.dy)
      ..quadraticBezierTo(
        corner.dx + dirX * 4.0,
        corner.dy + dirY * 4.0,
        corner.dx,
        corner.dy + dirY * arm,
      );

    canvas.drawPath(
      arch,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final Offset gemCenter =
        Offset(corner.dx + dirX * 4.5, corner.dy + dirY * 4.5);
    _drawRosetteDiamond(
      canvas: canvas,
      center: gemCenter,
      radius: 3.0,
      strokeColor: innerColor,
      fillColor: fillColor,
    );
  }

  void _drawRosetteDiamond({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color strokeColor,
    required Color fillColor,
  }) {
    final Path p = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();

    canvas.drawPath(
      p,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      p,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25,
    );
  }

  void _drawQuranHeaderBox({
    required Canvas canvas,
    required Rect rect,
    required String text,
  }) {
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = paperColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    canvas.drawRRect(
      rrect.deflate(2.2),
      Paint()
        ..color = innerColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: inkColor,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: rect.width - 10);

    tp.paint(
      canvas,
      Offset(
        rect.center.dx - tp.width * 0.5,
        rect.center.dy - tp.height * 0.5,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _AuthenticQuranicFramePainter oldDelegate) =>
      oldDelegate.outerColor != outerColor ||
      oldDelegate.innerColor != innerColor ||
      oldDelegate.paperColor != paperColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.inkColor != inkColor ||
      oldDelegate.surahLabel != surahLabel ||
      oldDelegate.juzLabel != juzLabel ||
      oldDelegate.wirdRatio != wirdRatio;
}

class _FloatingBottomBar extends StatelessWidget {
  final PageThemePalette palette;
  final int currentPage;
  final bool hasSecondaryBookmark;
  final int? secondaryBookmarkPage;
  final int wirdRead;
  final int wirdGoal;
  final ValueChanged<int> onJumpPage;
  final VoidCallback onOpenSurahs;
  final VoidCallback onOpenJuz;
  final VoidCallback onOpenWird;
  final VoidCallback onToggleSecondaryBookmark;
  final VoidCallback? onJumpSecondaryBookmark;
  final VoidCallback onOpenScale;
  final VoidCallback onOpenTheme;

  const _FloatingBottomBar({
    required this.palette,
    required this.currentPage,
    required this.hasSecondaryBookmark,
    required this.secondaryBookmarkPage,
    required this.wirdRead,
    required this.wirdGoal,
    required this.onJumpPage,
    required this.onOpenSurahs,
    required this.onOpenJuz,
    required this.onOpenWird,
    required this.onToggleSecondaryBookmark,
    required this.onJumpSecondaryBookmark,
    required this.onOpenScale,
    required this.onOpenTheme,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio =
        wirdGoal > 0 ? (wirdRead / wirdGoal).clamp(0.0, 1.0) : 0.0;
    final int khatmaPct = ((currentPage / 604) * 100).round();

    return Material(
      elevation: 6,
      color: palette.background.withValues(alpha: 0.98),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.ink.withValues(alpha: 0.16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'ص $currentPage • الختمة $khatmaPct% • الورد $wirdRead/$wirdGoal',
                  style: TextStyle(
                      fontSize: 11.5, color: palette.ink.withValues(alpha: 0.88)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      min: 1,
                      max: 604,
                      value: currentPage.toDouble().clamp(1, 604),
                      activeColor: palette.accent,
                      onChanged: (v) => onJumpPage(v.round()),
                    ),
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: palette.ink.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
              ),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _BarBtn(
                    icon: Icons.menu_book_outlined,
                    label: 'الفهرس',
                    color: palette.ink,
                    onTap: onOpenSurahs,
                  ),
                  _BarBtn(
                    icon: Icons.grid_view_outlined,
                    label: 'الأجزاء',
                    color: palette.ink,
                    onTap: onOpenJuz,
                  ),
                  _BarBtn(
                    icon: Icons.track_changes_outlined,
                    label: 'الورد',
                    color: palette.ink,
                    onTap: onOpenWird,
                  ),
                  _BarBtn(
                    icon: hasSecondaryBookmark
                        ? Icons.bookmark_added
                        : Icons.bookmark_add_outlined,
                    label: 'علامة ٢',
                    color: hasSecondaryBookmark ? palette.accent : palette.ink,
                    onTap: onToggleSecondaryBookmark,
                  ),
                  if (onJumpSecondaryBookmark != null &&
                      secondaryBookmarkPage != null)
                    _BarBtn(
                      icon: Icons.my_location,
                      label: 'ص $secondaryBookmarkPage',
                      color: palette.accent,
                      onTap: onJumpSecondaryBookmark!,
                    ),
                  _BarBtn(
                    icon: Icons.zoom_in_outlined,
                    label: 'الحجم',
                    color: palette.ink,
                    onTap: onOpenScale,
                  ),
                  _BarBtn(
                    icon: Icons.palette_outlined,
                    label: 'الثيم',
                    color: palette.ink,
                    onTap: onOpenTheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BarBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10.5, color: color)),
          ],
        ),
      ),
    );
  }
}

class AthkarTab extends StatefulWidget {
  const AthkarTab({super.key});

  @override
  State<AthkarTab> createState() => _AthkarTabState();
}

class _AthkarTabState extends State<AthkarTab> {
  int _selectedCategoryIndex = 0;
  int _itemIndexInCategory = 0;
  bool _vibrationEnabled = true;
  final Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = _suggestCategoryIndexByHour();
    _loadPrefsAndCounts();
  }

  int _suggestCategoryIndexByHour() {
    final int hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return 0;
    if (hour >= 15 && hour < 21) return 1;
    return 0;
  }

  Future<void> _loadPrefsAndCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = _todayKey();
    final String savedDate = prefs.getString('athkar_date') ?? today;
    final bool vib = prefs.getBool('athkar_vibration') ?? true;
    if (savedDate != today) {
      await prefs.setString('athkar_date', today);
    }
    if (!mounted) return;
    setState(() {
      _vibrationEnabled = vib;
      for (final item in kThikrItems) {
        _counts[item.id] =
            savedDate == today ? (prefs.getInt('thikr_${item.id}') ?? 0) : 0;
      }
    });
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveCount(String id, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('athkar_date', _todayKey());
    await prefs.setInt('thikr_$id', value);
  }

  Future<void> _toggleVibration() async {
    final next = !_vibrationEnabled;
    setState(() => _vibrationEnabled = next);
    if (next) {
      HapticFeedback.selectionClick();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('athkar_vibration', next);
  }

  void _increment(ThikrItem item) {
    final int current = _counts[item.id] ?? 0;
    if (current >= item.targetCount) return;
    final int next = current + 1;
    final bool completedNow = next >= item.targetCount;
    setState(() => _counts[item.id] = next);
    _saveCount(item.id, next);

    if (_vibrationEnabled) {
      if (completedNow) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _resetCurrentItem(ThikrItem item) {
    setState(() => _counts[item.id] = 0);
    _saveCount(item.id, 0);
    if (_vibrationEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentCategory = kThikrCategories[_selectedCategoryIndex];
    final List<ThikrItem> items =
        kThikrItems.where((item) => item.category == currentCategory).toList();
    final int safeIndex =
        items.isEmpty ? 0 : _itemIndexInCategory.clamp(0, items.length - 1);
    final ThikrItem item = items[safeIndex];
    final int count = _counts[item.id] ?? 0;
    final bool done = count >= item.targetCount;
    final double ringProgress =
        item.targetCount > 0 ? (count / item.targetCount).clamp(0.0, 1.0) : 0.0;

    const Color bg = Color(0xFFF6F1E7);
    const Color card = Color(0xFFFFFCF6);
    const Color primary = Color(0xFF235347);
    const Color ringTrack = Color(0xFFDCE7E2);
    const Color ink = Color(0xFF1E2421);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          currentCategory,
          style: const TextStyle(
              color: ink, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Center(
              child: Text(
                'الذكر ${safeIndex + 1} من ${items.length}',
                style: TextStyle(
                    color: ink.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: kThikrCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final bool selected = index == _selectedCategoryIndex;
                return ChoiceChip(
                  label: Text(kThikrCategories[index]),
                  selected: selected,
                  selectedColor: primary.withValues(alpha: 0.18),
                  labelStyle: TextStyle(
                    color: selected ? primary : ink,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryIndex = index;
                      _itemIndexInCategory = 0;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: done ? null : () => _increment(item),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ink.withValues(alpha: 0.10)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 17,
                              height: 1.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 172,
                      height: 172,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 11,
                              color: ringTrack,
                            ),
                          ),
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: ringProgress,
                              strokeWidth: 11,
                              backgroundColor: Colors.transparent,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(primary),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$count',
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$count/${item.targetCount}',
                                style: TextStyle(
                                  color: ink.withValues(alpha: 0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'الهدف: ${item.targetCount}',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      done ? 'تم إكمال الذكر بنجاح' : 'اضغط في أي مكان للتسبيح',
                      style: TextStyle(
                        color: done ? primary : ink.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.outlined(
                          tooltip: 'الذكر السابق',
                          onPressed: safeIndex > 0
                              ? () => setState(
                                  () => _itemIndexInCategory = safeIndex - 1)
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: ink.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: _toggleVibration,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _vibrationEnabled
                                          ? Icons.vibration
                                          : Icons.phone_android,
                                      color: _vibrationEnabled
                                          ? primary
                                          : ink.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'اهتزاز',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: _vibrationEnabled
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _vibrationEnabled
                                            ? primary
                                            : ink.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 22),
                              InkWell(
                                onTap: () => _resetCurrentItem(item),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh,
                                        color: ink.withValues(alpha: 0.75)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'تصفير',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: ink.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.outlined(
                          tooltip: 'الذكر التالي',
                          onPressed: safeIndex < items.length - 1
                              ? () => setState(
                                  () => _itemIndexInCategory = safeIndex + 1)
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
