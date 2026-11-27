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

  // حالة حركة انحناء الصفحة أثناء السحب
  bool _isDragging = false;
  bool _dragForward = true;
  double _dragProgress = 0.0;
  double _dragStartX = 0.0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, _totalPages);
    _pageController = PageController(initialPage: _currentPage - 1);
    _curlController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (!_isDragging) {
          setState(() {
            _dragProgress = _curlController.value;
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
      _dragProgress = 0.0;
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

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_curlController.isAnimating) {
      _curlController.stop();
    }
    setState(() {
      _isDragging = true;
      _dragStartX = details.globalPosition.dx;
      _dragProgress = 0.0;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (!_isDragging || width <= 0) return;
    final deltaX = details.globalPosition.dx - _dragStartX;

    // في الاتجاه العربي RTL: السحب لليسار ينتقل للصفحة التالية، ولليمين للسابقة
    if (deltaX < 0 && _currentPage < _totalPages) {
      _dragForward = true;
      _dragProgress = (-deltaX / width).clamp(0.0, 1.0);
      setState(() {});
    } else if (deltaX > 0 && _currentPage > 1) {
      _dragForward = false;
      _dragProgress = (deltaX / width).clamp(0.0, 1.0);
      setState(() {});
    } else {
      setState(() => _dragProgress = 0.0);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    final velocity = details.primaryVelocity ?? 0.0;
    final shouldComplete = _dragProgress > 0.35 || velocity.abs() > 700;
    final targetPage = _dragForward
        ? (_currentPage + 1).clamp(1, _totalPages)
        : (_currentPage - 1).clamp(1, _totalPages);

    _isDragging = false;

    if (shouldComplete && targetPage != _currentPage) {
      _curlController.forward(from: _dragProgress).then((_) {
        if (!mounted) return;
        _goToPage(targetPage);
        _curlController.reset();
      });
    } else {
      _curlController.reverse(from: _dragProgress).then((_) {
        if (!mounted) return;
        setState(() => _dragProgress = 0.0);
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
    final wirdEndPage = (_currentPage + _dailyWirdPages - 1).clamp(1, _totalPages);

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

  Widget _buildFullMushafPage(int pageNumber, Color primaryColor) {
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor =
        _nightMode ? const Color(0xFF14171A) : const Color(0xFFFFFDF8);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final nextPage = _dragForward
                  ? (_currentPage + 1).clamp(1, _totalPages)
                  : (_currentPage - 1).clamp(1, _totalPages);

              return GestureDetector(
                onHorizontalDragStart: _onHorizontalDragStart,
                onHorizontalDragUpdate: (d) =>
                    _onHorizontalDragUpdate(d, width),
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
                        return _buildFullMushafPage(index + 1, primaryColor);
                      },
                    ),
                    if (_dragProgress > 0.0 && nextPage != _currentPage) ...[
                      Positioned.fill(
                        child: _buildFullMushafPage(nextPage, primaryColor),
                      ),
                      Positioned.fill(
                        child: ClipPath(
                          clipper: _PageCurlClipper(
                            progress: _dragProgress,
                            forward: _dragForward,
                          ),
                          child: _buildFullMushafPage(
                            _currentPage,
                            primaryColor,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: Size(width, height),
                            painter: _PageCurlFoldPainter(
                              progress: _dragProgress,
                              forward: _dragForward,
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

class _PageCurlClipper extends CustomClipper<Path> {
  final double progress;
  final bool forward;

  const _PageCurlClipper({
    required this.progress,
    required this.forward,
  });

  @override
  Path getClip(Size size) {
    final p = progress.clamp(0.0, 1.0);
    final path = Path();

    if (forward) {
      final foldX = size.width * (1.0 - p);
      path.moveTo(0, 0);
      path.lineTo(foldX, 0);
      path.quadraticBezierTo(
        foldX - 24 * math.sin(p * math.pi),
        size.height * 0.5,
        foldX,
        size.height,
      );
      path.lineTo(0, size.height);
      path.close();
    } else {
      final foldX = size.width * p;
      path.moveTo(foldX, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(foldX, size.height);
      path.quadraticBezierTo(
        foldX + 24 * math.sin(p * math.pi),
        size.height * 0.5,
        foldX,
        0,
      );
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _PageCurlClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.forward != forward;
  }
}

class _PageCurlFoldPainter extends CustomPainter {
  final double progress;
  final bool forward;
  final bool nightMode;

  const _PageCurlFoldPainter({
    required this.progress,
    required this.forward,
    required this.nightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0.0) return;

    final foldX = forward ? size.width * (1.0 - p) : size.width * p;
    final curveOffset = forward
        ? -24 * math.sin(p * math.pi)
        : 24 * math.sin(p * math.pi);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: nightMode ? 0.45 : 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final path = Path()
      ..moveTo(foldX, 0)
      ..quadraticBezierTo(
        foldX + curveOffset,
        size.height * 0.5,
        foldX,
        size.height,
      );

    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _PageCurlFoldPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.forward != forward ||
        oldDelegate.nightMode != nightMode;
  }
}
