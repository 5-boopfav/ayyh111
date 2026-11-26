import 'dart:math' as math;
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

  Map<int, QuranPageData> _pagesMap = const <int, QuranPageData>{};
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
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

  void _handleHorizontalDragStart(DragStartDetails details) {
    if (_turnController.isAnimating) return;
    _dragStartX = details.localPosition.dx;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (_turnController.isAnimating || width <= 0) return;
    final deltaX = details.localPosition.dx - _dragStartX;

    // السحب لليسار يقلب للصفحة التالية، والسحب لليمين يرجع للصفحة السابقة
    if (deltaX < 0 && _currentPage < _totalPages) {
      if (!_turningForward && _turnController.value == 0) {
        setState(() => _turningForward = true);
      }
      if (_turningForward) {
        _turnController.value = (-deltaX / (width * 0.75)).clamp(0.0, 1.0);
      }
    } else if (deltaX > 0 && _currentPage > 1) {
      if (_turningForward && _turnController.value == 0) {
        setState(() => _turningForward = false);
      }
      if (!_turningForward) {
        _turnController.value = (deltaX / (width * 0.75)).clamp(0.0, 1.0);
      }
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_turnController.isAnimating) return;
    final velocity = details.primaryVelocity ?? 0.0;
    if (_turnController.value >= 0.35 || velocity.abs() > 650) {
      _turnController.forward();
    } else {
      _turnController.reverse();
    }
  }

  void _openDailyWirdSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الورد اليومي: $_dailyWird صفحات',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [10, 20, 30, 60].map((pages) {
                      final selected = _dailyWird == pages;
                      return ChoiceChip(
                        label: Text('$pages صفحات'),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _dailyWird = pages);
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          color: const Color(0xFFC9A86A).withValues(alpha: 0.85),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD9BE8C).withValues(alpha: 0.7),
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
            const Divider(height: 12, color: Color(0xFFE6D5B0)),
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
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildVersesRichText(
                            pageData.verses,
                            primaryColor,
                          ),
                        ),
            ),
            const SizedBox(height: 4),
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
            fontSize: 18,
            color: Color(0xFF231D14),
            height: 1.95,
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

  Widget _buildRealisticFlipPage({
    required double progress,
    required bool forward,
    required int targetPage,
    required Color primaryColor,
  }) {
    // زاوية التقليب الواقعية من 0 إلى pi/2 عند منتصف القلب ثم إكمال الصفحة
    final angle = forward ? -(progress * math.pi) : (progress * math.pi);
    final isPastHalfway = progress >= 0.5;
    final shownPage = isPastHalfway ? targetPage : _currentPage;
    final effectiveAngle = isPastHalfway
        ? (forward ? (math.pi * (1.0 - progress)) : -(math.pi * (1.0 - progress)))
        : angle;

    final shadowOpacity = (math.sin(progress * math.pi) * 0.35).clamp(0.0, 0.35);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0014)
      ..rotateY(effectiveAngle);

    return Transform(
      alignment: forward ? Alignment.centerLeft : Alignment.centerRight,
      transform: transform,
      child: Stack(
        children: [
          Positioned.fill(
            child: _buildPageContent(shownPage, primaryColor),
          ),
          if (shadowOpacity > 0.01)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: forward ? Alignment.centerRight : Alignment.centerLeft,
                      end: forward ? Alignment.centerLeft : Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: shadowOpacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final percentText = (_progress * 100).toStringAsFixed(1);
    final targetPageNumber = _turningForward
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
            tooltip: 'الورد اليومي ($_dailyWird ص)',
            icon: const Icon(Icons.auto_stories),
            onPressed: _openDailyWirdSheet,
          ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                            fontSize: 13,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'صفحة $_currentPage / $_totalPages',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$percentText% • ص $_bookmarkedPage',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 5,
                        backgroundColor: Colors.grey.shade200,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onHorizontalDragStart: _handleHorizontalDragStart,
                      onHorizontalDragUpdate: (details) =>
                          _handleHorizontalDragUpdate(
                        details,
                        constraints.maxWidth,
                      ),
                      onHorizontalDragEnd: _handleHorizontalDragEnd,
                      child: AnimatedBuilder(
                        animation: _turnController,
                        builder: (context, _) {
                          final t = _turnController.value;
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: _buildPageContent(
                                  targetPageNumber,
                                  primaryColor,
                                ),
                              ),
                              if (t < 1.0)
                                Positioned.fill(
                                  child: _buildRealisticFlipPage(
                                    progress: t,
                                    forward: _turningForward,
                                    targetPage: targetPageNumber,
                                    primaryColor: primaryColor,
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
              const SizedBox(height: 8),
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
                  Text(
                    'اسحب يميناً أو يساراً للتقليب',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
