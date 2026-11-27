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
      themeMode: ThemeMode.system,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MushafReaderScreen(),
      ),
    );
  }
}

// ============================================================================
// بيانات السور والأجزاء والورد اليومي
// ============================================================================

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

// ============================================================================
// الشاشة الرئيسية لقراءة المصحف
// ============================================================================

class MushafReaderScreen extends StatefulWidget {
  const MushafReaderScreen({super.key});

  @override
  State<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends State<MushafReaderScreen>
    with SingleTickerProviderStateMixin {
  static const int totalPages = 604;

  int _currentPage = 1;
  int? _bookmarkedPage;
  int _dailyWirdGoalPages = 20;
  int _wirdReadToday = 0;
  String _lastWirdDate = '';
  bool _nightMode = false;
  double _pageScale = 1.0;

  int _dragDirection = 0;
  double _dragProgress = 0.0;
  double _pointerDyRatio = 0.5;
  bool _isAnimatingCommit = false;

  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;
  bool _commitTargetReached = false;

  @override
  void initState() {
    super.initState();
    _settleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )
      ..addListener(_onSettleTick)
      ..addStatusListener(_onSettleStatus);

    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayDateKey();
    final savedDate = prefs.getString('last_wird_date') ?? todayKey;
    final savedWirdCount =
        savedDate == todayKey ? (prefs.getInt('wird_read_today') ?? 0) : 0;

    setState(() {
      _currentPage = (prefs.getInt('current_page') ?? 1).clamp(1, totalPages);
      _bookmarkedPage = prefs.getInt('bookmarked_page');
      _nightMode = prefs.getBool('night_mode') ?? false;
      _pageScale = (prefs.getDouble('page_scale') ?? 1.0).clamp(0.9, 1.25);
      _dailyWirdGoalPages = prefs.getInt('daily_wird_goal') ?? 20;
      _lastWirdDate = todayKey;
      _wirdReadToday = savedWirdCount;
    });

    await prefs.setString('last_wird_date', todayKey);
    await prefs.setInt('wird_read_today', _wirdReadToday);
  }

  String _todayDateKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _persistPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_page', _currentPage);
    if (_bookmarkedPage != null) {
      await prefs.setInt('bookmarked_page', _bookmarkedPage!);
    } else {
      await prefs.remove('bookmarked_page');
    }
    await prefs.setBool('night_mode', _nightMode);
    await prefs.setDouble('page_scale', _pageScale);
    await prefs.setInt('daily_wird_goal', _dailyWirdGoalPages);
    await prefs.setString('last_wird_date', _lastWirdDate);
    await prefs.setInt('wird_read_today', _wirdReadToday);
  }

  void _onSettleTick() {
    if (_settleAnimation == null) return;
    setState(() {
      _dragProgress = _settleAnimation!.value.clamp(0.0, 1.0);
    });
  }

  void _onSettleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final int dir = _dragDirection;
      final bool committed = _commitTargetReached;

      setState(() {
        if (committed) {
          final int nextPage = (_currentPage - dir).clamp(1, totalPages);
          if (nextPage != _currentPage) {
            _currentPage = nextPage;
            _registerWirdProgress();
          }
        }
        _dragDirection = 0;
        _dragProgress = 0.0;
        _isAnimatingCommit = false;
        _commitTargetReached = false;
      });
      _persistPreferences();
    }
  }

  void _registerWirdProgress() {
    final today = _todayDateKey();
    if (_lastWirdDate != today) {
      _lastWirdDate = today;
      _wirdReadToday = 0;
    }
    if (_wirdReadToday < _dailyWirdGoalPages) {
      _wirdReadToday++;
    }
  }

  void _jumpToPage(int page) {
    final int target = page.clamp(1, totalPages);
    if (_settleController.isAnimating) {
      _settleController.stop();
    }
    setState(() {
      _dragDirection = 0;
      _dragProgress = 0.0;
      _isAnimatingCommit = false;
      _commitTargetReached = false;
      _currentPage = target;
    });
    _persistPreferences();
  }

  void _toggleBookmark() {
    setState(() {
      if (_bookmarkedPage == _currentPage) {
        _bookmarkedPage = null;
      } else {
        _bookmarkedPage = _currentPage;
      }
    });
    _persistPreferences();
  }

  void _handlePanStart(DragStartDetails details, double width, double height) {
    if (_isAnimatingCommit) return;
    if (_settleController.isAnimating) {
      _settleController.stop();
    }
    setState(() {
      _dragDirection = 0;
      _dragProgress = 0.0;
      _pointerDyRatio = (details.localPosition.dy / height).clamp(0.0, 1.0);
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, double width, double height) {
    if (_isAnimatingCommit || width <= 0) return;

    final double dx = details.delta.dx;
    final double dyRatio = (details.localPosition.dy / height).clamp(0.0, 1.0);

    if (_dragDirection == 0 && dx.abs() > 1.5) {
      final int candidateDir = dx < 0 ? -1 : 1;
      final int targetPage = _currentPage - candidateDir;
      if (targetPage >= 1 && targetPage <= totalPages) {
        _dragDirection = candidateDir;
      }
    }

    if (_dragDirection == 0) {
      setState(() {
        _pointerDyRatio = dyRatio;
      });
      return;
    }

    final double deltaProgress = (-dx * _dragDirection) / (width * 0.85);
    setState(() {
      _pointerDyRatio = dyRatio;
      _dragProgress = (_dragProgress + deltaProgress).clamp(0.0, 1.0);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isAnimatingCommit || _dragDirection == 0) return;

    final double velocity = details.primaryVelocity ?? 0.0;
    final double directionalVelocity = -velocity * _dragDirection;

    final bool shouldCommit =
        _dragProgress >= 0.36 || directionalVelocity > 450;

    _commitTargetReached = shouldCommit;
    _isAnimatingCommit = true;

    final double endValue = shouldCommit ? 1.0 : 0.0;
    _settleAnimation = Tween<double>(
      begin: _dragProgress,
      end: endValue,
    ).animate(
      CurvedAnimation(
        parent: _settleController,
        curve: Curves.easeOutCubic,
      ),
    );

    _settleController.forward(from: 0.0);
  }

  SurahInfo get _currentSurah {
    SurahInfo current = kSurahs.first;
    for (final s in kSurahs) {
      if (s.startPage <= _currentPage) {
        current = s;
      } else {
        break;
      }
    }
    return current;
  }

  JuzInfo get _currentJuz {
    JuzInfo current = kJuzList.first;
    for (final j in kJuzList) {
      if (j.startPage <= _currentPage) {
        current = j;
      } else {
        break;
      }
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        _nightMode ? const Color(0xFF121417) : const Color(0xFFF6EFE2);
    final Color textColor =
        _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
    final Color accentColor =
        _nightMode ? const Color(0xFFD4AF37) : const Color(0xFF8C6223);

    final int? underPageNumber = _dragDirection == 0
        ? null
        : (_currentPage - _dragDirection).clamp(1, totalPages);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'سورة ${_currentSurah.name}',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${_currentJuz.title} • ص $_currentPage',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.72),
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _bookmarkedPage == _currentPage
                ? 'إزالة علامة الحفظ'
                : 'حفظ العلامة هنا',
            icon: Icon(
              _bookmarkedPage == _currentPage
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: _bookmarkedPage == _currentPage ? accentColor : textColor,
            ),
            onPressed: _toggleBookmark,
          ),
          if (_bookmarkedPage != null)
            IconButton(
              tooltip: 'الذهاب إلى علامة الحفظ (ص $_bookmarkedPage)',
              icon: Icon(Icons.turned_in_not, color: accentColor),
              onPressed: () => _jumpToPage(_bookmarkedPage!),
            ),
          IconButton(
            tooltip: _nightMode ? 'الوضع النهاري' : 'الوضع الليلي',
            icon: Icon(
              _nightMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: textColor,
            ),
            onPressed: () {
              setState(() => _nightMode = !_nightMode);
              _persistPreferences();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) => _handlePanStart(d, width, height),
                  onPanUpdate: (d) => _handlePanUpdate(d, width, height),
                  onPanEnd: _handlePanEnd,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (underPageNumber != null)
                        _buildFixedUnderPage(
                          pageNumber: underPageNumber,
                          nightMode: _nightMode,
                          scale: _pageScale,
                          progress: _dragProgress,
                        ),
                      _buildActiveCurved3DPage(
                        pageNumber: _currentPage,
                        width: width,
                        height: height,
                        dragDirection: _dragDirection,
                        progress: _dragProgress,
                        pointerDyRatio: _pointerDyRatio,
                        nightMode: _nightMode,
                        scale: _pageScale,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildBottomNavigationBar(textColor, accentColor, bgColor),
        ],
      ),
    );
  }

  Widget _buildFixedUnderPage({
    required int pageNumber,
    required bool nightMode,
    required double scale,
    required double progress,
  }) {
    final double shadowOpacity =
        (0.28 * (1.0 - (progress * 0.45))).clamp(0.0, 0.35);

    return Stack(
      fit: StackFit.expand,
      children: [
        MushafSheetWithFrame(
          pageNumber: pageNumber,
          nightMode: nightMode,
          scale: scale,
        ),
        IgnorePointer(
          child: Container(
            color: Colors.black.withValues(alpha: shadowOpacity * 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCurved3DPage({
    required int pageNumber,
    required double width,
    required double height,
    required int dragDirection,
    required double progress,
    required double pointerDyRatio,
    required bool nightMode,
    required double scale,
  }) {
    if (dragDirection == 0 || progress <= 0.0) {
      return MushafSheetWithFrame(
        pageNumber: pageNumber,
        nightMode: nightMode,
        scale: scale,
      );
    }

    const double maxTiltAngle = 0.72;
    final double angleY = dragDirection * progress * maxTiltAngle;

    final double verticalFactor = (pointerDyRatio - 0.5) * 2.0;
    final double angleX = -verticalFactor * progress * 0.14;

    final double translateX = dragDirection * progress * (width * 0.68);
    final double translateY = verticalFactor * progress * (height * 0.04);

    final double pivotX = dragDirection < 0 ? 0.85 : 0.15;
    final double pivotY = pointerDyRatio.clamp(0.15, 0.85);

    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0011)
      ..translate(translateX, translateY, 0.0)
      ..rotateY(angleY)
      ..rotateX(angleX);

    return Transform(
      alignment: Alignment(pivotX * 2 - 1, pivotY * 2 - 1),
      transform: transform,
      child: ClipPath(
        clipper: _PageCurlClipper(
          dragDirection: dragDirection,
          progress: progress,
          pointerDyRatio: pointerDyRatio,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MushafSheetWithFrame(
              pageNumber: pageNumber,
              nightMode: nightMode,
              scale: scale,
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: dragDirection < 0
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    end: dragDirection < 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(
                          alpha: nightMode ? 0.04 : 0.16 * progress),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.24 * progress),
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    Color textColor,
    Color accentColor,
    Color bgColor,
  ) {
    final double wirdRatio = _dailyWirdGoalPages > 0
        ? (_wirdReadToday / _dailyWirdGoalPages).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: textColor.withValues(alpha: 0.12)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'الورد اليومي: $_wirdReadToday / $_dailyWirdGoalPages صفحة',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: wirdRatio,
                      minHeight: 6,
                      backgroundColor: textColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavActionButton(
                  icon: Icons.menu_book_outlined,
                  label: 'الفهرس',
                  color: textColor,
                  onTap: _openSurahIndexSheet,
                ),
                _NavActionButton(
                  icon: Icons.grid_view_outlined,
                  label: 'الأجزاء',
                  color: textColor,
                  onTap: _openJuzSheet,
                ),
                _NavActionButton(
                  icon: Icons.track_changes_outlined,
                  label: 'الورد',
                  color: textColor,
                  onTap: _openWirdSettingsDialog,
                ),
                _NavActionButton(
                  icon: Icons.zoom_in_outlined,
                  label: 'الحجم',
                  color: textColor,
                  onTap: _openScaleSheet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSurahIndexSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _nightMode ? const Color(0xFF1A1D22) : const Color(0xFFFAF5EA),
      builder: (ctx) {
        final Color fg =
            _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
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
                    color: fg,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kSurahs.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: fg.withValues(alpha: 0.1)),
                  itemBuilder: (_, index) {
                    final surah = kSurahs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: fg.withValues(alpha: 0.12),
                        child: Text(
                          '${surah.number}',
                          style: TextStyle(color: fg, fontSize: 13),
                        ),
                      ),
                      title: Text(
                        surah.name,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        surah.revelationType,
                        style: TextStyle(color: fg.withValues(alpha: 0.65)),
                      ),
                      trailing: Text(
                        'ص ${surah.startPage}',
                        style: TextStyle(color: fg.withValues(alpha: 0.8)),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _jumpToPage(surah.startPage);
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

  void _openJuzSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _nightMode ? const Color(0xFF1A1D22) : const Color(0xFFFAF5EA),
      builder: (ctx) {
        final Color fg =
            _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
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
                    color: fg,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kJuzList.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: fg.withValues(alpha: 0.1)),
                  itemBuilder: (_, index) {
                    final juz = kJuzList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: fg.withValues(alpha: 0.12),
                        child: Text(
                          '${juz.number}',
                          style: TextStyle(color: fg, fontSize: 13),
                        ),
                      ),
                      title: Text(
                        juz.title,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        'تبدأ من ص ${juz.startPage}',
                        style: TextStyle(color: fg.withValues(alpha: 0.8)),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _jumpToPage(juz.startPage);
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

  void _openWirdSettingsDialog() {
    int tempGoal = _dailyWirdGoalPages;
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return AlertDialog(
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
                      onChanged: (val) {
                        setLocalState(() => tempGoal = val.round());
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _dailyWirdGoalPages = tempGoal;
                        if (_wirdReadToday > _dailyWirdGoalPages) {
                          _wirdReadToday = _dailyWirdGoalPages;
                        }
                      });
                      _persistPreferences();
                      Navigator.pop(ctx);
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _openScaleSheet() {
    double tempScale = _pageScale;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _nightMode ? const Color(0xFF1A1D22) : const Color(0xFFFAF5EA),
      builder: (ctx) {
        final Color fg =
            _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'حجم عرض الصفحة: ${(tempScale * 100).round()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: fg,
                      ),
                    ),
                    Slider(
                      min: 0.9,
                      max: 1.25,
                      divisions: 14,
                      value: tempScale,
                      onChanged: (v) {
                        setLocalState(() => tempScale = v);
                        setState(() => _pageScale = v);
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        onPressed: () {
                          _persistPreferences();
                          Navigator.pop(ctx);
                        },
                        child: const Text('تم'),
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

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }
}

// ============================================================================
// الورقة المرسومة مع الإطار القرآني المتحرك معها كجزء منها (604 صفحات)
// ============================================================================

class MushafSheetWithFrame extends StatelessWidget {
  final int pageNumber;
  final bool nightMode;
  final double scale;

  const MushafSheetWithFrame({
    super.key,
    required this.pageNumber,
    required this.nightMode,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final Color paperColor =
        nightMode ? const Color(0xFF15181C) : const Color(0xFFFAF4E6);
    final Color frameOuterColor =
        nightMode ? const Color(0xFFC59B27) : const Color(0xFF8A5A1E);
    final Color frameInnerColor =
        nightMode ? const Color(0xFF8F6E1B) : const Color(0xFFB6833A);

    final String assetPath = 'assets/images/quran/$pageNumber.png';

    return Transform.scale(
      scale: scale,
      child: Container(
        color: paperColor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: CustomPaint(
          painter: _QuranicPageFramePainter(
            outerColor: frameOuterColor,
            innerColor: frameInnerColor,
            paperColor: paperColor,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories,
                        size: 44,
                        color: frameOuterColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'صفحة المصحف رقم $pageNumber من 604',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: nightMode
                              ? const Color(0xFFE7DFC8)
                              : const Color(0xFF231F1A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        assetPath,
                        style: TextStyle(
                          fontSize: 12,
                          color: (nightMode
                                  ? const Color(0xFFE7DFC8)
                                  : const Color(0xFF231F1A))
                              .withValues(alpha: 0.65),
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
    );
  }
}

// ============================================================================
// رسام الإطار القرآني المدمج بالورقة وقص العطف المرن
// ============================================================================

class _QuranicPageFramePainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;
  final Color paperColor;

  _QuranicPageFramePainter({
    required this.outerColor,
    required this.innerColor,
    required this.paperColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect outerRect = Offset.zero & size;
    final Rect innerRect = outerRect.deflate(7.5);

    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawRect(outerRect, outerPaint);
    canvas.drawRect(innerRect, innerPaint);

    const double cornerLen = 18.0;
    final Paint cornerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;

    final List<Offset> corners = [
      outerRect.topLeft,
      outerRect.topRight,
      outerRect.bottomLeft,
      outerRect.bottomRight,
    ];

    for (final c in corners) {
      final double dx = (c.dx == outerRect.left) ? 1.0 : -1.0;
      final double dy = (c.dy == outerRect.top) ? 1.0 : -1.0;
      canvas.drawLine(c, Offset(c.dx + dx * cornerLen, c.dy), cornerPaint);
      canvas.drawLine(c, Offset(c.dx, c.dy + dy * cornerLen), cornerPaint);
    }

    final double midX = size.width / 2;
    final double midY = size.height / 2;
    const double diamondR = 5.0;

    final List<Offset> midPoints = [
      Offset(midX, outerRect.top),
      Offset(midX, outerRect.bottom),
      Offset(outerRect.left, midY),
      Offset(outerRect.right, midY),
    ];

    for (final m in midPoints) {
      final Path diamond = Path()
        ..moveTo(m.dx, m.dy - diamondR)
        ..lineTo(m.dx + diamondR, m.dy)
        ..lineTo(m.dx, m.dy + diamondR)
        ..lineTo(m.dx - diamondR, m.dy)
        ..close();
      canvas.drawPath(diamond, Paint()..color = paperColor);
      canvas.drawPath(diamond, outerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuranicPageFramePainter oldDelegate) {
    return oldDelegate.outerColor != outerColor ||
        oldDelegate.innerColor != innerColor ||
        oldDelegate.paperColor != paperColor;
  }
}

class _PageCurlClipper extends CustomClipper<Path> {
  final int dragDirection;
  final double progress;
  final double pointerDyRatio;

  _PageCurlClipper({
    required this.dragDirection,
    required this.progress,
    required this.pointerDyRatio,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();
    if (progress <= 0.0 || dragDirection == 0) {
      path.addRect(Offset.zero & size);
      return path;
    }

    final double curlDepth = size.width * 0.14 * progress;
    final double focusY =
        (size.height * pointerDyRatio).clamp(0.0, size.height);

    if (dragDirection < 0) {
      final double rightEdgeX = size.width - curlDepth;
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.quadraticBezierTo(
        rightEdgeX,
        focusY,
        size.width,
        size.height,
      );
      path.lineTo(0, size.height);
      path.close();
    } else {
      final double leftEdgeX = curlDepth;
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.quadraticBezierTo(
        leftEdgeX,
        focusY,
        0,
        0,
      );
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _PageCurlClipper oldClipper) {
    return oldClipper.dragDirection != dragDirection ||
        oldClipper.progress != progress ||
        oldClipper.pointerDyRatio != pointerDyRatio;
  }
}

class _NavActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavActionButton({
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
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
