import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/islamic_models.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  List<AzkarChapter> _chapters = const [];
  int _selectedChapterIndex = 0;
  final Map<String, int> _counts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final chapters =
        await LocalIslamicRepository.instance.loadAzkarChapters();
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      _isLoading = false;
    });
  }

  void _incrementDhikr(DhikrItem item) {
    final current = _counts[item.id] ?? 0;
    if (current < item.repeatCount) {
      setState(() {
        _counts[item.id] = current + 1;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _resetDhikr(String id) {
    setState(() {
      _counts[id] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'حصن المسلم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapters.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'بانتظار إضافة ملف البيانات المحلي الموثوق (assets/data/hisn_al_muslim.json) لعرض أبواب وأذكار حصن المسلم بدون إنترنت.',
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
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: _chapters.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final chapter = _chapters[index];
                          final selected = index == _selectedChapterIndex;
                          return ChoiceChip(
                            label: Text(chapter.title),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedChapterIndex = index;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemCount:
                            _chapters[_selectedChapterIndex].items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item =
                              _chapters[_selectedChapterIndex].items[index];
                          final currentCount = _counts[item.id] ?? 0;
                          final completed = currentCount >= item.repeatCount;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: completed
                                  ? primaryColor.withValues(alpha: 0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: completed
                                    ? primaryColor.withValues(alpha: 0.4)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  item.text,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.8,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                if (item.reference != null &&
                                    item.reference!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    item.reference!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: currentCount > 0
                                          ? () => _resetDhikr(item.id)
                                          : null,
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('إعادة'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _incrementDhikr(item),
                                      child: Text(
                                        'التكرار: $currentCount / ${item.repeatCount}',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
