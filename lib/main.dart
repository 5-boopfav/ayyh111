import 'dart:math' as math;

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

  // تتبع السحب المباشر باللمس
  int? _pointerId;
  double _startX = 0.0;
  double _lastX = 0.0;
  int _lastTimeMs = 0;
  double _vx = 0.0;
  double _dyRatio = 0.5;

  // -1 للانتقال للصفحة التالية (سحب لليسار)، +1 للرجوع للسابقة (سحب لليمين)
  int _dragDir = 0;
  double _progress = 0.0;
  bool _settling = false;
  bool _commit = false;

  late final AnimationController _settleCtrl;
  Animation<double>? _settleAnim;

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
              final int nextPage = (_currentPage - finishedDir).clamp(1, totalPages);
              if (nextPage != _currentPage) {
                _currentPage = nextPage;
                _advanceWirdOnce();
              }
            }
            _dragDir = 0;
            _progress = 0.0;
            _settling = false;
            _commit = false;
          });
          _saveState();
        }
      });

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
      _nightMode = prefs.getBool('night_mode') ?? false;
      _pageScale = (prefs.getDouble('page_scale') ?? 1.0).clamp(0.9, 1.25);
      _dailyWirdGoalPages = prefs.getInt('daily_wird_goal') ?? 20;
      _lastWirdDate = today;
      _wirdReadToday = savedWird;
    });
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
    await prefs.setBool('night_mode', _nightMode);
    await prefs.setDouble('page_scale', _pageScale);
    await prefs.setInt('daily_wird_goal', _dailyWirdGoalPages);
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
    if (_settleCtrl.isAnimating) {
      _settleCtrl.stop();
    }
    setState(() {
      _pointerId = null;
      _dragDir = 0;
      _progress = 0.0;
      _settling = false;
      _commit = false;
      _currentPage = page.clamp(1, totalPages);
    });
    _saveState();
  }

  void _toggleBookmark() {
    setState(() {
      _bookmarkedPage = _bookmarkedPage == _currentPage ? null : _currentPage;
    });
    _saveState();
  }

  void _handlePointerDown(PointerDownEvent event, double height) {
    if (_settling) return;
    if (_settleCtrl.isAnimating) {
      _settleCtrl.stop();
    }
    setState(() {
      _pointerId = event.pointer;
      _startX = event.localPosition.dx;
      _lastX = event.localPosition.dx;
      _lastTimeMs = DateTime.now().millisecondsSinceEpoch;
      _vx = 0.0;
      _dyRatio =
          height > 0 ? (event.localPosition.dy / height).clamp(0.08, 0.92) : 0.5;
      _dragDir = 0;
      _progress = 0.0;
    });
  }

  void _handlePointerMove(PointerMoveEvent event, double width, double height) {
    if (_settling || width <= 0) return;
    if (_pointerId != null && event.pointer != _pointerId) return;

    final int now = DateTime.now().millisecondsSinceEpoch;
    final int dt = now - _lastTimeMs;
    if (dt > 0) {
      _vx = ((event.localPosition.dx - _lastX) * 1000.0) / dt;
    }
    _lastX = event.localPosition.dx;
    _lastTimeMs = now;

    final double dx = event.localPosition.dx - _startX;
    final double ratioY =
        height > 0 ? (event.localPosition.dy / height).clamp(0.08, 0.92) : 0.5;

    int dir = _dragDir;
    if (dir == 0 && dx.abs() > 2.0) {
      final int candidate = dx < 0 ? -1 : 1;
      final int target = _currentPage - candidate;
      if (target >= 1 && target <= totalPages) {
        dir = candidate;
      }
    }

    if (dir == 0) {
      setState(() => _dyRatio = ratioY);
      return;
    }

    final double raw = ((-dx * dir) / (width * 0.65)).clamp(0.0, 1.0);
    setState(() {
      _dragDir = dir;
      _dyRatio = ratioY;
      _progress = raw;
    });
  }

  void _handlePointerEnd(int pointer) {
    if (_pointerId != null && pointer != _pointerId) return;
    _pointerId = null;
    if (_settling || _dragDir == 0) return;

    final double directionalSpeed = -_vx * _dragDir;
    final bool shouldCommit = _progress >= 0.35 || directionalSpeed > 360;
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
    final Color bgColor =
        _nightMode ? const Color(0xFF121417) : const Color(0xFFF6EFE2);
    final Color textColor =
        _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
    final Color accentColor =
        _nightMode ? const Color(0xFFD4AF37) : const Color(0xFF8C6223);

    final bool activeCurl = _dragDir != 0 && _progress > 0.001;
    final int underPage =
        activeCurl ? (_currentPage - _dragDir).clamp(1, totalPages) : _currentPage;

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
              _saveState();
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

                return Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) => _handlePointerDown(e, height),
                  onPointerMove: (e) => _handlePointerMove(e, width, height),
                  onPointerUp: (e) => _handlePointerEnd(e.pointer),
                  onPointerCancel: (e) => _handlePointerEnd(e.pointer),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. الصفحة الثابتة تحت الورقة المنثنية
                      if (activeCurl)
                        _UnderPageLayer(
                          pageNumber: underPage,
                          nightMode: _nightMode,
                          scale: _pageScale,
                          progress: _progress,
                        ),

                      // 2. الورقة المنثنية مع Matrix4 ثلاثي الأبعاد والانثناء والظل وظهر الصفحة
                      _Matrix3DCurledSheet(
                        currentPage: _currentPage,
                        backPage: underPage,
                        width: width,
                        height: height,
                        direction: activeCurl ? _dragDir : 0,
                        progress: activeCurl ? _progress : 0.0,
                        dyRatio: _dyRatio,
                        nightMode: _nightMode,
                        scale: _pageScale,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _BottomBar(
            textColor: textColor,
            accentColor: accentColor,
            bgColor: bgColor,
            wirdRead: _wirdReadToday,
            wirdGoal: _dailyWirdGoalPages,
            onOpenSurahs: _openSurahs,
            onOpenJuz: _openJuz,
            onOpenWird: _openWird,
            onOpenScale: _openScale,
          ),
        ],
      ),
    );
  }

  void _openSurahs() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _nightMode ? const Color(0xFF1A1D22) : const Color(0xFFFAF5EA),
      builder: (ctx) {
        final fg = _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'فهرس السور',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: fg),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kSurahs.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: fg.withValues(alpha: 0.1)),
                  itemBuilder: (_, i) {
                    final s = kSurahs[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: fg.withValues(alpha: 0.12),
                        child: Text('${s.number}', style: TextStyle(color: fg, fontSize: 13)),
                      ),
                      title: Text(s.name, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
                      subtitle: Text(s.revelationType, style: TextStyle(color: fg.withValues(alpha: 0.65))),
                      trailing: Text('ص ${s.startPage}', style: TextStyle(color: fg.withValues(alpha: 0.8))),
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

  void _openJuz() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _nightMode ? const Color(0xFF1A1D22) : const Color(0xFFFAF5EA),
      builder: (ctx) {
        final fg = _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'أجزاء المصحف الثلاثون',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: fg),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kJuzList.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: fg.withValues(alpha: 0.1)),
                  itemBuilder: (_, i) {
                    final j = kJuzList[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: fg.withValues(alpha: 0.12),
                        child: Text('${j.number}', style: TextStyle(color: fg, fontSize: 13)),
                      ),
                      title: Text(j.title, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
                      trailing: Text('تبدأ من ص ${j.startPage}', style: TextStyle(color: fg.withValues(alpha: 0.8))),
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
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
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

  void _openScale() {
    double tempScale = _pageScale;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _nightMode ? const Color(0xFF1A1D22) : const Color(0xFFFAF5EA),
      builder: (ctx) {
        final fg = _nightMode ? const Color(0xFFE7DFC8) : const Color(0xFF231F1A);
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: fg),
                  ),
                  Slider(
                    min: 0.9,
                    max: 1.25,
                    divisions: 14,
                    value: tempScale,
                    onChanged: (v) {
                      setLocal(() => tempScale = v);
                      setState(() => _pageScale = v);
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
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

class _UnderPageLayer extends StatelessWidget {
  final int pageNumber;
  final bool nightMode;
  final double scale;
  final double progress;

  const _UnderPageLayer({
    required this.pageNumber,
    required this.nightMode,
    required this.scale,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final double shade = (0.18 * (1.0 - progress)).clamp(0.0, 0.22);
    return Stack(
      fit: StackFit.expand,
      children: [
        MushafSingleSheet(pageNumber: pageNumber, nightMode: nightMode, scale: scale),
        IgnorePointer(child: Container(color: Colors.black.withValues(alpha: shade))),
      ],
    );
  }
}

class _Matrix3DCurledSheet extends StatelessWidget {
  final int currentPage;
  final int backPage;
  final double width;
  final double height;
  final int direction;
  final double progress;
  final double dyRatio;
  final bool nightMode;
  final double scale;

  const _Matrix3DCurledSheet({
    required this.currentPage,
    required this.backPage,
    required this.width,
    required this.height,
    required this.direction,
    required this.progress,
    required this.dyRatio,
    required this.nightMode,
    required this.scale,
  });

  Matrix4 _buildFlapPerspectiveMatrix() {
    // مصفوفة تحويل ثلاثية الأبعاد مع عمق منظور ودوران حول المحور الرأسي للثنية
    final Matrix4 m = Matrix4.identity()..setEntry(3, 2, 0.0012);
    final double yawAngle = -direction * (math.pi * 0.42 * progress);
    final double tiltX = (dyRatio - 0.5) * 0.14 * progress;
    m.rotateY(yawAngle);
    m.rotateX(tiltX);
    return m;
  }

  @override
  Widget build(BuildContext context) {
    if (direction == 0 || progress <= 0.0) {
      return MushafSingleSheet(
        pageNumber: currentPage,
        nightMode: nightMode,
        scale: scale,
      );
    }

    final _SheetCurlData data = _SheetCurlData.build(
      size: Size(width, height),
      direction: direction,
      progress: progress,
      dyRatio: dyRatio,
    );

    final Matrix4 flapMatrix = _buildFlapPerspectiveMatrix();
    final Alignment flapAlignment =
        direction < 0 ? Alignment.centerRight : Alignment.centerLeft;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ظل خط العطف على الصفحة الثابتة تحت الورقة
        IgnorePointer(
          child: CustomPaint(
            size: Size(width, height),
            painter: _CreaseShadowPainter(
              data: data,
              progress: progress,
              nightMode: nightMode,
            ),
          ),
        ),

        // الجزء الثابت غير المنعطف من الورقة الحالية
        ClipPath(
          clipper: _FixedSheetClipper(data: data),
          child: MushafSingleSheet(
            pageNumber: currentPage,
            nightMode: nightMode,
            scale: scale,
          ),
        ),

        // الجزء المنثني ثلاثي الأبعاد: يظهر الصفحة التالية معكوسة مع عمق Matrix4 وظل التقوّس
        ClipPath(
          clipper: _FlapClipper(data: data),
          child: Transform(
            alignment: flapAlignment,
            transform: flapMatrix,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                  child: Opacity(
                    opacity: nightMode ? 0.44 : 0.58,
                    child: MushafSingleSheet(
                      pageNumber: backPage,
                      nightMode: nightMode,
                      scale: scale,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: (nightMode
                              ? const Color(0xFF1A1E24)
                              : const Color(0xFFF3EAD8))
                          .withValues(alpha: nightMode ? 0.50 : 0.42),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(width, height),
                    painter: _FlapCreasePainter(
                      data: data,
                      progress: progress,
                      nightMode: nightMode,
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

class _SheetCurlData {
  final Size size;
  final int direction;
  final double progress;
  final double topX;
  final double bottomX;
  final double bowX;
  final double focusY;
  final double flapWidth;

  const _SheetCurlData({
    required this.size,
    required this.direction,
    required this.progress,
    required this.topX,
    required this.bottomX,
    required this.bowX,
    required this.focusY,
    required this.flapWidth,
  });

  factory _SheetCurlData.build({
    required Size size,
    required int direction,
    required double progress,
    required double dyRatio,
  }) {
    final double w = size.width;
    final double h = size.height;
    final double biasY = (dyRatio - 0.5) * 2.0;
    final double slant = biasY * w * 0.16 * progress;
    final double bow = w * 0.09 * (progress * (1.0 - progress * 0.3));
    final double fy = (h * dyRatio).clamp(h * 0.1, h * 0.9);
    final double flap = (w * (0.16 + 0.24 * progress)).clamp(24.0, w * 0.45);

    if (direction < 0) {
      final double base = w * (1.0 - progress);
      return _SheetCurlData(
        size: size,
        direction: direction,
        progress: progress,
        topX: (base + slant).clamp(0.0, w),
        bottomX: (base - slant).clamp(0.0, w),
        bowX: -bow,
        focusY: fy,
        flapWidth: flap,
      );
    } else {
      final double base = w * progress;
      return _SheetCurlData(
        size: size,
        direction: direction,
        progress: progress,
        topX: (base - slant).clamp(0.0, w),
        bottomX: (base + slant).clamp(0.0, w),
        bowX: bow,
        focusY: fy,
        flapWidth: flap,
      );
    }
  }

  Path creasePath() {
    final double midX = (topX + bottomX) * 0.5 + bowX;
    return Path()
      ..moveTo(topX, 0)
      ..quadraticBezierTo(midX, focusY, bottomX, size.height);
  }

  Path outerFlapPath() {
    final double tOut = (topX - direction * flapWidth).clamp(0.0, size.width);
    final double bOut = (bottomX - direction * flapWidth).clamp(0.0, size.width);
    final double mOut =
        ((tOut + bOut) * 0.5 + bowX * 1.25).clamp(0.0, size.width);
    return Path()
      ..moveTo(tOut, 0)
      ..quadraticBezierTo(mOut, focusY, bOut, size.height);
  }
}

class _FixedSheetClipper extends CustomClipper<Path> {
  final _SheetCurlData data;
  _FixedSheetClipper({required this.data});

  @override
  Path getClip(Size size) {
    final double midX = (data.topX + data.bottomX) * 0.5 + data.bowX;
    final Path path = Path();
    if (data.direction < 0) {
      path.moveTo(0, 0);
      path.lineTo(data.topX, 0);
      path.quadraticBezierTo(midX, data.focusY, data.bottomX, size.height);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(data.topX, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(data.bottomX, size.height);
      path.quadraticBezierTo(midX, data.focusY, data.topX, 0);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _FixedSheetClipper oldClipper) => oldClipper.data != data;
}

class _FlapClipper extends CustomClipper<Path> {
  final _SheetCurlData data;
  _FlapClipper({required this.data});

  @override
  Path getClip(Size size) {
    final double midX = (data.topX + data.bottomX) * 0.5 + data.bowX;
    final double tOut =
        (data.topX - data.direction * data.flapWidth).clamp(0.0, size.width);
    final double bOut =
        (data.bottomX - data.direction * data.flapWidth).clamp(0.0, size.width);
    final double mOut =
        ((tOut + bOut) * 0.5 + data.bowX * 1.25).clamp(0.0, size.width);

    return Path()
      ..moveTo(data.topX, 0)
      ..quadraticBezierTo(midX, data.focusY, data.bottomX, size.height)
      ..lineTo(bOut, size.height)
      ..quadraticBezierTo(mOut, data.focusY, tOut, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _FlapClipper oldClipper) => oldClipper.data != data;
}

class _CreaseShadowPainter extends CustomPainter {
  final _SheetCurlData data;
  final double progress;
  final bool nightMode;

  _CreaseShadowPainter({
    required this.data,
    required this.progress,
    required this.nightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;
    final double sw = (26.0 * progress).clamp(5.0, 28.0);
    final double alpha = (nightMode ? 0.36 : 0.26) * progress;

    canvas.drawPath(
      data.creasePath(),
      Paint()
        ..color = Colors.black.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sw * 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _CreaseShadowPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.progress != progress ||
      oldDelegate.nightMode != nightMode;
}

class _FlapCreasePainter extends CustomPainter {
  final _SheetCurlData data;
  final double progress;
  final bool nightMode;

  _FlapCreasePainter({
    required this.data,
    required this.progress,
    required this.nightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    canvas.drawPath(
      data.outerFlapPath(),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
    );

    canvas.drawPath(
      data.creasePath(),
      Paint()
        ..color = (nightMode ? Colors.white : Colors.black)
            .withValues(alpha: (nightMode ? 0.18 : 0.24) * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _FlapCreasePainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.progress != progress ||
      oldDelegate.nightMode != nightMode;
}

class MushafSingleSheet extends StatelessWidget {
  final int pageNumber;
  final bool nightMode;
  final double scale;

  const MushafSingleSheet({
    super.key,
    required this.pageNumber,
    required this.nightMode,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final Color paper =
        nightMode ? const Color(0xFF15181C) : const Color(0xFFFAF4E6);
    final Color outerFrame =
        nightMode ? const Color(0xFFC59B27) : const Color(0xFF8A5A1E);
    final Color innerFrame =
        nightMode ? const Color(0xFF8F6E1B) : const Color(0xFFB6833A);
    final String assetPath = 'assets/images/quran/$pageNumber.png';

    return Transform.scale(
      scale: scale,
      child: Container(
        color: paper,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: CustomPaint(
          painter: _QuranFramePainter(
            outerColor: outerFrame,
            innerColor: innerFrame,
            paperColor: paper,
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
                        color: outerFrame.withValues(alpha: 0.7),
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

class _QuranFramePainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;
  final Color paperColor;

  _QuranFramePainter({
    required this.outerColor,
    required this.innerColor,
    required this.paperColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect outer = Offset.zero & size;
    final Rect inner = outer.deflate(7.5);

    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawRect(outer, outerPaint);
    canvas.drawRect(inner, innerPaint);

    const double cornerLen = 18.0;
    final Paint cornerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;

    for (final c in [outer.topLeft, outer.topRight, outer.bottomLeft, outer.bottomRight]) {
      final double dx = c.dx == outer.left ? 1.0 : -1.0;
      final double dy = c.dy == outer.top ? 1.0 : -1.0;
      canvas.drawLine(c, Offset(c.dx + dx * cornerLen, c.dy), cornerPaint);
      canvas.drawLine(c, Offset(c.dx, c.dy + dy * cornerLen), cornerPaint);
    }

    final double midX = size.width / 2;
    final double midY = size.height / 2;
    const double r = 5.0;

    for (final m in [
      Offset(midX, outer.top),
      Offset(midX, outer.bottom),
      Offset(outer.left, midY),
      Offset(outer.right, midY),
    ]) {
      final Path d = Path()
        ..moveTo(m.dx, m.dy - r)
        ..lineTo(m.dx + r, m.dy)
        ..lineTo(m.dx, m.dy + r)
        ..lineTo(m.dx - r, m.dy)
        ..close();
      canvas.drawPath(d, Paint()..color = paperColor);
      canvas.drawPath(d, outerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuranFramePainter oldDelegate) =>
      oldDelegate.outerColor != outerColor ||
      oldDelegate.innerColor != innerColor ||
      oldDelegate.paperColor != paperColor;
}

class _BottomBar extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  final Color bgColor;
  final int wirdRead;
  final int wirdGoal;
  final VoidCallback onOpenSurahs;
  final VoidCallback onOpenJuz;
  final VoidCallback onOpenWird;
  final VoidCallback onOpenScale;

  const _BottomBar({
    required this.textColor,
    required this.accentColor,
    required this.bgColor,
    required this.wirdRead,
    required this.wirdGoal,
    required this.onOpenSurahs,
    required this.onOpenJuz,
    required this.onOpenWird,
    required this.onOpenScale,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio =
        wirdGoal > 0 ? (wirdRead / wirdGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: textColor.withValues(alpha: 0.12))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'الورد اليومي: $wirdRead / $wirdGoal صفحة',
                  style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.85)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
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
                _BarBtn(icon: Icons.menu_book_outlined, label: 'الفهرس', color: textColor, onTap: onOpenSurahs),
                _BarBtn(icon: Icons.grid_view_outlined, label: 'الأجزاء', color: textColor, onTap: onOpenJuz),
                _BarBtn(icon: Icons.track_changes_outlined, label: 'الورد', color: textColor, onTap: onOpenWird),
                _BarBtn(icon: Icons.zoom_in_outlined, label: 'الحجم', color: textColor, onTap: onOpenScale),
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
