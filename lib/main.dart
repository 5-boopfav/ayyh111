import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BahmadMushafApp());
}

class BahmadMushafApp extends StatelessWidget {
  const BahmadMushafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'مصحف بحمد',
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MushafReaderScreen(),
      ),
    );
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
  final double shade; // 0.0 فاتح ناعم .. 1.0 أغمق وأقوى

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
  final Color backFaceTint;

  const PageThemePalette({
    required this.background,
    required this.paper,
    required this.ink,
    required this.accent,
    required this.outerFrame,
    required this.innerFrame,
    required this.backFaceTint,
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
    final Color outerFrame = HSLColor.fromAHSL(1.0, h, 0.46, 0.36).toColor();
    final Color innerFrame = HSLColor.fromAHSL(1.0, h, 0.38, 0.52).toColor();
    final Color backFaceTint = HSLColor.fromAHSL(
            1.0, h, 0.35, (paperLightness - 0.06).clamp(0.55, 0.92))
        .toColor();

    return PageThemePalette(
      background: background,
      paper: paper,
      ink: ink,
      accent: accent,
      outerFrame: outerFrame,
      innerFrame: innerFrame,
      backFaceTint: backFaceTint,
    );
  }
}

class MushafReaderScreen extends StatefulWidget {
  const MushafReaderScreen({super.key});

  @override
  State<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends State<MushafReaderScreen>
    with SingleTickerProviderStateMixin {
  static const int totalPages = 604;

  // لون الحبل الأحمر أخف وأهدأ (لقطة أ)
  static const Color _softBookmarkRed = Color(0xFFC94A4A);
  static const Color _softBookmarkRedLight = Color(0xFFD96B6B);
  static const Color _softBookmarkRedDark = Color(0xFF9E3434);

  int _currentPage = 1;
  int? _bookmarkedPage;
  double _ribbonDropRatio = 0.34;
  int _dailyWirdGoalPages = 20;
  int _wirdReadToday = 0;
  String _lastWirdDate = '';
  double _pageScale = 1.0;

  String _selectedThemeId = 'classic_cream';
  double _themeHue = 38.0;
  double _themeShade = 0.14;
  bool _showBottomBar = false;

  int? _activePointerId;
  double _startX = 0.0;
  double _startY = 0.0;
  double _lastX = 0.0;
  int _lastTimeMs = 0;
  double _vx = 0.0;
  double _dyRatio = 0.5;
  double _touchXRatio = 0.5;
  double _verticalTravelRatio = 0.0;
  bool _hasMovedBeyondTap = false;

  int _dragDir = 0;
  double _progress = 0.0;
  bool _settling = false;
  bool _commit = false;

  late final AnimationController _settleCtrl;
  Animation<double>? _settleAnim;

  final Map<int, ImageProvider> _imageCache = {};
  int _lastPrecachedPage = -1;

  @override
  void initState() {
    super.initState();
    _settleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )
      ..addListener(() {
        if (_settleAnim != null) {
          setState(() {
            _progress = _settleAnim!.value.clamp(0.0, 1.0);
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final int finishedDir = _dragDir;
          final bool didCommit = _commit;
          setState(() {
            if (didCommit && finishedDir != 0) {
              final int nextPage =
                  (_currentPage - finishedDir).clamp(1, totalPages);
              if (nextPage != _currentPage) {
                _currentPage = nextPage;
                _advanceWirdOnce();
              }
            }
            _activePointerId = null;
            _dragDir = 0;
            _progress = 0.0;
            _verticalTravelRatio = 0.0;
            _hasMovedBeyondTap = false;
            _settling = false;
            _commit = false;
          });
          _saveState();
          _precacheNeighbors();
        }
      });

    _loadState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheNeighbors();
  }

  ImageProvider _providerForPage(int page) {
    final int clamped = page.clamp(1, totalPages);
    return _imageCache.putIfAbsent(
      clamped,
      () => AssetImage('assets/images/quran/$clamped.png'),
    );
  }

  void _precacheNeighbors() {
    if (!mounted || _lastPrecachedPage == _currentPage) return;
    _lastPrecachedPage = _currentPage;
    final candidates = [
      _currentPage - 1,
      _currentPage,
      _currentPage + 1,
      _currentPage + 2,
    ];
    for (final p in candidates) {
      if (p >= 1 && p <= totalPages) {
        precacheImage(_providerForPage(p), context).catchError((_) {});
      }
    }
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
    });
    _precacheNeighbors();
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
    await prefs.setDouble('ribbon_drop_ratio', _ribbonDropRatio);
    await prefs.setDouble('page_scale', _pageScale);
    await prefs.setInt('daily_wird_goal', _dailyWirdGoalPages);
    await prefs.setString('theme_preset_id', _selectedThemeId);
    await prefs.setDouble('theme_hue', _themeHue);
    await prefs.setDouble('theme_shade', _themeShade);
    await prefs.setBool('show_bottom_bar', _showBottomBar);
    await prefs.setString('last_wird_date', _lastWirdDate);
    await prefs.setInt('wird_read_today', _wirdReadToday);
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

  void _jumpToPage(int page) {
    if (_settling) return;
    if (_settleCtrl.isAnimating) {
      _settleCtrl.stop();
    }
    setState(() {
      _activePointerId = null;
      _dragDir = 0;
      _progress = 0.0;
      _verticalTravelRatio = 0.0;
      _hasMovedBeyondTap = false;
      _settling = false;
      _commit = false;
      _currentPage = page.clamp(1, totalPages);
    });
    _saveState();
    _precacheNeighbors();
  }

  void _toggleBookmark() {
    setState(() {
      _bookmarkedPage = _bookmarkedPage == _currentPage ? null : _currentPage;
    });
    _saveState();
  }

  void _handlePointerDown(PointerDownEvent event, double width, double height) {
    if (_settling || _activePointerId != null || width <= 0) return;

    final double x = event.localPosition.dx;
    final double y = event.localPosition.dy;
    final double edgeZone = width * 0.30;

    int initialDir = 0;
    if (x <= edgeZone && _currentPage < totalPages) {
      initialDir = -1;
    } else if (x >= (width - edgeZone) && _currentPage > 1) {
      initialDir = 1;
    }

    setState(() {
      _activePointerId = event.pointer;
      _startX = x;
      _startY = y;
      _lastX = x;
      _lastTimeMs = DateTime.now().millisecondsSinceEpoch;
      _vx = 0.0;
      _dyRatio = height > 0 ? (y / height).clamp(0.06, 0.94) : 0.5;
      _touchXRatio = (x / width).clamp(0.0, 1.0);
      _verticalTravelRatio = 0.0;
      _hasMovedBeyondTap = false;
      _dragDir = initialDir;
      _progress = 0.0;
    });
  }

  void _handlePointerMove(PointerMoveEvent event, double width, double height) {
    if (_settling || width <= 0) return;
    if (_activePointerId == null || event.pointer != _activePointerId) return;

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int dt = now - _lastTimeMs;
    if (dt > 0) {
      _vx = ((event.localPosition.dx - _lastX) * 1000.0) / dt;
    }
    _lastX = event.localPosition.dx;
    _lastTimeMs = now;

    final double x = event.localPosition.dx;
    final double y = event.localPosition.dy;
    final double dx = x - _startX;
    final double dy = y - _startY;

    if (dx.abs() > 10.0 || dy.abs() > 10.0) {
      _hasMovedBeyondTap = true;
      if (_showBottomBar) {
        _showBottomBar = false;
      }
    }

    final double verticalDeltaRatio = height > 0 ? (dy / height) : 0.0;
    final double baseRatioY = height > 0 ? (y / height) : 0.5;
    final double ratioY =
        (baseRatioY + verticalDeltaRatio * 0.35).clamp(0.06, 0.94);
    final double ratioX = (x / width).clamp(0.0, 1.0);

    if (_dragDir == 0) {
      setState(() {
        _dyRatio = ratioY;
        _touchXRatio = ratioX;
        _verticalTravelRatio = verticalDeltaRatio.clamp(-0.6, 0.6);
      });
      return;
    }

    final double signedTravel = _dragDir < 0 ? dx : -dx;
    final double raw = (signedTravel / (width * 0.44)).clamp(0.0, 1.0);

    setState(() {
      _dyRatio = ratioY;
      _touchXRatio = ratioX;
      _verticalTravelRatio = verticalDeltaRatio.clamp(-0.6, 0.6);
      _progress = raw;
    });
  }

  void _handlePointerEnd(int pointer) {
    if (_activePointerId == null || pointer != _activePointerId) return;
    if (_settling) return;

    if (!_hasMovedBeyondTap && _progress <= 0.001) {
      setState(() {
        _activePointerId = null;
        _dragDir = 0;
        _progress = 0.0;
        _verticalTravelRatio = 0.0;
        _showBottomBar = !_showBottomBar;
      });
      _saveState();
      return;
    }

    if (_dragDir == 0 || _progress <= 0.001) {
      setState(() {
        _activePointerId = null;
        _dragDir = 0;
        _progress = 0.0;
        _verticalTravelRatio = 0.0;
        _hasMovedBeyondTap = false;
      });
      return;
    }

    final double directionalSpeed = _dragDir < 0 ? _vx : -_vx;
    final bool shouldCommit = _progress >= 0.32 || directionalSpeed > 260;
    _runSettle(shouldCommit);
  }

  void _runSettle(bool commit) {
    _commit = commit;
    _settling = true;
    _settleAnim = Tween<double>(
      begin: _progress,
      end: commit ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(parent: _settleCtrl, curve: Curves.easeOutCubic),
    );
    _settleCtrl.forward(from: 0.0);
  }

  SurahInfo get _currentSurah {
    SurahInfo res = kSurahs.first;
    for (final s in kSurahs) {
      if (s.startPage <= _currentPage) {
        res = s;
      } else {
        break;
      }
    }
    return res;
  }

  JuzInfo get _currentJuz {
    JuzInfo res = kJuzList.first;
    for (final j in kJuzList) {
      if (j.startPage <= _currentPage) {
        res = j;
      } else {
        break;
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final PageThemePalette palette = PageThemePalette.fromHueAndShade(
      hue: _themeHue,
      shade: _themeShade,
    );

    final bool isTurning = _dragDir != 0 && _progress > 0.001;
    final int underPage =
        isTurning ? (_currentPage - _dragDir).clamp(1, totalPages) : _currentPage;
    final bool hasBookmarkOnCurrent = _bookmarkedPage == _currentPage;

    // في RTL: مربع الجزء يقع جهة اليسار في الأعلى، لذا "يمين مربع الجزء" يكون بإزاحة يمينية من الحافة اليسرى
    const double juzBoxWidth = 114.0;
    const double bookmarkRightOfJuzLeft = 16.0 + juzBoxWidth + 6.0;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => _handlePointerDown(e, width, height),
              onPointerMove: (e) => _handlePointerMove(e, width, height),
              onPointerUp: (e) => _handlePointerEnd(e.pointer),
              onPointerCancel: (e) => _handlePointerEnd(e.pointer),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isTurning)
                    _NextPageUnderlay(
                      imageProvider: _providerForPage(underPage),
                      pageNumber: underPage,
                      surahName: _surahForPage(underPage).name,
                      juzTitle: _juzForPage(underPage).title,
                      palette: palette,
                      scale: _pageScale,
                      progress: _progress,
                    ),
                  _RealisticPaperCurlEngine(
                    currentProvider: _providerForPage(_currentPage),
                    backProvider: _providerForPage(underPage),
                    currentPage: _currentPage,
                    backPage: underPage,
                    currentSurahName: _currentSurah.name,
                    currentJuzTitle: _currentJuz.title,
                    backSurahName: _surahForPage(underPage).name,
                    backJuzTitle: _juzForPage(underPage).title,
                    width: width,
                    height: height,
                    direction: isTurning ? _dragDir : 0,
                    progress: isTurning ? _progress : 0.0,
                    dyRatio: _dyRatio,
                    touchXRatio: _touchXRatio,
                    verticalTravelRatio: _verticalTravelRatio,
                    palette: palette,
                    scale: _pageScale,
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
                  // خيار العلامة محاذي إلى يمين مربع الجزء مباشرة
                  Positioned(
                    top: 32,
                    left: bookmarkRightOfJuzLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TopQuickChip(
                          icon: Icons.bookmark,
                          color: hasBookmarkOnCurrent
                              ? _softBookmarkRed
                              : palette.ink.withValues(alpha: 0.78),
                          bgColor: palette.paper.withValues(alpha: 0.94),
                          borderColor: palette.outerFrame,
                          tooltip: hasBookmarkOnCurrent
                              ? 'إزالة الحبل الأحمر'
                              : 'إنزال الحبل الأحمر',
                          onTap: _toggleBookmark,
                        ),
                        if (_bookmarkedPage != null && !hasBookmarkOnCurrent) ...[
                          const SizedBox(width: 4),
                          _TopQuickChip(
                            icon: Icons.turned_in,
                            color: _softBookmarkRed,
                            bgColor: palette.paper.withValues(alpha: 0.94),
                            borderColor: palette.outerFrame,
                            tooltip:
                                'الانتقال إلى الحبل الأحمر (ص $_bookmarkedPage)',
                            onTap: () => _jumpToPage(_bookmarkedPage!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // الشريط السفلي عائم فوق الصفحة دون رفعها أو تغيير موضعها (نقطة 2)
                  if (_showBottomBar)
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: _FloatingBottomBar(
                        palette: palette,
                        wirdRead: _wirdReadToday,
                        wirdGoal: _dailyWirdGoalPages,
                        onOpenSurahs: () => _openSurahs(palette),
                        onOpenJuz: () => _openJuz(palette),
                        onOpenWird: _openWird,
                        onOpenScale: () => _openScale(palette),
                        onOpenTheme: () => _openThemeCustomizer(palette),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
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
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: const Text('إعداد الورد اليومي'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('الهدف اليومي: $tempGoal صفحة'),
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

  @override
  void dispose() {
    _settleCtrl.dispose();
    super.dispose();
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
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: borderColor.withValues(alpha: 0.7)),
        ),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 16, color: color),
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
          _MushafReaderScreenState._softBookmarkRedDark,
          _MushafReaderScreenState._softBookmarkRedLight,
          _MushafReaderScreenState._softBookmarkRed,
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
      Paint()..color = _MushafReaderScreenState._softBookmarkRedDark,
    );
  }

  @override
  bool shouldRepaint(covariant _RedCordPainter oldDelegate) =>
      oldDelegate.cordLength != cordLength;
}

class _NextPageUnderlay extends StatelessWidget {
  final ImageProvider imageProvider;
  final int pageNumber;
  final String surahName;
  final String juzTitle;
  final PageThemePalette palette;
  final double scale;
  final double progress;

  const _NextPageUnderlay({
    required this.imageProvider,
    required this.pageNumber,
    required this.surahName,
    required this.juzTitle,
    required this.palette,
    required this.scale,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double dim = (0.12 * (1.0 - progress)).clamp(0.0, 0.14);
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: MushafSingleSheet(
            imageProvider: imageProvider,
            pageNumber: pageNumber,
            surahName: surahName,
            juzTitle: juzTitle,
            palette: palette,
            scale: scale,
          ),
        ),
        IgnorePointer(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: dim),
          ),
        ),
      ],
    );
  }
}

/// تأثير قلب الصفحة (الضوابط الأربع) + حركة الورقة/الصورة نفسها بسلاسة (نقطة 1)
class _RealisticPaperCurlEngine extends StatelessWidget {
  final ImageProvider currentProvider;
  final ImageProvider backProvider;
  final int currentPage;
  final int backPage;
  final String currentSurahName;
  final String currentJuzTitle;
  final String backSurahName;
  final String backJuzTitle;
  final double width;
  final double height;
  final int direction;
  final double progress;
  final double dyRatio;
  final double touchXRatio;
  final double verticalTravelRatio;
  final PageThemePalette palette;
  final double scale;

  const _RealisticPaperCurlEngine({
    required this.currentProvider,
    required this.backProvider,
    required this.currentPage,
    required this.backPage,
    required this.currentSurahName,
    required this.currentJuzTitle,
    required this.backSurahName,
    required this.backJuzTitle,
    required this.width,
    required this.height,
    required this.direction,
    required this.progress,
    required this.dyRatio,
    required this.touchXRatio,
    required this.verticalTravelRatio,
    required this.palette,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == 0 || progress <= 0.0 || width <= 0 || height <= 0) {
      return RepaintBoundary(
        child: MushafSingleSheet(
          imageProvider: currentProvider,
          pageNumber: currentPage,
          surahName: currentSurahName,
          juzTitle: currentJuzTitle,
          palette: palette,
          scale: scale,
        ),
      );
    }

    final _CurlMeshModel model = _CurlMeshModel.solve(
      size: Size(width, height),
      direction: direction,
      progress: progress,
      dyRatio: dyRatio,
      touchXRatio: touchXRatio,
      verticalTravelRatio: verticalTravelRatio,
    );

    final double midArch = math.sin(progress * math.pi);

    // حركة الصورة/الورقة الأمامية نفسها مع الانحناء والسحب
    final double frontShiftX =
        -direction * (width * 0.05 * midArch + width * 0.065 * progress);
    final double frontShiftY = verticalTravelRatio * height * 0.032 * midArch;
    final Matrix4 frontLeafTransform = Matrix4.identity()
      ..translate(frontShiftX, frontShiftY, 0.0)
      ..rotateZ(direction * 0.016 * midArch);

    // حركة وانحناء الوجه الخلفي للورقة نفسها
    final double liftAngleY = -direction * (0.24 * midArch);
    final double tiltAngleX =
        ((dyRatio - 0.5) * 0.12 + verticalTravelRatio * 0.14) * midArch;
    final double flapShiftX = -direction * (model.curlDepth * 0.22 * midArch);
    final Matrix4 backPerspective = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..translate(flapShiftX, frontShiftY * 0.8, 0.0)
      ..rotateY(liftAngleY)
      ..rotateX(tiltAngleX);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(width, height),
              painter: _UnderPageCastShadowPainter(model: model),
            ),
          ),
        ),
        ClipPath(
          clipper: _FrontBodyClipper(model: model),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: frontLeafTransform,
                child: RepaintBoundary(
                  child: MushafSingleSheet(
                    imageProvider: currentProvider,
                    pageNumber: currentPage,
                    surahName: currentSurahName,
                    juzTitle: currentJuzTitle,
                    palette: palette,
                    scale: scale,
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(
                  size: Size(width, height),
                  painter: _FrontSurfaceLightingPainter(model: model),
                ),
              ),
            ],
          ),
        ),
        ClipPath(
          clipper: _CurledBackClipper(model: model),
          child: Transform(
            alignment:
                direction < 0 ? Alignment.centerLeft : Alignment.centerRight,
            transform: backPerspective,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                  child: Opacity(
                    opacity: 0.44,
                    child: RepaintBoundary(
                      child: MushafSingleSheet(
                        imageProvider: backProvider,
                        pageNumber: backPage,
                        surahName: backSurahName,
                        juzTitle: backJuzTitle,
                        palette: palette,
                        scale: scale,
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(width, height),
                    painter: _BackFaceShadingPainter(
                      model: model,
                      paperTint: palette.backFaceTint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CurlMeshModel {
  final Size size;
  final int direction;
  final double progress;
  final double dyRatio;
  final double touchXRatio;
  final double verticalTravelRatio;

  final Offset creaseTop;
  final Offset creaseMid;
  final Offset creaseBottom;

  final Offset edgeTop;
  final Offset edgeMid;
  final Offset edgeBottom;

  final double curlDepth;
  final double bowMagnitude;

  const _CurlMeshModel({
    required this.size,
    required this.direction,
    required this.progress,
    required this.dyRatio,
    required this.touchXRatio,
    required this.verticalTravelRatio,
    required this.creaseTop,
    required this.creaseMid,
    required this.creaseBottom,
    required this.edgeTop,
    required this.edgeMid,
    required this.edgeBottom,
    required this.curlDepth,
    required this.bowMagnitude,
  });

  factory _CurlMeshModel.solve({
    required Size size,
    required int direction,
    required double progress,
    required double dyRatio,
    required double touchXRatio,
    required double verticalTravelRatio,
  }) {
    final double w = size.width;
    final double h = size.height;
    final double p = progress.clamp(0.0, 1.0);

    // 1. الانحناء والتقوّس: يبدأ مبكراً ويلين عند الاكتمال
    final double bell = math.sin(p * math.pi).clamp(0.0, 1.0);
    final double earlyBowFactor = math.pow(bell, 0.75).toDouble();
    final double bow = w * 0.115 * earlyBowFactor;

    final double flapDepth =
        (w * (0.12 + 0.24 * math.sin(p * math.pi * 0.78))).clamp(16.0, w * 0.38);

    // 2. ميل الطي: مرتبط بحركة الإصبع ومتصل بالمنتصف
    final double verticalBias = (dyRatio - 0.5) * 2.0;
    final double motionTilt = (verticalTravelRatio * 1.6).clamp(-0.65, 0.65);
    final double horizontalBias = (touchXRatio - 0.5).abs();
    final double diagonalSkew = (verticalBias * 0.65 + motionTilt) *
        w *
        (0.22 + 0.06 * horizontalBias) *
        p;

    final double blendedRatioY = ui.lerpDouble(0.5, dyRatio, 0.68)!;
    final double fy = (h * blendedRatioY).clamp(h * 0.16, h * 0.84);

    if (direction < 0) {
      final double baseX = w * (0.04 + 0.88 * p);
      final double topX = (baseX - diagonalSkew).clamp(0.0, w);
      final double botX = (baseX + diagonalSkew).clamp(0.0, w);
      final double midX = ((topX + botX) * 0.5 + bow).clamp(0.0, w);

      final double eTopX = (topX - flapDepth).clamp(-w * 0.10, w);
      final double eBotX = (botX - flapDepth).clamp(-w * 0.10, w);
      final double eMidX =
          ((eTopX + eBotX) * 0.5 + bow * 1.28).clamp(-w * 0.10, w);

      return _CurlMeshModel(
        size: size,
        direction: direction,
        progress: p,
        dyRatio: dyRatio,
        touchXRatio: touchXRatio,
        verticalTravelRatio: verticalTravelRatio,
        creaseTop: Offset(topX, 0),
        creaseMid: Offset(midX, fy),
        creaseBottom: Offset(botX, h),
        edgeTop: Offset(eTopX, 0),
        edgeMid: Offset(eMidX, fy),
        edgeBottom: Offset(eBotX, h),
        curlDepth: flapDepth,
        bowMagnitude: bow,
      );
    } else {
      final double baseX = w * (0.96 - 0.88 * p);
      final double topX = (baseX + diagonalSkew).clamp(0.0, w);
      final double botX = (baseX - diagonalSkew).clamp(0.0, w);
      final double midX = ((topX + botX) * 0.5 - bow).clamp(0.0, w);

      final double eTopX = (topX + flapDepth).clamp(0.0, w * 1.10);
      final double eBotX = (botX + flapDepth).clamp(0.0, w * 1.10);
      final double eMidX =
          ((eTopX + eBotX) * 0.5 - bow * 1.28).clamp(0.0, w * 1.10);

      return _CurlMeshModel(
        size: size,
        direction: direction,
        progress: p,
        dyRatio: dyRatio,
        touchXRatio: touchXRatio,
        verticalTravelRatio: verticalTravelRatio,
        creaseTop: Offset(topX, 0),
        creaseMid: Offset(midX, fy),
        creaseBottom: Offset(botX, h),
        edgeTop: Offset(eTopX, 0),
        edgeMid: Offset(eMidX, fy),
        edgeBottom: Offset(eBotX, h),
        curlDepth: flapDepth,
        bowMagnitude: bow,
      );
    }
  }

  Path creaseCurve() {
    return Path()
      ..moveTo(creaseTop.dx, creaseTop.dy)
      ..quadraticBezierTo(
          creaseMid.dx, creaseMid.dy, creaseBottom.dx, creaseBottom.dy);
  }

  Path outerEdgeCurve() {
    return Path()
      ..moveTo(edgeTop.dx, edgeTop.dy)
      ..quadraticBezierTo(edgeMid.dx, edgeMid.dy, edgeBottom.dx, edgeBottom.dy);
  }

  Path curledFlapRegion() {
    return Path()
      ..moveTo(creaseTop.dx, creaseTop.dy)
      ..quadraticBezierTo(
          creaseMid.dx, creaseMid.dy, creaseBottom.dx, creaseBottom.dy)
      ..lineTo(edgeBottom.dx, edgeBottom.dy)
      ..quadraticBezierTo(edgeMid.dx, edgeMid.dy, edgeTop.dx, edgeTop.dy)
      ..close();
  }

  Path frontBodyRegion() {
    final Path path = Path();
    if (direction < 0) {
      path.moveTo(creaseTop.dx, creaseTop.dy);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(creaseBottom.dx, creaseBottom.dy);
      path.quadraticBezierTo(
          creaseMid.dx, creaseMid.dy, creaseTop.dx, creaseTop.dy);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(creaseTop.dx, creaseTop.dy);
      path.quadraticBezierTo(
          creaseMid.dx, creaseMid.dy, creaseBottom.dx, creaseBottom.dy);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CurlMeshModel &&
        other.size == size &&
        other.direction == direction &&
        other.progress == progress &&
        other.dyRatio == dyRatio &&
        other.touchXRatio == touchXRatio &&
        other.verticalTravelRatio == verticalTravelRatio;
  }

  @override
  int get hashCode => Object.hash(
        size,
        direction,
        progress,
        dyRatio,
        touchXRatio,
        verticalTravelRatio,
      );
}

class _FrontBodyClipper extends CustomClipper<Path> {
  final _CurlMeshModel model;
  _FrontBodyClipper({required this.model});

  @override
  Path getClip(Size size) => model.frontBodyRegion();

  @override
  bool shouldReclip(covariant _FrontBodyClipper oldClipper) =>
      oldClipper.model != model;
}

class _CurledBackClipper extends CustomClipper<Path> {
  final _CurlMeshModel model;
  _CurledBackClipper({required this.model});

  @override
  Path getClip(Size size) => model.curledFlapRegion();

  @override
  bool shouldReclip(covariant _CurledBackClipper oldClipper) =>
      oldClipper.model != model;
}

class _UnderPageCastShadowPainter extends CustomPainter {
  final _CurlMeshModel model;

  _UnderPageCastShadowPainter({required this.model});

  @override
  void paint(Canvas canvas, Size size) {
    if (model.progress <= 0.0) return;

    final double lift = math.sin(model.progress * math.pi).clamp(0.0, 1.0);
    final double broadWidth = (16.0 + 26.0 * lift).clamp(8.0, 42.0);
    final double broadAlpha = (0.26 * lift).clamp(0.0, 0.30);

    canvas.drawPath(
      model.creaseCurve(),
      Paint()
        ..color = Colors.black.withValues(alpha: broadAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = broadWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, broadWidth * 0.72),
    );

    canvas.drawPath(
      model.creaseCurve(),
      Paint()
        ..color = Colors.black.withValues(alpha: (0.22 * lift).clamp(0.0, 0.25))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );

    canvas.drawPath(
      model.outerEdgeCurve(),
      Paint()
        ..color = Colors.black.withValues(alpha: (0.16 * lift).clamp(0.0, 0.18))
        ..style = PaintingStyle.stroke
        ..strokeWidth = broadWidth * 0.55
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, broadWidth * 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _UnderPageCastShadowPainter oldDelegate) =>
      oldDelegate.model != model;
}

class _FrontSurfaceLightingPainter extends CustomPainter {
  final _CurlMeshModel model;

  _FrontSurfaceLightingPainter({required this.model});

  @override
  void paint(Canvas canvas, Size size) {
    if (model.progress <= 0.0) return;

    final double archPeak = math.sin(model.progress * math.pi).clamp(0.0, 1.0);
    final double band = (24.0 + 28.0 * archPeak).clamp(14.0, 52.0);
    final double midX = model.creaseMid.dx;
    final double startX = (midX - band * model.direction).clamp(0.0, size.width);
    final double endX = (midX + band * model.direction).clamp(0.0, size.width);

    final Rect lightRect = Rect.fromLTRB(
      math.min(startX, endX),
      0,
      math.max(startX, endX),
      size.height,
    );

    final Paint highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(midX, model.creaseMid.dy),
        Offset(
          (midX - model.direction * band * 0.85).clamp(0.0, size.width),
          model.creaseMid.dy,
        ),
        [
          const Color(0xFFFFFDF8).withValues(alpha: 0.28 * archPeak),
          Colors.transparent,
        ],
      );

    canvas.drawRect(lightRect, highlightPaint);

    canvas.drawPath(
      model.creaseCurve(),
      Paint()
        ..color = const Color(0xFF4A3519).withValues(alpha: 0.22 * archPeak)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
    );
  }

  @override
  bool shouldRepaint(covariant _FrontSurfaceLightingPainter oldDelegate) =>
      oldDelegate.model != model;
}

class _BackFaceShadingPainter extends CustomPainter {
  final _CurlMeshModel model;
  final Color paperTint;

  _BackFaceShadingPainter({
    required this.model,
    required this.paperTint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (model.progress <= 0.0) return;

    final Path flapPath = model.curledFlapRegion();
    final Rect bounds = flapPath.getBounds();
    if (bounds.width <= 0 || bounds.height <= 0) return;

    final double archPeak = math.sin(model.progress * math.pi).clamp(0.0, 1.0);

    canvas.drawPath(
      flapPath,
      Paint()
        ..color = paperTint.withValues(alpha: 0.50)
        ..style = PaintingStyle.fill,
    );

    final Paint gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        model.creaseMid,
        model.edgeMid,
        [
          Colors.black.withValues(alpha: 0.26 * archPeak),
          const Color(0xFFFFFCF5).withValues(alpha: 0.20 * archPeak),
          Colors.black.withValues(alpha: 0.22 * archPeak),
        ],
        const [0.0, 0.45, 1.0],
      );

    canvas.drawPath(flapPath, gradientPaint);

    canvas.drawPath(
      model.outerEdgeCurve(),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22 * archPeak)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
    );
  }

  @override
  bool shouldRepaint(covariant _BackFaceShadingPainter oldDelegate) =>
      oldDelegate.model != model || oldDelegate.paperTint != paperTint;
}

/// نقاط (3) و(4) و(5) + توصيل خط الإطار بين مربع السورة ومربع الجزء
class MushafSingleSheet extends StatelessWidget {
  final ImageProvider? imageProvider;
  final int pageNumber;
  final String surahName;
  final String juzTitle;
  final PageThemePalette palette;
  final double scale;

  const MushafSingleSheet({
    super.key,
    this.imageProvider,
    required this.pageNumber,
    required this.surahName,
    required this.juzTitle,
    required this.palette,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final String assetPath = 'assets/images/quran/$pageNumber.png';
    final ImageProvider resolvedProvider =
        imageProvider ?? AssetImage(assetPath);

    return Transform.scale(
      scale: scale,
      child: Container(
        color: palette.paper,
        child: CustomPaint(
          painter: _ConnectedQuranFramePainter(
            outerColor: palette.outerFrame,
            innerColor: palette.innerFrame,
            paperColor: palette.paper,
            accentColor: palette.accent,
            inkColor: palette.ink,
            surahLabel: 'سورة $surahName',
            juzLabel: juzTitle,
          ),
          child: Padding(
            // يبدأ من تحت الإطار العلوي مباشرة ويمتد حتى الأسفل دون فراغات مزعجة
            padding: const EdgeInsets.fromLTRB(12, 34, 12, 12),
            child: SizedBox.expand(
              child: Image(
                image: resolvedProvider,
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
                          color: palette.outerFrame.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'صفحة المصحف رقم $pageNumber من 604',
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

class _ConnectedQuranFramePainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;
  final Color paperColor;
  final Color accentColor;
  final Color inkColor;
  final String surahLabel;
  final String juzLabel;

  _ConnectedQuranFramePainter({
    required this.outerColor,
    required this.innerColor,
    required this.paperColor,
    required this.accentColor,
    required this.inkColor,
    required this.surahLabel,
    required this.juzLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 40 || size.height <= 40) return;

    const double topInset = 22.0;
    final Rect outer = Rect.fromLTRB(6, topInset, size.width - 6, size.height - 6);
    final Rect inner = outer.deflate(5.5);

    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // في RTL: اليمين للأعلى هو مربع السورة (مثل سورة البقرة)، واليسار للأعلى هو مربع الجزء
    const double boxHeight = 28.0;
    const double surahBoxWidth = 122.0;
    const double juzBoxWidth = 114.0;

    final Rect surahRect = Rect.fromLTWH(
      outer.right - surahBoxWidth - 10,
      2,
      surahBoxWidth,
      boxHeight,
    );
    final Rect juzRect = Rect.fromLTWH(
      outer.left + 10,
      2,
      juzBoxWidth,
      boxHeight,
    );

    // رسم الإطار الخارجي موصولاً من الأسفل إلى الجانبين ويتصل بمربعي السورة والجزء مع توصيل الخط بينهما
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
    canvas.drawRect(inner, innerPaint);

    // توصيل خط إطار علوي واضح بين مربع السورة ومربع الجزء
    final double bridgeY = outer.top;
    canvas.drawLine(
      Offset(surahRect.left, bridgeY),
      Offset(juzRect.right, bridgeY),
      outerPaint,
    );

    // رسم مربع السورة ومربع الجزء بطابع قرآني متصل بالإطار العلوي
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
      rrect.deflate(2.5),
      Paint()
        ..color = innerColor.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: inkColor,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: rect.width - 12);

    tp.paint(
      canvas,
      Offset(
        rect.center.dx - tp.width * 0.5,
        rect.center.dy - tp.height * 0.5,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ConnectedQuranFramePainter oldDelegate) =>
      oldDelegate.outerColor != outerColor ||
      oldDelegate.innerColor != innerColor ||
      oldDelegate.paperColor != paperColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.inkColor != inkColor ||
      oldDelegate.surahLabel != surahLabel ||
      oldDelegate.juzLabel != juzLabel;
}

class _FloatingBottomBar extends StatelessWidget {
  final PageThemePalette palette;
  final int wirdRead;
  final int wirdGoal;
  final VoidCallback onOpenSurahs;
  final VoidCallback onOpenJuz;
  final VoidCallback onOpenWird;
  final VoidCallback onOpenScale;
  final VoidCallback onOpenTheme;

  const _FloatingBottomBar({
    required this.palette,
    required this.wirdRead,
    required this.wirdGoal,
    required this.onOpenSurahs,
    required this.onOpenJuz,
    required this.onOpenWird,
    required this.onOpenScale,
    required this.onOpenTheme,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio =
        wirdGoal > 0 ? (wirdRead / wirdGoal).clamp(0.0, 1.0) : 0.0;

    return Material(
      elevation: 6,
      color: palette.background.withValues(alpha: 0.97),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.ink.withValues(alpha: 0.14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'الورد اليومي: $wirdRead / $wirdGoal صفحة',
                  style: TextStyle(
                      fontSize: 12, color: palette.ink.withValues(alpha: 0.85)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: palette.ink.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BarBtn(
                    icon: Icons.menu_book_outlined,
                    label: 'الفهرس',
                    color: palette.ink,
                    onTap: onOpenSurahs),
                _BarBtn(
                    icon: Icons.grid_view_outlined,
                    label: 'الأجزاء',
                    color: palette.ink,
                    onTap: onOpenJuz),
                _BarBtn(
                    icon: Icons.track_changes_outlined,
                    label: 'الورد',
                    color: palette.ink,
                    onTap: onOpenWird),
                _BarBtn(
                    icon: Icons.zoom_in_outlined,
                    label: 'الحجم',
                    color: palette.ink,
                    onTap: onOpenScale),
                _BarBtn(
                    icon: Icons.palette_outlined,
                    label: 'الثيم',
                    color: palette.ink,
                    onTap: onOpenTheme),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
