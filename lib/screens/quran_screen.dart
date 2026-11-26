import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  static const int _totalPages = 604;

  late final PageController _pageController;
  int _currentPage = 1;
  int _bookmarkedPage = 1;
  int _dailyWird = 20;
  bool _pageSoundEnabled = true;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(_handlePageScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page;
    if (page != null && mounted) {
      setState(() {
        _pageOffset = page;
      });
    }
  }

  int get _juz {
    final value = ((_currentPage - 1) ~/ 20) + 1;
    return value.clamp(1, 30);
  }

  double get _progress {
    return (_currentPage / _totalPages).clamp(0.0, 1.0);
  }

  void _playPageTurnSound() {
    if (!_pageSoundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  void _goToPage(int pageNumber, {bool playSound = true}) {
    final target = pageNumber.clamp(1, _totalPages);
    if (playSound) {
      _playPageTurnSound();
    }
    _pageController.animateToPage(
      target - 1,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
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

  Widget _buildRealisticPage(BuildContext context, int index, Color primaryColor) {
    final pageNum = index + 1;
    final juzNum = ((pageNum - 1) ~/ 20) + 1;
    final delta = index - _pageOffset;
    final clampedDelta = delta.clamp(-1.0, 1.0);
    final turnAngle = clampedDelta * 0.42;
    final shadowOpacity = (clampedDelta.abs() * 0.22).clamp(0.0, 0.22);

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0014)
      ..rotateY(turnAngle);

    return Transform(
      alignment: clampedDelta <= 0 ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFC9A86A).withValues(alpha: 0.75),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08 + shadowOpacity),
              blurRadius: 12,
              offset: Offset(clampedDelta * -6, 4),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFD9BE8C).withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الجزء $juzNum',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4B2B),
                    ),
                  ),
                  Text(
                    'صفحة $pageNum',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4B2B),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 46,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'مصحف المدينة النبوية — الصفحة $pageNum',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B2418),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اسحب يميناً أو يساراً لقلب الصفحة كالكتاب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                '$pageNum',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4B2B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final percentText = (_progress * 100).toStringAsFixed(1);

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
            height: 290,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPages,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index + 1;
                });
                _playPageTurnSound();
              },
              itemBuilder: (context, index) {
                return _buildRealisticPage(context, index, primaryColor);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _currentPage > 1
                    ? () => _goToPage(_currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('الصفحة السابقة'),
              ),
              ElevatedButton.icon(
                onPressed: _currentPage < _totalPages
                    ? () => _goToPage(_currentPage + 1)
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
