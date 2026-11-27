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

  bool _isDragging = false;
  bool _openingNextPage = true;
  double _rawProgress = 0.0;
  double _dragStartX = 0.0;
  double _dragStartY = 0.0;
  double _pointerRatioY = 0.12;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, _totalPages);
    _pageController = PageController(initialPage: _currentPage - 1);
    _curlController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
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

  double _shapedProgress(double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (clamped <= 0.15) {
      return Curves.easeOut.transform(clamped / 0.15) * 0.15;
    } else if (clamped <= 0.55) {
      return 0.15 +
          Curves.easeInOutCubic.transform((clamped - 0.15) / 0.40) * 0.40;
    } else if (clamped <= 0.80) {
      return 0.55 +
          Curves.easeInOutCubic.transform((clamped - 0.55) / 0.25) * 0.25;
    } else {
      return 0.80 +
          Curves.easeOutCubic.transform((clamped - 0.80) / 0.20) * 0.20;
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
          height > 0 ? (_dragStartY / height).clamp(0.05, 0.85) : 0.12;
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
        ? (details.globalPosition.dy / height).clamp(0.05, 0.85)
        : 0.12;

    if (deltaX > 0 && _currentPage < _totalPages) {
      _openingNextPage = true;
      _pointerRatioY = ratioY;
      _rawProgress = (deltaX / width).clamp(0.0, 1.0);
      setState(() {});
    } else if (deltaX < 0 && _currentPage > 1) {
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

  // حساب خط الطيّ والزاوية المطوية قطرياً من الأعلى لليسار نحو اليمين والأسفل
  _CornerFoldData _computeFoldData(Size size, double progress) {
    final w = size.width;
    final h = size.height;
    final t = _openingNextPage ? progress : (1.0 - progress);
    final easedT = t.clamp(0.0, 1.0);

    // نقطة انطلاق الزاوية العلوية اليسرى أثناء رفعها نحو اليمين والأسفل
    final cornerX = (w * (0.14 + easedT * 0.92)).clamp(0.0, w * 1.15);
    final cornerY = (h * (0.06 + easedT * 0.78 * (0.55 + _pointerRatioY)))
        .clamp(0.0, h * 1.15);

    // خط الطي العمودي على منتصف المسافة بين الزاوية الأصلية (0,0) وموضعها الحالي
    final midX = cornerX * 0.5;
    final midY = cornerY * 0.5;

    // متجه خط الطي
    final dirX = -cornerY;
    final dirY = cornerX;
    final norm = math.sqrt(dirX * dirX + dirY * dirY).clamp(1.0, double.infinity);
    final ux = dirX / norm;
    final uy = dirY / norm;

    final span = (w + h) * 1.4;
    final foldStart = Offset(midX - ux * span, midY - uy * span);
    final foldEnd = Offset(midX + ux * span, midY + uy * span);

    // زاوية ميل الصفحة المنطوية حول خط الطي
    final foldAngle = math.atan2(uy, ux);

    return _CornerFoldData(
      foldStart: foldStart,
      foldEnd: foldEnd,
      liftedCorner: Offset(cornerX, cornerY),
      foldAngle: foldAngle,
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
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final destinationPage = _openingNextPage
                  ? (_currentPage + 1).clamp(1, _totalPages)
                  : (_currentPage - 1).clamp(1, _totalPages);
              final isFolding =
                  effectiveProgress > 0.0 && destinationPage != _currentPage;
              final foldData = _computeFoldData(size, effectiveProgress);
              final lift = math.sin(effectiveProgress * math.pi);

              return GestureDetector(
                onHorizontalDragStart: (d) =>
                    _onHorizontalDragStart(d, size.height),
                onHorizontalDragUpdate: (d) =>
                    _onHorizontalDragUpdate(d, size.width, size.height),
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
                          showControls: !isFolding,
                        );
                      },
                    ),
                    if (isFolding) ...[
                      // 1. الصفحة التالية/السابقة المكشوفة أسفل الجزء المنطوي
                      Positioned.fill(
                        child: _buildFullMushafPage(
                          destinationPage,
                          showControls: false,
                        ),
                      ),
                      // 2. ظل ناعم واقع على الصفحة السفلية بمحاذاة الطية
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: size,
                            painter: _FoldShadowPainter(
                              foldData: foldData,
                              lift: lift,
                            ),
                          ),
                        ),
                      ),
                      // 3. الجزء غير المنطوي من الصفحة الحالية
                      Positioned.fill(
                        child: ClipPath(
                          clipper: _UnfoldedAreaClipper(foldData: foldData),
                          child: _buildFullMushafPage(
                            _currentPage,
                            showControls: false,
                          ),
                        ),
                      ),
                      // 4. الجزء المنطوي من الصفحة الحالية مع انعكاس وتظليل الورقة
                      Positioned.fill(
                        child: ClipPath(
                          clipper: _FoldedFlapClipper(foldData: foldData),
                          child: Transform(
                            alignment: Alignment.topLeft,
                            transform: Matrix4.identity()
                              ..translate(
                                foldData.liftedCorner.dx,
                                foldData.liftedCorner.dy,
                              )
                              ..rotateZ(foldData.foldAngle * 0.55)
                              ..scale(-1.0, 1.0),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: size.width,
                                  height: size.height,
                                  child: _buildFullMushafPage(
                                    _currentPage,
                                    showControls: false,
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.black.withValues(
                                              alpha: (0.16 + 0.14 * lift)
                                                  .clamp(0.0, 0.38),
                                            ),
                                            Colors.white.withValues(
                                              alpha: 0.14,
                                            ),
                                            Colors.black.withValues(
                                              alpha: (0.24 + 0.16 * lift)
                                                  .clamp(0.0, 0.44),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

class _CornerFoldData {
  final Offset foldStart;
  final Offset foldEnd;
  final Offset liftedCorner;
  final double foldAngle;

  const _CornerFoldData({
    required this.foldStart,
    required this.foldEnd,
    required this.liftedCorner,
    required this.foldAngle,
  });
}

class _UnfoldedAreaClipper extends CustomClipper<Path> {
  final _CornerFoldData foldData;

  const _UnfoldedAreaClipper({required this.foldData});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(foldData.foldStart.dx, foldData.foldStart.dy)
      ..lineTo(foldData.foldEnd.dx, foldData.foldEnd.dy)
      ..lineTo(size.width * 2, size.height * 2)
      ..lineTo(size.width * 2, -size.height)
      ..lineTo(-size.width, size.height * 2)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _UnfoldedAreaClipper oldClipper) {
    return oldClipper.foldData != foldData;
  }
}

class _FoldedFlapClipper extends CustomClipper<Path> {
  final _CornerFoldData foldData;

  const _FoldedFlapClipper({required this.foldData});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(foldData.foldStart.dx, foldData.foldStart.dy)
      ..lineTo(foldData.foldEnd.dx, foldData.foldEnd.dy)
      ..lineTo(-size.width, -size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _FoldedFlapClipper oldClipper) {
    return oldClipper.foldData != foldData;
  }
}

class _FoldShadowPainter extends CustomPainter {
  final _CornerFoldData foldData;
  final double lift;

  const _FoldShadowPainter({
    required this.foldData,
    required this.lift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final foldPath = Path()
      ..moveTo(foldData.foldStart.dx, foldData.foldStart.dy)
      ..lineTo(foldData.foldEnd.dx, foldData.foldEnd.dy);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(
        alpha: (0.24 + 0.16 * lift).clamp(0.0, 0.42),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0 + 14.0 * lift
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        10.0 + 8.0 * lift,
      );

    canvas.save();
    canvas.translate(5.0, 6.0);
    canvas.drawPath(foldPath, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoldShadowPainter oldDelegate) {
    return oldDelegate.foldData != foldData || oldDelegate.lift != lift;
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
