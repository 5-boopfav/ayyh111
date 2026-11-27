import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/islamic_models.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  List<HisnCategory> _categories = const <HisnCategory>[];
  int _selectedCategoryIndex = 0;
  int _currentItemIndex = 0;
  int _tapCount = 0;
  bool _isLoading = true;
  bool _showShortOnly = false;
  bool _showReference = false;

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  Future<void> _loadAzkar() async {
    final loaded = await LocalIslamicRepository.instance.loadHisnAlMuslim();
    if (!mounted) return;

    final list =
        loaded is List<HisnCategory> ? loaded : const <HisnCategory>[];
    setState(() {
      _categories = list;
      _selectedCategoryIndex = 0;
      _currentItemIndex = 0;
      _tapCount = 0;
      _isLoading = false;
    });
  }

  List<HisnItem> _visibleItems(HisnCategory category) {
    if (!_showShortOnly) return category.items;
    final shortList = category.items
        .where((item) => item.text.trim().length <= 140)
        .toList();
    return shortList.isNotEmpty ? shortList : category.items;
  }

  String _extractBenefitOrNote(String rawText) {
    final bracketMatch = RegExp(r'\[([^\]]+)\]').firstMatch(rawText);
    if (bracketMatch != null) {
      return '[${bracketMatch.group(1)!.trim()}]';
    }
    final parenMatch = RegExp(r'\(([^()]*مرَّات[^()]*|[^()]*مرات[^()]*)\)')
        .firstMatch(rawText);
    if (parenMatch != null) {
      return '(${parenMatch.group(1)!.trim()})';
    }
    return '';
  }

  String _cleanMainDhikrText(String rawText, String extractedNote) {
    var cleaned = rawText;
    if (extractedNote.isNotEmpty) {
      cleaned = cleaned.replaceAll(extractedNote, '');
    }
    return cleaned.trim();
  }

  void _onCounterTap(int targetCount, int totalItems) {
    final safeTarget = targetCount > 0 ? targetCount : 1;
    final nextTap = _tapCount + 1;

    if (nextTap >= safeTarget) {
      HapticFeedback.mediumImpact();
      setState(() {
        if (_currentItemIndex + 1 < totalItems) {
          _currentItemIndex += 1;
          _tapCount = 0;
          _showReference = false;
        } else {
          _tapCount = safeTarget;
        }
      });
    } else {
      HapticFeedback.lightImpact();
      setState(() {
        _tapCount = nextTap;
      });
    }
  }

  void _goToItem(int index) {
    setState(() {
      _currentItemIndex = index;
      _tapCount = 0;
      _showReference = false;
    });
  }

  void _resetCurrentDhikr() {
    HapticFeedback.selectionClick();
    setState(() {
      _tapCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = (_categories.isNotEmpty &&
            _selectedCategoryIndex < _categories.length)
        ? _categories[_selectedCategoryIndex]
        : null;

    final items =
        currentCategory != null ? _visibleItems(currentCategory) : const <HisnItem>[];
    final safeIndex =
        items.isEmpty ? 0 : _currentItemIndex.clamp(0, items.length - 1);
    final HisnItem? currentItem = items.isNotEmpty ? items[safeIndex] : null;
    final targetCount =
        (currentItem != null && currentItem.count > 0) ? currentItem.count : 1;

    final noteText =
        currentItem != null ? _extractBenefitOrNote(currentItem.text) : '';
    final mainText = currentItem != null
        ? _cleanMainDhikrText(currentItem.text, noteText)
        : '';

    const accentTeal = Color(0xFF0097B2);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          currentCategory?.category ?? 'الأذكار',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Color(0xFF1A1D1F),
          ),
        ),
        actions: [
          if (_categories.length > 1)
            PopupMenuButton<int>(
              tooltip: 'اختيار الباب',
              icon: const Icon(Icons.menu_book_outlined, color: accentTeal),
              onSelected: (catIndex) {
                setState(() {
                  _selectedCategoryIndex = catIndex;
                  _currentItemIndex = 0;
                  _tapCount = 0;
                  _showReference = false;
                });
              },
              itemBuilder: (context) => [
                for (int i = 0; i < _categories.length; i++)
                  PopupMenuItem<int>(
                    value: i,
                    child: Text(_categories[i].category),
                  ),
              ],
            ),
          IconButton(
            tooltip: 'تصفير العداد الحالي',
            icon: const Icon(Icons.replay, color: Color(0xFF4A5056)),
            onPressed: currentItem == null ? null : _resetCurrentDhikr,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (currentItem == null || items.isEmpty)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'بانتظار إضافة ملف البيانات المحلي الموثوق (assets/data/hisn_al_muslim.json) لعرض الأذكار بدون إنترنت.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // شريط التبديل العلوي: الأذكار الكاملة / الأذكار المختصرة
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEEEF),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showShortOnly = false;
                                      _currentItemIndex = 0;
                                      _tapCount = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_showShortOnly
                                          ? accentTeal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'الأذكار الكاملة',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: !_showShortOnly
                                            ? Colors.white
                                            : const Color(0xFF4F565C),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showShortOnly = true;
                                      _currentItemIndex = 0;
                                      _tapCount = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _showShortOnly
                                          ? accentTeal
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'الأذكار المختصرة',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: _showShortOnly
                                            ? Colors.white
                                            : const Color(0xFF4F565C),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // منطقة نص الذكر والفضل وزر إظهار الدليل
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Column(
                            children: [
                              Text(
                                mainText,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  height: 1.9,
                                  color: Color(0xFF14171A),
                                ),
                              ),
                              if (noteText.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  noteText,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2B2F33),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showReference = !_showReference;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFECEEEF),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                icon: Icon(
                                  _showReference
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: const Color(0xFF4A5056),
                                ),
                                label: const Text(
                                  'اظهار الدليل',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A5056),
                                  ),
                                ),
                              ),
                              if (_showReference) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'الباب: ${currentCategory!.category} • رقم الذكر في الباب: ${safeIndex + 1} من ${items.length}',
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // شريط تنقل سريع بين أذكار الباب
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 6),
                          itemBuilder: (context, idx) {
                            final active = idx == safeIndex;
                            return GestureDetector(
                              onTap: () => _goToItem(idx),
                              child: Container(
                                width: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: active
                                      ? accentTeal
                                      : const Color(0xFFE7EAEC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: active
                                        ? Colors.white
                                        : const Color(0xFF4A5056),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // المنطقة السفلية: إجمالي الأذكار + العداد الدائري + عدد مرات الذكر
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'اجمالي الاذكار',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A5056),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${safeIndex + 1}/${items.length}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1D1F),
                                  ),
                                ),
                              ],
                            ),

                            // زر العداد الدائري المركزي
                            GestureDetector(
                              onTap: () =>
                                  _onCounterTap(targetCount, items.length),
                              child: Container(
                                width: 104,
                                height: 104,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFD5D9DD),
                                      Color(0xFF8C9298),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.14),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFC8CDD2),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$_tapCount',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Column(
                              children: [
                                const Text(
                                  'عدد مرات الذكر',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4A5056),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$targetCount',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A1D1F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
