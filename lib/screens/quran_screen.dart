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

  static const List<String> _surahNames = <String>[
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام',
    'الأعراف', 'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف',
    'الرعد', 'إبراهيم', 'الحجر', 'النحل', 'الإسراء', 'الكهف',
    'مريم', 'طه', 'الأنبياء', 'الحج', 'المؤمنون', 'النور',
    'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس',
    'الصافات', 'ص', 'الزمر', 'غافر', 'فصلت', 'الشورى',
    'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف', 'محمد', 'الفتح',
    'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم', 'القمر',
    'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم',
    'الملك', 'القلم', 'الحاقة', 'المعارج', 'نوح', 'الجن',
    'المزمل', 'المدثر', 'القيامة', 'الإنسان', 'المرسلات', 'النبأ',
    'النازعات', 'عبس', 'التكوير', 'الإنفطار', 'المطففين', 'الإنشقاق',
    'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
    'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق',
    'القدر', 'البينة', 'الزلزلة', 'العاديات', 'القارعة', 'التكاثر',
    'العصر', 'الهمزة', 'الفيل', 'قريش', 'الماعون', 'الكوثر',
    'الكافرون', 'النصر', 'المسد', 'الإخلاص', 'الفلق', 'الناس',
  ];

  late final AnimationController _curlController;
  int _currentPage = 1;
  int _bookmarkedPage = 1;
  int _dailyWird = 20;
  bool _pageSoundEnabled = true;
  bool _nightMode = false;
  double _fontSize = 18.0;
  bool _turningForward = true;
  Offset _dragStart = Offset.zero;
  Offset _dragCurrent = Offset.zero;
  Size _pageBoxSize = Size.zero;

  Map<int, QuranPageData> _pagesMap = const <int, QuranPageData>{};
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _curlController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addStatusListener(_onCurlStatus);
    _loadLocalPages();
  }

  String _resolveSurahName(int surahNumber, String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isNotEmpty && !RegExp(r'^\d+$').hasMatch(trimmed)) {
      return trimmed.startsWith('سورة') ? trimmed : 'سورة $trimmed';
    }
    if (surahNumber >= 1 && surahNumber <= _surahNames.length) {
      return 'سورة ${_surahNames[surahNumber - 1]}';
    }
    return 'سورة $surahNumber';
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

  void _onCurlStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (_turningForward && _currentPage < _totalPages) {
          _currentPage += 1;
        } else if (!_turningForward && _currentPage > 1) {
          _currentPage -= 1;
        }
      });
      _playPageTurnSound();
      _curlController.reset();
    }
  }

  @override
  void dispose() {
    _curlController.removeStatusListener(_onCurlStatus);
    _curlController.dispose();
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
    if (_curlController.isAnimating) return;
    if (forward && _currentPage >= _totalPages) return;
    if (!forward && _currentPage <= 1) return;

    setState(() {
      _turningForward = forward;
      if (_pageBoxSize != Size.zero) {
        _dragStart = forward
            ? Offset(_pageBoxSize.width, _pageBoxSize.height * 0.85)
            : Offset(0, _pageBoxSize.height * 0.85);
        _dragCurrent = _dragStart;
      }
    });
    _curlController.forward(from: 0.0);
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

  void _openGoToPageDialog() {
    final controller = TextEditingController(text: '$_currentPage');
    showDialog<void>(
      context: context,
      builder: (ctx) {
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                Navigator.pop(ctx);
                if (parsed != null) {
                  _goToPage(parsed);
                }
              },
              child: const Text('انتقال'),
            ),
          ],
        );
      },
    );
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

  void _handlePanStart(DragStartDetails details) {
    if (_curlController.isAnimating) return;
    _dragStart = details.localPosition;
    _dragCurrent = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (_curlController.isAnimating || size.width <= 0) return;
    _dragCurrent = details.localPosition;
    final dx = _dragCurrent.dx - _dragStart.dx;

    if (dx < 0 && _currentPage < _totalPages) {
      if (!_turningForward && _curlController.value == 0) {
        setState(() => _turningForward = true);
      }
      if (_turningForward) {
        _curlController.value = (-dx / (size.width * 0.72)).clamp(0.0, 1.0);
      }
    } else if (dx > 0 && _currentPage > 1) {
      if (_turningForward && _curlController.value == 0) {
        setState(() => _turningForward = false);
      }
      if (!_turningForward) {
        _curlController.value = (dx / (size.width * 0.72)).clamp(0.0, 1.0);
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_curlController.isAnimating) return;
    final vx = details.velocity.pixelsPerSecond.dx;
    if (_curlController.value >= 0.35 || vx.abs() > 650) {
      _curlController.forward();
    } else {
      _curlController.reverse();
    }
  }

  void _openReadingSettingsSheet() {
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
                  const Text(
                    'إعدادات القراءة والورد',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('الوضع الليلي للمصحف'),
                    value: _nightMode,
                    onChanged: (val) {
                      setState(() => _nightMode = val);
                      setSheetState(() {});
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('حجم الخط: ${_fontSize.toInt()}'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _fontSize = (_fontSize - 2).clamp(14.0, 30.0);
                              });
                              setSheetState(() {});
                            },
                            icon: const Icon(Icons.text_decrease),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _fontSize = (_fontSize + 2).clamp(14.0, 30.0);
                              });
                              setSheetState(() {});
                            },
                            icon: const Icon(Icons.text_increase),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'الورد اليومي: $_dailyWird صفحات',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
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
      final firstVerse = pageData.verses.first;
      headerSurah =
          _resolveSurahName(firstVerse.surahNumber, firstVerse.surahName);
    }

    final paperColor =
        _nightMode ? const Color(0xFF1A1D21) : const Color(0xFFFFFDF6);
    final borderColor = _nightMode
        ? const Color(0xFF6F5D3A).withValues(alpha: 0.75)
        : const Color(0xFFC9A86A).withValues(alpha: 0.85);
    final metaColor =
        _nightMode ? const Color(0xFFD5C39C) : const Color(0xFF5D4B2B);

    return Container(
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _nightMode ? 0.35 : 0.12),
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
          border: Border.all(color: borderColor.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الجزء $juzNum',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: metaColor,
                  ),
                ),
                Text(
                  headerSurah,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _nightMode ? const Color(0xFFE7C77C) : primaryColor,
                  ),
                ),
                Text(
                  'صفحة $pageNumber',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: metaColor,
                  ),
                ),
              ],
            ),
            Divider(height: 12, color: borderColor.withValues(alpha: 0.5)),
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
                              color: _nightMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: metaColor,
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
    final verseColor =
        _nightMode ? const Color(0xFFF3EFE6) : const Color(0xFF231D14);
    final surahBannerColor =
        _nightMode ? const Color(0xFFE7C77C) : primaryColor;
    final ayahNumColor =
        _nightMode ? const Color(0xFFD4A853) : const Color(0xFF8A6829);

    for (final verse in verses) {
      if (verse.surahNumber != currentSurahNumber) {
        currentSurahNumber = verse.surahNumber;
        final surahLabel =
            _resolveSurahName(verse.surahNumber, verse.surahName);
        spans.add(
          TextSpan(
            text: '\n$surahLabel\n',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize - 2,
              color: surahBannerColor,
              height: 1.8,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: '${verse.text} ',
          style: TextStyle(
            fontSize: _fontSize,
            color: verseColor,
            height: 1.95,
          ),
        ),
      );
      spans.add(
        TextSpan(
          text: '(${verse.ayahNumber}) ',
          style: TextStyle(
            fontSize: (_fontSize - 4).clamp(11.0, 24.0),
            fontWeight: FontWeight.bold,
            color: ayahNumColor,
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
            tooltip: 'انتقال لصفحة',
            icon: const Icon(Icons.search),
            onPressed: _openGoToPageDialog,
          ),
          IconButton(
            tooltip: 'إعدادات القراءة',
            icon: const Icon(Icons.tune),
            onPressed: _openReadingSettingsSheet,
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
                  color: _nightMode ? const Color(0xFF23272E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _nightMode
                        ? const Color(0xFF343A46)
                        : Colors.grey.shade200,
                  ),
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
                            color: _nightMode
                                ? const Color(0xFFE7C77C)
                                : primaryColor,
                          ),
                        ),
                        Text(
                          'صفحة $_currentPage / $_totalPages',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _nightMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '$percentText% • ص $_bookmarkedPage',
                          style: TextStyle(
                            color: _nightMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
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
                        backgroundColor: _nightMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        color: _nightMode
                            ? const Color(0xFFE7C77C)
                            : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _pageBoxSize =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onPanStart: _handlePanStart,
                      onPanUpdate: (details) =>
                          _handlePanUpdate(details, _pageBoxSize),
                      onPanEnd: _handlePanEnd,
                      child: AnimatedBuilder(
                        animation: _curlController,
                        builder: (context, _) {
                          final progress = _curlController.value;
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: _buildPageContent(
                                  targetPageNumber,
                                  primaryColor,
                                ),
                              ),
                              Positioned.fill(
                                child: ClipPath(
                                  clipper: _PageCurlClipper(
                                    progress: progress,
                                    forward: _turningForward,
                                    dragY: _dragCurrent.dy,
                                  ),
                                  child: _buildPageContent(
                                    _currentPage,
                                    primaryColor,
                                  ),
                                ),
                              ),
                              if (progress > 0.005 && progress < 0.995)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _PageCurlFoldPainter(
                                        progress: progress,
                                        forward: _turningForward,
                                        dragY: _dragCurrent.dy,
                                        nightMode: _nightMode,
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
                    'اسحب الورقة لطيّها • ورد $_dailyWird ص',
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

class _PageCurlClipper extends CustomClipper<Path> {
  final double progress;
  final bool forward;
  final double dragY;

  const _PageCurlClipper({
    required this.progress,
    required this.forward,
    required this.dragY,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    if (progress <= 0.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }
    if (progress >= 1.0) {
      return path;
    }

    final remaining = (1.0 - progress).clamp(0.0, 1.0);
    final curveBulge = math.sin(progress * math.pi) * 38.0;
    final safeY = dragY <= 0 ? size.height * 0.85 : dragY.clamp(40.0, size.height - 40.0);
    final bendOffset = (safeY / size.height - 0.5) * curveBulge;

    if (forward) {
      // تبقى الصفحة الحالية في الجهة اليسرى وتنطوي من اليمين نحو اليسار
      final edgeX = size.width * remaining;
      path.moveTo(0, 0);
      path.lineTo((edgeX + bendOffset).clamp(0.0, size.width), 0);
      path.quadraticBezierTo(
        (edgeX - curveBulge * 0.65).clamp(0.0, size.width),
        safeY,
        (edgeX - bendOffset).clamp(0.0, size.width),
        size.height,
      );
      path.lineTo(0, size.height);
      path.close();
    } else {
      // تنطوي من اليسار نحو اليمين
      final edgeX = size.width * progress;
      path.moveTo((edgeX + bendOffset).clamp(0.0, size.width), 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo((edgeX - bendOffset).clamp(0.0, size.width), size.height);
      path.quadraticBezierTo(
        (edgeX + curveBulge * 0.65).clamp(0.0, size.width),
        safeY,
        (edgeX + bendOffset).clamp(0.0, size.width),
        0,
      );
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _PageCurlClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.forward != forward ||
        oldClipper.dragY != dragY;
  }
}

class _PageCurlFoldPainter extends CustomPainter {
  final double progress;
  final bool forward;
  final double dragY;
  final bool nightMode;

  const _PageCurlFoldPainter({
    required this.progress,
    required this.forward,
    required this.dragY,
    required this.nightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final remaining = (1.0 - progress).clamp(0.0, 1.0);
    final curveBulge = math.sin(progress * math.pi) * 38.0;
    final safeY = dragY <= 0 ? size.height * 0.85 : dragY.clamp(40.0, size.height - 40.0);
    final bendOffset = (safeY / size.height - 0.5) * curveBulge;
    final flapWidth = (size.width * 0.16 * math.sin(progress * math.pi)).clamp(14.0, 75.0);

    final edgeX = forward ? size.width * remaining : size.width * progress;
    final topX = (edgeX + bendOffset).clamp(0.0, size.width);
    final midX = forward
        ? (edgeX - curveBulge * 0.65).clamp(0.0, size.width)
        : (edgeX + curveBulge * 0.65).clamp(0.0, size.width);
    final botX = (edgeX - bendOffset).clamp(0.0, size.width);

    final flapPath = Path()
      ..moveTo(topX, 0)
      ..quadraticBezierTo(midX, safeY, botX, size.height);

    if (forward) {
      flapPath
        ..lineTo((botX + flapWidth).clamp(0.0, size.width), size.height)
        ..quadraticBezierTo(
          (midX + flapWidth * 0.8).clamp(0.0, size.width),
          safeY,
          (topX + flapWidth).clamp(0.0, size.width),
          0,
        );
    } else {
      flapPath
        ..lineTo((botX - flapWidth).clamp(0.0, size.width), size.height)
        ..quadraticBezierTo(
          (midX - flapWidth * 0.8).clamp(0.0, size.width),
          safeY,
          (topX - flapWidth).clamp(0.0, size.width),
          0,
        );
    }
    flapPath.close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: forward ? Alignment.centerLeft : Alignment.centerRight,
        end: forward ? Alignment.centerRight : Alignment.centerLeft,
        colors: nightMode
            ? const [
                Color(0x66000000),
                Color(0xB33B3426),
                Color(0x441B1914),
              ]
            : const [
                Color(0x55000000),
                Color(0xE6F6ECD4),
                Color(0x33D8C69E),
              ],
      ).createShader(rect);

    canvas.drawPath(flapPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PageCurlFoldPainter oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.forward != forward ||
        oldClipper.dragY != dragY ||
        oldClipper.nightMode != nightMode;
  }
}
