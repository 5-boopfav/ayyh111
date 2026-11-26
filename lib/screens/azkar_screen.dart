import 'package:flutter/material.dart';

class _ZikrItem {
  final String category;
  final String title;
  final String text;
  final int targetCount;
  int currentCount = 0;

  _ZikrItem({
    required this.category,
    required this.title,
    required this.text,
    required this.targetCount,
  });
}

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final List<String> _categories = const [
    'أذكار الصباح',
    'أذكار المساء',
    'بعد الصلاة',
  ];

  int _selectedCategoryIndex = 0;
  int _selectedZikrIndex = 0;

  late final List<_ZikrItem> _zikrList = [
    _ZikrItem(
      category: 'أذكار الصباح',
      title: 'سبحان الله',
      text: 'سبحان الله وبحمده، عدد خلقه، ورضاء نفسه، وزنة عرشه، ومداد كلماته.',
      targetCount: 100,
    ),
    _ZikrItem(
      category: 'أذكار الصباح',
      title: 'أصبحنا وأصبح الملك لله',
      text: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
      targetCount: 1,
    ),
    _ZikrItem(
      category: 'أذكار المساء',
      title: 'أمسينا وأمسى الملك لله',
      text: 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
      targetCount: 1,
    ),
    _ZikrItem(
      category: 'أذكار المساء',
      title: 'أستغفر الله العظيم',
      text: 'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه.',
      targetCount: 100,
    ),
    _ZikrItem(
      category: 'بعد الصلاة',
      title: 'التسبيح بعد الصلاة',
      text: 'سبحان الله، والحمد لله، والله أكبر.',
      targetCount: 33,
    ),
  ];

  List<_ZikrItem> get _filteredList {
    final cat = _categories[_selectedCategoryIndex];
    return _zikrList.where((item) => item.category == cat).toList();
  }

  void _incrementZikr(_ZikrItem item) {
    setState(() {
      if (item.currentCount < item.targetCount) {
        item.currentCount++;
        if (item.currentCount == item.targetCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('أتممت "${item.title}" (${item.targetCount}/${item.targetCount})'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _resetZikr(_ZikrItem item) {
    setState(() {
      item.currentCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final items = _filteredList;
    final safeIndex = _selectedZikrIndex < items.length ? _selectedZikrIndex : 0;
    final activeItem = items[safeIndex];
    final progress = activeItem.targetCount > 0
        ? (activeItem.currentCount / activeItem.targetCount).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حصن المسلم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'تصفير العداد',
            icon: const Icon(Icons.refresh),
            onPressed: () => _resetZikr(activeItem),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أذكار الصباح، المساء، بعد الصلاة',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_categories.length, (i) {
                      final selected = i == _selectedCategoryIndex;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text(_categories[i]),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategoryIndex = i;
                              _selectedZikrIndex = 0;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(items.length, (i) {
                final isCurrent = i == safeIndex;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isCurrent ? const Color(0xFFEBF4FC) : Colors.white,
                      side: BorderSide(
                        color: isCurrent ? primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedZikrIndex = i;
                      });
                    },
                    child: Text(
                      items[i].title,
                      style: TextStyle(
                        color: isCurrent ? primaryColor : Colors.black87,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Text(
                  activeItem.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  activeItem.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.7,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${activeItem.currentCount} / ${activeItem.targetCount}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 112,
                  height: 112,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 112,
                        height: 112,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 7,
                          backgroundColor: Colors.grey.shade200,
                          color: primaryColor,
                        ),
                      ),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _incrementZikr(activeItem),
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.1),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'تسبيح',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
