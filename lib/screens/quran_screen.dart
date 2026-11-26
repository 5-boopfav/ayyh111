import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/islamic_models.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalPages = 604;

  late final AnimationController _turnController;
  int _currentPage = 1;
  int _bookmarkedPage = 1;
  int _dailyWird = 20;
  bool _pageSoundEnabled = true;
  bool _turningForward = true;
  double _dragStartX = 0.0;
  double _dragStartY = 0.0;

  Map<int, QuranPageData> _pagesMap = const <int, QuranPageData>{};
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addStatusListener(_onTurnAnimationStatus);
    _loadLocalPages();
  }

  Future<void> _loadLocalPages() async {
    final data = await LocalIslamicRepository.instance.loadQuranPages();
    if (!mounted) return;

    final Map<int, QuranPageData> loadedMap =
        data is Map<int, QuranPageData> ? data : const <int, QuranPageData>{};

    int initialPage = _currentPage;
    if (loadedMap.isNotEmpty && !loadedMap.containsKey(initialPage)) {
      final sortedPages = loadedMap.keys.toList()..sort();
      initialPage = sortedPages.first;
    }

    setState(() {
      _pagesMap = loadedMap;
      _currentPage = initialPage;
      _isLoadingData = false;
    });
  }

  void _onTurnAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (_turningForward && _currentPage < _totalPages) {
          _currentPage += 1;
        } else if (!_turningForward && _currentPage > 1) {
          _currentPage -= 1;
        }
      });
      _playPageTurnSound();
      _turnController.reset();
    }
  }

  @override
  void dispose() {
    _turnController.removeStatusListener(_onTurnAnimationStatus);
    _turnController.dispose();
    super.dispose();
  }

  int get _juz {
    final pageData = _pagesMap[_currentPage];
    if (pageData != null) return pageData.juz.clamp(1, 30);
    return (((_currentPage - 1) ~/ 20) + 1).clamp(1, 30);
  }

  double get _progress {
    return (_currentPage / _totalPages).clamp(0.0, 1.0);
  }

  void _playPageTurnSound() {
    if (!_pageSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  void _triggerTurn({required bool forward}) {
    if (_turnController.isAnimating) return;
    if (forward && _currentPage >= _totalPages) return;
    if (!forward && _currentPage <= 1) return;

    setState(() {
      _turningForward = forward;
    });
    _turnController.forward(from: 0.0);
  }

  void _goToPage(int pageNumber) {
    final target = pageNumber.clamp(1, _totalPages);
    if (target == _currentPage) return;
    setState(() {
      _turningForward = target > _currentPage;
      _currentPage = target;
    });
    _playPageTurnSound();
  }

  void _saveBookmark() {
    setState(() {
      _bookmarkedPage = _currentPage;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ العلامة عند الصفحة $_bookmarkedPage.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goToBookmark() {
    _goToPage(_bookmarkedPage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الانتقال إلى العلامة المحفوظة: الصفحة $_bookmarkedPage.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePanStart(DragStartDetails details, Size boxSize) {
    _dragStartX = details.localPosition.dx;
    _dragStartY = details.localPosition.dy;
    final inTopQuarter = details.localPosition.dy <= boxSize.height * 0.25;
    if (inTopQuarter && !_turnController.isAnimating) {
      setState(() {
        _turningForward = details.localPosition.dx > boxSize.width * 0.5;
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size boxSize) {
    if (_turnController.isAnimating) return;
    final dx = (details.localPosition.dx - _dragStartX).abs();
    final dy = (details.localPosition.dy - _dragStartY).abs();
    final progress =
        ((dx + dy * 0.5) / (boxSize.width * 0.85)).clamp(0.0, 1.0);
    _turnController.value = progress;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_turnController.isAnimating) return;
    if (_turnController.value >= 0.35) {
      _turnController.forward();
    } else {
      _turnController.reverse();
    }
  }

  Widget _buildPageContent(int pageNumber, Color primaryColor) {
    final pageData = _pagesMap[pageNumber];
    final juzNum =
        pageData?.juz ?? (((pageNumber - 1) ~/ 20) + 1).clamp(1, 30);

    String headerSurah = 'الختمة';
    if (pageData != null && pageData.verses.isNotEmpty) {
      final firstSurah = pageData.verses.first.surahName.trim();
      headerSurah = firstSurah.isNotEmpty
          ? firstSurah
          : 'سورة ${pageData.verses.first.surahNumber}';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFC9A86A).withValues(alpha: 0.8),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD9BE8C).withValues(alpha: 0.65),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الجزء $juzNum',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4B2B),
                  ),
                ),
                Text(
                  headerSurah,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'صفحة $pageNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4B2B),
                  ),
                ),
              ],
            ),
            const Divider(height: 14, color: Color(0xFFE6D5B0)),
            Expanded(
              child: _isLoadingData
                  ? const Center(child: CircularProgressIndicator())
                  : (pageData == null || pageData.verses.isEmpty)
                      ? Center(
                          child: Text(
                            'بانتظار إضافة ملف البيانات المحلي الموثوق (assets/data/quran_pages.json) لعرض الصفحة $pageNumber كاملة بدون إنترنت.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: _buildVersesRichText(
                            pageData.verses,
                            primaryColor,
                          ),
                        ),
            ),
            const SizedBox(height: 6),
            Text(
              '$pageNumber',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4B2B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesRichText(List<QuranVerseItem> verses, Color primaryColor) {
    final List<InlineSpan> spans = <InlineSpan>[];
    int? currentSurahNumber;

    for (final verse in verses) {
      final surahLabel = verse.surahName.trim().isNotEmpty
          ? 'سورة ${verse.surahName.trim()}'
          : 'سورة ${verse.surahNumber}';

      if (verse.surahNumber != currentSurahNumber) {
        currentSurahNumber = verse.surahNumber;
        spans.add(
          TextSpan(
            text: '\n$surahLabel\n',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: primaryColor,
              height: 1.8,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: '${verse.text} ',
          style: const TextStyle(
            fontSize: 17,
            color: Color(0xFF231D14),
            height: 1.9,
          ),
        ),
      );
      spans.add(
        TextSpan(
          text: '(${verse.ayahNumber}) ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8A6829),
          ),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final percentText = (_progress * 100).toStringAsFixed(1);
    final nextPageNumber = _turningForward
        ? (_currentPage < _totalPages ? _currentPage + 1 : _currentPage)
        : (_currentPage > 1 ? _currentPage - 1 : _currentPage);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الختمة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: _pageSoundEnabled ? 'إيقاف صوت القلب' : 'تفعيل صوت القلب',
            icon: Icon(
              _pageSoundEnabled ? Icons.volume_up : Icons.volume_off,
            ),
            onPressed: () {
              setState(() {
                _pageSoundEnabled = !_pageSoundEnabled;
              });
            },
          ),
          IconButton(
            tooltip: 'حفظ العلامة',
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: _saveBookmark,
          ),
          IconButton(
            tooltip: 'الذهاب إلى العلامة',
            icon: const Icon(Icons.bookmark),
            onPressed: _goToBookmark,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الجزء $_juz',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      'صفحة $_currentPage / $_totalPages',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإنجاز: $percentText%',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    Text(
                      'العلامة: ص $_bookmarkedPage',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 360,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxSize =
                    Size(constraints.maxWidth, constraints.maxHeight);
                return GestureDetector(
                  onPanStart: (details) => _handlePanStart(details, boxSize),
                  onPanUpdate: (details) => _handlePanUpdate(details, boxSize),
                  onPanEnd: _handlePanEnd,
                  child: AnimatedBuilder(
                    animation: _turnController,
                    builder: (context, _) {
                      final t = _turnController.value;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: _buildPageContent(
                              nextPageNumber,
                              primaryColor,
                            ),
                          ),
                          Positioned.fill(
                            child: ClipPath(
                              clipper: _TopQuarterSweepClipper(
                                progress: t,
                                forward: _turningForward,
                              ),
                              child: _buildPageContent(
                                _currentPage,
                                primaryColor,
                              ),
                            ),
                          ),
                          if (t > 0.01)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _PageFoldEdgePainter(
                                    progress: t,
                                    forward: _turningForward,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentPage > 1
                    ? () => _triggerTurn(forward: false)
                    : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('الصفحة السابقة'),
              ),
              ElevatedButton.icon(
                onPressed: _currentPage < _totalPages
                    ? () => _triggerTurn(forward: true)
                    : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('الصفحة التالية'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الورد اليومي: $_dailyWird صفحات',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [10, 20, 30, 60].map((pages) {
                    final selected = _dailyWird == pages;
                    return ChoiceChip(
                      label: Text('$pages صفحات'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _dailyWird = pages;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopQuarterSweepClipper extends CustomClipper<Path> {
  final double progress;
  final bool forward;

  const _TopQuarterSweepClipper({
    required this.progress,
    required this.forward,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    if (progress <= 0.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    final topQuarterHeight = size.height * 0.25;
    final sweepX =
        forward ? size.width * (1.0 - progress) : size.width * progress;

    path.moveTo(0, 0);
    if (forward) {
      path.lineTo(sweepX, 0);
      path.lineTo(sweepX, topQuarterHeight);
      path.lineTo(size.width, topQuarterHeight);
    } else {
      path.lineTo(sweepX, 0);
      path.lineTo(sweepX, topQuarterHeight);
      path.lineTo(0, topQuarterHeight);
    }
    path.lineTo(size.width, topQuarterHeight);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TopQuarterSweepClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.forward != forward;
  }
}

class _PageFoldEdgePainter extends CustomPainter {
  final double progress;
  final bool forward;

  const _PageFoldEdgePainter({
    required this.progress,
    required this.forward,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final topQuarterHeight = size.height * 0.25;
    final edgeX =
        forward ? size.width * (1.0 - progress) : size.width * progress;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.14)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(edgeX, 0),
      Offset(edgeX, topQuarterHeight),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(0, topQuarterHeight),
      Offset(size.width, topQuarterHeight),
      Paint()
        ..color = const Color(0xFFC9A86A).withValues(alpha: 0.45)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PageFoldEdgePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.forward != forward;
  }
}
