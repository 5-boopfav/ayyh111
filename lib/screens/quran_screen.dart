import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranScreen extends StatefulWidget {
  final int initialPage;

  const QuranScreen({
    super.key,
    this.initialPage = 1,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalPages = 604;
  static const String _prefLastPage = 'quran_last_page';
  static const String _prefNightMode = 'quran_night_mode';
  static const String _prefBookmarkPage = 'quran_bookmark_page';
  static const String _prefDailyWirdPages = 'quran_daily_wird_pages';
  static const String _prefFontScale = 'quran_font_scale';

  late PageController _pageController;
  late AnimationController _curlController;

  int _currentPage = 1;
  bool _nightMode = false;
  int? _bookmarkedPage;
  int _dailyWirdPages = 20;
  double _fontScale = 1.0;

  // حالة السحب من الجزء العلوي الأيسر نحو اليمين
  bool _isDragging = false;
  bool _openingNextPage = true; // true: يسار -> يمين (الصفحة التالية)
  double _rawProgress = 0.0;
  double _dragStartX = 0.0;
  double _dragStartY = 0.0;
  double _pointerRatioY = 0.14;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, _totalPages);
    _pageController = PageController(initialPage: _currentPage - 1);
    _curlController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(() {
        if (!_isDragging) {
          setState(() {
            _rawProgress = _curlController.value;
          });
        }
      });

    _loadPreferences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _curlController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final savedPage = prefs.getInt(_prefLastPage);
    final savedNight = prefs.getBool(_prefNightMode) ?? false;
    final savedBookmark = prefs.getInt(_prefBookmarkPage);
    final savedWird = prefs.getInt(_prefDailyWirdPages) ?? 20;
    final savedScale = prefs.getDouble(_prefFontScale) ?? 1.0;

    final targetPage =
        (widget.initialPage != 1 ? widget.initialPage : (savedPage ?? 1))
            .clamp(1, _totalPages);

    setState(() {
      _nightMode = savedNight;
      _bookmarkedPage = savedBookmark;
      _dailyWirdPages = savedWird.clamp(1, 100);
      _fontScale = savedScale.clamp(0.8, 1.5);
      _currentPage = targetPage;
    });

    if (_pageController.hasClients &&
        (_pageController.page?.round() ?? 0) != targetPage - 1) {
      _pageController.jumpToPage(targetPage - 1);
    }
  }

  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefLastPage, page);
  }

  Future<void> _toggleNightMode() async {
    final next = !_nightMode;
    setState(() => _nightMode = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefNightMode, next);
  }

  Future<void> _toggleBookmarkForCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedPage == _currentPage) {
        _bookmarkedPage = null;
        prefs.remove(_prefBookmarkPage);
      } else {
        _bookmarkedPage = _currentPage;
        prefs.setInt(_prefBookmarkPage, _currentPage);
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarkedPage == _currentPage
              ? 'تم حفظ العلامة في الصفحة $_currentPage'
              : 'تمت إزالة العلامة',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _saveDailyWird(int pages) async {
    final clamped = pages.clamp(1, 100);
    setState(() => _dailyWirdPages = clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefDailyWirdPages, clamped);
  }

  Future<void> _saveFontScale(double scale) async {
    final clamped = scale.clamp(0.8, 1.5);
    setState(() => _fontScale = clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefFontScale, clamped);
  }

  void _goToPage(int page) {
    final target = page.clamp(1, _totalPages);
    setState(() {
      _currentPage = target;
      _isDragging = false;
      _rawProgress = 0.0;
    });
    _saveLastPage(target);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(target - 1);
    }
  }

  String _quranPageAssetPath(int pageNumber) {
    return 'assets/images/quran/$pageNumber.png';
  }

  int _estimateJuz(int pageNumber) {
    return (((pageNumber - 1) ~/ 20) + 1).clamp(1, 30);
  }

  // منحنى زمني يحاكي المراحل الأربع للورقة بـ easeInOutCubic
  double _shapedProgress(double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (clamped <= 0.15) {
      final local = clamped / 0.15;
      return Curves.easeOut.transform(local) * 0.12;
    } else if (clamped <= 0.55) {
      final local = (clamped - 0.15) / 0.40;
      return 0.12 + Curves.easeInOutCubic.transform(local) * 0.43;
    } else if (clamped <= 0.80) {
      final local = (clamped - 0.55) / 0.25;
      return 0.55 + Curves.easeInOutCubic.transform(local) * 0.25;
    } else {
      final local = (clamped - 0.80) / 0.20;
      return 0.80 + Curves.easeOutCubic.transform(local) * 0.20;
    }
  }

  void _onHorizontalDragStart(DragStartDetails details, double height) {
    if (_curlController.isAnimating) {
      _curlController.stop();
    }
    setState(() {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
      _dragStartY = details.globalPosition.dy;
      _pointerRatioY =
          height > 0 ? (_dragStartY / height).clamp(0.04, 0.85) : 0.14;
      _rawProgress = 0.0;
    });
  }

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
    double width,
    double height,
  ) {
    if (!_isDragging || width <= 0) return;

    final deltaX = details.globalPosition.dx - _dragStartX;
    final ratioY = height > 0
        ? (details.globalPosition.dy / height).clamp(0.04, 0.85)
        : 0.14;

    // السحب من اليسار إلى اليمين (deltaX > 0) يفتح الصفحة التالية من الجزء العلوي الأيسر
    if (deltaX > 0 && _currentPage < _totalPages) {
      _openingNextPage = true;
      _pointerRatioY = ratioY;
      _rawProgress = (deltaX / width).clamp(0.0, 1.0);
      setState(() {});
    }
    // السحب من اليمين إلى اليسار (deltaX < 0) يرجع للصفحة السابقة
    else if (deltaX < 0 && _currentPage > 1) {
      _openingNextPage = false;
      _pointerRatioY = ratioY;
      _rawProgress = (-deltaX / width).clamp(0.0, 1.0);
      setState(() {});
    } else {
      setState(() => _rawProgress = 0.0);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final velocity = details.primaryVelocity ?? 0.0;
    final shouldComplete = _rawProgress >= 0.40 || velocity.abs() > 750;
    final targetPage = _openingNextPage
        ? (_currentPage + 1).clamp(1, _totalPages)
        : (_currentPage - 1).clamp(1, _totalPages);

    _isDragging = false;

    if (shouldComplete && targetPage != _currentPage) {
      _curlController.forward(from: _rawProgress).then((_) {
        if (!mounted) return;
        _goToPage(targetPage);
        _curlController.reset();
      });
    } else {
      _curlController.reverse(from: _rawProgress).then((_) {
        if (!mounted) return;
        setState(() => _rawProgress = 0.0);
      });
    }
  }

  Future<void> _openGoToPageDialog() async {
    final controller = TextEditingController(text: '$_currentPage');
    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('الانتقال إلى صفحة'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'أدخل رقم الصفحة (1 - 604)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                Navigator.pop(context, parsed);
              },
              child: const Text('انتقال'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      _goToPage(result);
    }
  }

  void _openQuickMenuSheet() {
    final wirdEndPage =
        (_currentPage + _dailyWirdPages - 1).clamp(1, _totalPages);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          _nightMode ? const Color(0xFF1B1F24) : const Color(0xFFFFFDF8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final textColor =
                _nightMode ? const Color(0xFFEAE5DC) : const Color(0xFF23292E);

            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'صفحة $_currentPage • الجزء ${_estimateJuz(_currentPage)}',
                        style: TextStyle(
                          fontSize: 16 * _fontScale,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleBookmarkForCurrentPage,
                        icon: Icon(
                          _bookmarkedPage == _currentPage
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: _bookmarkedPage == _currentPage
                              ? const Color(0xFFC39E58)
                              : textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('الانتقال لصفحة'),
                        onPressed: () {
                          Navigator.pop(context);
                          _openGoToPageDialog();
                        },
                      ),
                      if (_bookmarkedPage != null)
                        ActionChip(
                          label: Text('العلامة (صـ $_bookmarkedPage)'),
                          onPressed: () {
                            final p = _bookmarkedPage!;
                            Navigator.pop(context);
                            _goToPage(p);
                          },
                        ),
                      ActionChip(
                        label: Text(
                          _nightMode ? 'الوضع النهاري' : 'الوضع الليلي',
                        ),
                        onPressed: () async {
                          await _toggleNightMode();
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'الورد اليومي: $_dailyWirdPages صفحات (إلى صـ $wirdEndPage)',
                    style: TextStyle(
                      fontSize: 13 * _fontScale,
                      color: textColor,
                    ),
                  ),
                  Slider(
                    value: _dailyWirdPages.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '$_dailyWirdPages',
                    onChanged: (value) async {
                      await _saveDailyWird(value.round());
                      setModalState(() {});
                    },
                  ),
                  Text(
                    'حجم نصوص القوائم: ${(_fontScale * 100).round()}%',
                    style: TextStyle(
                      fontSize: 13 * _fontScale,
                      color: textColor,
                    ),
                  ),
                  Slider(
                    value: _fontScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 14,
                    label: '${(_fontScale * 100).round()}%',
                    onChanged: (value) async {
                      await _saveFontScale(value);
                      setModalState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFullMushafPage(int pageNumber, {bool showControls = true}) {
    final paperColor =
        _nightMode ? const Color(0xFF14171A) : const Color(0xFFFFFDF8);
    final headerTextColor =
        _nightMode ? const Color(0xFFE5DFD3) : const Color(0xFF2B3338);

    Widget imageWidget = Image.asset(
      _quranPageAssetPath(pageNumber),
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'تعذّر العثور على صورة الصفحة $pageNumber في assets/images/quran/$pageNumber.png',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _nightMode ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        );
      },
    );

    if (_nightMode) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Color(0x88121518),
          BlendMode.darken,
        ),
        child: imageWidget,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: paperColor,
      child: Stack(
        children: [
          Positioned.fill(child: imageWidget),
          if (showControls)
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FloatingCircleIcon(
                    icon: Icons.search,
                    color: headerTextColor,
                    nightMode: _nightMode,
                    onTap: _openGoToPageDialog,
                  ),
                  _FloatingCircleIcon(
                    icon: Icons.menu,
                    color: headerTextColor,
                    nightMode: _nightMode,
                    onTap: _openQuickMenuSheet,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        _nightMode ? const Color(0xFF14171A) : const Color(0xFFFFFDF8);
    final effectiveProgress = _shapedProgress(_rawProgress);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final destinationPage = _openingNextPage
                  ? (_currentPage + 1).clamp(1, _totalPages)
                  : (_currentPage - 1).clamp(1, _totalPages);
              final isCurling =
                  effectiveProgress > 0.0 && destinationPage != _currentPage;

              return GestureDetector(
                onHorizontalDragStart: (d) => _onHorizontalDragStart(d, height),
                onHorizontalDragUpdate: (d) =>
                    _onHorizontalDragUpdate(d, width, height),
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _totalPages,
                      onPageChanged: (index) {
                        final page = index + 1;
                        setState(() => _currentPage = page);
                        _saveLastPage(page);
                      },
                      itemBuilder: (context, index) {
                        return _buildFullMushafPage(
                          index + 1,
                          showControls: !isCurling,
                        );
                      },
                    ),
                    if (isCurling) ...[
                      // 1. الصفحة التالية/السابقة المكشوفة أسفل الجزء المنثني
                      Positioned.fill(
                        child: _buildFullMushafPage(
                          destinationPage,
                          showControls: false,
                        ),
                      ),
                      // 2. قص الجزء المتبقي من الصفحة الحالية ليظهر انثناء الجزء العلوي الأيسر
                      Positioned.fill(
                        child: ClipPath(
                          clipper: _TopLeftCornerCurlClipper(
                            progress: effectiveProgress,
                            openingNextPage: _openingNextPage,
                            pointerRatioY: _pointerRatioY,
                          ),
                          child: _buildFullMushafPage(
                            _currentPage,
                            showControls: false,
                          ),
                        ),
                      ),
                      // 3. رسم وجه/ظهر الورقة المنثنية من الأعلى لليسار والظل الواقعي تحتها
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: Size(width, height),
                            painter: _TopLeftCornerCurlPainter(
                              progress: effectiveProgress,
                              openingNextPage: _openingNextPage,
                              pointerRatioY: _pointerRatioY,
                              nightMode: _nightMode,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FloatingCircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool nightMode;
  final VoidCallback onTap;

  const _FloatingCircleIcon({
    required this.icon,
    required this.color,
    required this.nightMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: nightMode
          ? const Color(0xCC22272C)
          : const Color(0xCCF6F5F0),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

/// يقص الجزء المتبقي من الصفحة الحالية مع فتح انثناء من الجزء العلوي الأيسر نحو اليمين
class _TopLeftCornerCurlClipper extends CustomClipper<Path> {
  final double progress;
  final bool openingNextPage;
  final double pointerRatioY;

  const _TopLeftCornerCurlClipper({
    required this.progress,
    required this.openingNextPage,
    required this.pointerRatioY,
  });

  @override
  Path getClip(Size size) {
    final p = progress.clamp(0.0, 1.0);
    final path = Path();

    if (openingNextPage) {
      // انثناء يبدأ من الزاوية العلوية اليسرى ويتسع نحو اليمين والأسفل
      final topCutX = (size.width * (p * 0.92)).clamp(0.0, size.width);
      final leftCutY = (size.height * (0.14 + p * 0.72 * (0.4 + pointerRatioY)))
          .clamp(0.0, size.height);
      final ctrlX = (topCutX * 0.55 + size.width * 0.08 * math.sin(p * math.pi))
          .clamp(0.0, size.width);
      final ctrlY = (leftCutY * 0.55).clamp(0.0, size.height);

      path.moveTo(topCutX, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, leftCutY);
      path.quadraticBezierTo(ctrlX, ctrlY, topCutX, 0);
      path.close();
    } else {
      final foldX = (size.width * (1.0 - p)).clamp(0.0, size.width);
      path.moveTo(0, 0);
      path.lineTo(foldX, 0);
      path.quadraticBezierTo(
        foldX - 20 * math.sin(p * math.pi),
        size.height * pointerRatioY,
        foldX,
        size.height,
      );
      path.lineTo(0, size.height);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _TopLeftCornerCurlClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.openingNextPage != openingNextPage ||
        oldClipper.pointerRatioY != pointerRatioY;
  }
}

/// يرسم الظل الواقعي تحت الثنية والجزء المنثني بلون ورقي دافئ من الأعلى لليسار
class _TopLeftCornerCurlPainter extends CustomPainter {
  final double progress;
  final bool openingNextPage;
  final double pointerRatioY;
  final bool nightMode;

  const _TopLeftCornerCurlPainter({
    required this.progress,
    required this.openingNextPage,
    required this.pointerRatioY,
    required this.nightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0.0) return;

    final lift = math.sin(p * math.pi).clamp(0.1, 1.0);

    if (openingNextPage) {
      final topCutX = (size.width * (p * 0.92)).clamp(0.0, size.width);
      final leftCutY = (size.height * (0.14 + p * 0.72 * (0.4 + pointerRatioY)))
          .clamp(0.0, size.height);
      final ctrlX = (topCutX * 0.55 + size.width * 0.08 * lift)
          .clamp(0.0, size.width);
      final ctrlY = (leftCutY * 0.55).clamp(0.0, size.height);

      // حافة الانثناء نفسها
      final creasePath = Path()
        ..moveTo(topCutX, 0)
        ..quadraticBezierTo(ctrlX, ctrlY, 0, leftCutY);

      // ظل ناعم يقع أسفل الثنية على الصفحة التحتية
      final underShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: (0.28 * lift).clamp(0.04, 0.42))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18.0 + 16.0 * lift
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          8.0 + 10.0 * lift,
        );

      canvas.save();
      canvas.translate(4.0 * lift, 5.0 * lift);
      canvas.drawPath(creasePath, underShadowPaint);
      canvas.restore();

      // الجزء المنثني من الورقة مع تدرج لوني دافئ يحاكي ظهر الورقة
      final flapLiftX = (topCutX + size.width * 0.14 * lift)
          .clamp(0.0, size.width);
      final flapLiftY = (leftCutY * 0.25 + size.height * 0.04 * lift)
          .clamp(0.0, size.height);

      final flapPath = Path()
        ..moveTo(topCutX, 0)
        ..quadraticBezierTo(ctrlX, ctrlY, 0, leftCutY)
        ..lineTo(0, flapLiftY.clamp(0.0, leftCutY))
        ..quadraticBezierTo(
          (ctrlX + flapLiftX) * 0.5,
          (ctrlY * 0.45).clamp(0.0, size.height),
          flapLiftX,
          0,
        )
        ..close();

      final paperBackPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: nightMode
              ? [
                  const Color(0xFF2D333B).withValues(alpha: 0.92),
                  const Color(0xFF1D2227).withValues(alpha: 0.95),
                ]
              : [
                  const Color(0xFFFDF8EC).withValues(alpha: 0.96),
                  const Color(0xFFE5D5B5).withValues(alpha: 0.94),
                ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(flapPath, paperBackPaint);
    } else {
      final foldX = (size.width * (1.0 - p)).clamp(0.0, size.width);
      final shadowPath = Path()
        ..moveTo(foldX, 0)
        ..quadraticBezierTo(
          foldX - 20 * lift,
          size.height * pointerRatioY,
          foldX,
          size.height,
        );

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: (0.25 * lift).clamp(0.04, 0.38))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      canvas.drawPath(shadowPath, shadowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TopLeftCornerCurlPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.openingNextPage != openingNextPage ||
        oldDelegate.pointerRatioY != pointerRatioY ||
        oldDelegate.nightMode != nightMode;
  }
}
