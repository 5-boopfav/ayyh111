import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_flip/page_flip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../main.dart';
import '../models/page_theme_palette.dart';
import '../widgets/mushaf_sheet.dart';

class KhatmaMushafTab extends StatefulWidget {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final void Function(
    int page,
    int readToday,
    int goal,
    bool controlsVisible,
  )? onProgressChanged;

  const KhatmaMushafTab({
    super.key,
    required this.soundEnabled,
    required this.vibrationEnabled,
    this.onProgressChanged,
  });

  @override
  State<KhatmaMushafTab> createState() => _KhatmaMushafTabState();
}

class _KhatmaMushafTabState extends State<KhatmaMushafTab> {
  static const int totalPages = 604;

  // «نقطة التاج»: تفعيل سحب الرجوع باليد بانسيابية التقدم
  static const bool kCrownPointEnabled = true;

  static const Color _softBookmarkRed = Color(0xFFC94A4A);
  static const Color _softBookmarkRedLight = Color(0xFFD96B6B);
  static const Color _softBookmarkRedDark = Color(0xFF9E3434);

  GlobalKey<PageFlipWidgetState> _portraitFlipKey =
      GlobalKey<PageFlipWidgetState>();
  GlobalKey<PageFlipWidgetState> _landscapeSpreadFlipKey =
      GlobalKey<PageFlipWidgetState>();

  int _currentPage = 1;
  int? _bookmarkedPage;
  int? _secondaryBookmarkPage;
  double _ribbonDropRatio = 0.34;
  int _dailyWirdGoalPages = 20;
  int _wirdReadToday = 0;
  String _lastWirdDate = '';
  double _pageScale = 1.0;

  String _selectedThemeId = 'mushaf_blue';
  double _themeHue = 196.0;
  double _themeShade = 0.08;
  bool _showBottomBar = false;

  Offset? _pointerDownPos;
  bool _movedDuringTouch = false;
  Orientation? _lastOrientation;

  late final List<int> _allPageNumbers =
      List<int>.generate(totalPages, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDate = prefs.getString('last_wird_date') ?? today;
    final savedWird =
        savedDate == today ? (prefs.getInt('wird_read_today') ?? 0) : 0;

    if (!mounted) return;
    setState(() {
      _currentPage = (prefs.getInt('current_page') ?? 1).clamp(1, totalPages);
      _bookmarkedPage = prefs.getInt('bookmarked_page');
      _secondaryBookmarkPage = prefs.getInt('secondary_bookmark_page');
      _ribbonDropRatio =
          (prefs.getDouble('ribbon_drop_ratio') ?? 0.34).clamp(0.14, 0.78);
      _pageScale = (prefs.getDouble('page_scale') ?? 1.0).clamp(0.9, 1.25);
      _dailyWirdGoalPages = prefs.getInt('daily_wird_goal') ?? 20;
      _selectedThemeId = prefs.getString('theme_preset_id') ?? 'mushaf_blue';
      _themeHue = (prefs.getDouble('theme_hue') ?? 196.0).clamp(0.0, 360.0);
      _themeShade = (prefs.getDouble('theme_shade') ?? 0.08).clamp(0.0, 1.0);
      _showBottomBar = prefs.getBool('show_bottom_bar') ?? false;
      _lastWirdDate = today;
      _wirdReadToday = savedWird;
      _portraitFlipKey = GlobalKey<PageFlipWidgetState>();
      _landscapeSpreadFlipKey = GlobalKey<PageFlipWidgetState>();
    });
    _notifyParent();
  }

  void _notifyParent() {
    widget.onProgressChanged?.call(
      _currentPage,
      _wirdReadToday,
      _dailyWirdGoalPages,
      _showBottomBar,
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_page', _currentPage);
    if (_bookmarkedPage != null) {
      await prefs.setInt('bookmarked_page', _bookmarkedPage!);
    } else {
      await prefs.remove('bookmarked_page');
    }
    if (_secondaryBookmarkPage != null) {
      await prefs.setInt('secondary_bookmark_page', _secondaryBookmarkPage!);
    } else {
      await prefs.remove('secondary_bookmark_page');
    }
    await prefs.setDouble('ribbon_drop_ratio', _ribbonDropRatio);
    await prefs.setDouble('page_scale', _pageScale);
    await prefs.setInt('daily_wird_goal', _dailyWirdGoalPages);
    await prefs.setString('theme_preset_id', _selectedThemeId);
    await prefs.setDouble('theme_hue', _themeHue);
    await prefs.setDouble('theme_shade', _themeShade);
    await prefs.setBool('show_bottom_bar', _showBottomBar);
    await prefs.setString('last_wird_date', _lastWirdDate);
    await prefs.setInt('wird_read_today', _wirdReadToday);
    _notifyParent();
  }

  void _advanceWirdOnce() {
    final today = _todayKey();
    if (_lastWirdDate != today) {
      _lastWirdDate = today;
      _wirdReadToday = 0;
    }
    if (_wirdReadToday < _dailyWirdGoalPages) {
      _wirdReadToday++;
    }
  }

  void _onPageChanged(int newPage) {
    final int clamped = newPage.clamp(1, totalPages);
    if (clamped == _currentPage) return;
    setState(() {
      if (clamped > _currentPage) {
        _advanceWirdOnce();
      }
      _currentPage = clamped;
    });
    _saveState();
    SubtleAudioEffects.playPageTurn(enabled: widget.soundEnabled);
    if (widget.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _jumpToPage(int page) {
    final int clamped = page.clamp(1, totalPages);
    setState(() {
      _currentPage = clamped;
      _portraitFlipKey = GlobalKey<PageFlipWidgetState>();
      _landscapeSpreadFlipKey = GlobalKey<PageFlipWidgetState>();
    });
    _saveState();
    SubtleAudioEffects.playPageTurn(enabled: widget.soundEnabled);
  }

  void _toggleBookmark() {
    setState(() {
      _bookmarkedPage = _bookmarkedPage == _currentPage ? null : _currentPage;
    });
    _saveState();
    if (widget.vibrationEnabled) HapticFeedback.selectionClick();
    SubtleAudioEffects.playTap(enabled: widget.soundEnabled);
  }

  void _toggleSecondaryBookmark() {
    setState(() {
      _secondaryBookmarkPage =
          _secondaryBookmarkPage == _currentPage ? null : _currentPage;
    });
    _saveState();
    if (widget.vibrationEnabled) HapticFeedback.selectionClick();
    SubtleAudioEffects.playTap(enabled: widget.soundEnabled);
  }

  void _onPointerDown(PointerDownEvent e) {
    _pointerDownPos = e.localPosition;
    _movedDuringTouch = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    final start = _pointerDownPos;
    if (start == null) return;
    if ((e.localPosition - start).distance > 12.0) {
      _movedDuringTouch = true;
      if (_showBottomBar) {
        setState(() => _showBottomBar = false);
        _saveState();
      }
    }
  }

  void _onPointerUp() {
    if (_pointerDownPos != null && !_movedDuringTouch) {
      setState(() => _showBottomBar = !_showBottomBar);
      _saveState();
    }
    _pointerDownPos = null;
    _movedDuringTouch = false;
  }

  SurahInfo _surahForPage(int page) {
    SurahInfo res = kSurahs.first;
    for (final s in kSurahs) {
      if (s.startPage <= page) {
        res = s;
      } else {
        break;
      }
    }
    return res;
  }

  JuzInfo _juzForPage(int page) {
    JuzInfo res = kJuzList.first;
    for (final j in kJuzList) {
      if (j.startPage <= page) {
        res = j;
      } else {
        break;
      }
    }
    return res;
  }

  Widget _buildSingleSheet(int pageNumber, PageThemePalette palette) {
    return MushafSingleSheet(
      pageNumber: pageNumber,
      surahName: _surahForPage(pageNumber).name,
      juzTitle: _juzForPage(pageNumber).title,
      palette: palette,
      scale: _pageScale,
      wirdRead: _wirdReadToday,
      wirdGoal: _dailyWirdGoalPages,
    );
  }

  Widget _buildLandscapeSpread(
    int rightPage,
    int? leftPage,
    PageThemePalette palette,
  ) {
    return Container(
      color: palette.background,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: _buildSingleSheet(rightPage, palette),
          ),
          Container(
            width: 3,
            color: palette.outerFrame.withValues(alpha: 0.45),
          ),
          Expanded(
            child: leftPage != null
                ? _buildSingleSheet(leftPage, palette)
                : Container(color: palette.paper),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PageThemePalette palette = PageThemePalette.fromHueAndShade(
      hue: _themeHue,
      shade: _themeShade,
    );

    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;

    if (_lastOrientation != null && _lastOrientation != orientation) {
      _portraitFlipKey = GlobalKey<PageFlipWidgetState>();
      _landscapeSpreadFlipKey = GlobalKey<PageFlipWidgetState>();
    }
    _lastOrientation = orientation;

    final bool hasBookmarkOnCurrent = _bookmarkedPage == _currentPage;
    final bool hasSecondaryOnCurrent = _secondaryBookmarkPage == _currentPage;

    const double juzBoxWidth = 116.0;
    const double bookmarkBesideJuzLeft = 22.0 + juzBoxWidth + 4.0;

    return Scaffold(
      backgroundColor: palette.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double height = constraints.maxHeight;

          final Widget flipBookWidget = isLandscape
              ? _buildLandscapeFlipBook(palette)
              : _buildPortraitFlipBook(palette);

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: (_) => _onPointerUp(),
            onPointerCancel: (_) {
              _pointerDownPos = null;
              _movedDuringTouch = false;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                flipBookWidget,
                if (hasBookmarkOnCurrent)
                  _RedBookmarkCordOverlay(
                    pageHeight: height,
                    dropRatio: _ribbonDropRatio,
                    onDropRatioChanged: (newRatio) {
                      setState(() => _ribbonDropRatio = newRatio);
                    },
                    onDragEnd: _saveState,
                    onTap: _toggleBookmark,
                  ),
                Positioned(
                  top: 3,
                  left: bookmarkBesideJuzLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TopQuickChip(
                        icon: Icons.bookmark,
                        color: hasBookmarkOnCurrent
                            ? _softBookmarkRed
                            : palette.outerFrame,
                        bgColor: palette.paper,
                        borderColor: const Color(0xFFE67E22),
                        tooltip: hasBookmarkOnCurrent
                            ? 'إزالة الحبل الأحمر'
                            : 'إنزال الحبل الأحمر',
                        onTap: _toggleBookmark,
                      ),
                      if (_bookmarkedPage != null &&
                          !hasBookmarkOnCurrent) ...[
                        const SizedBox(width: 2),
                        _TopQuickChip(
                          icon: Icons.turned_in,
                          color: _softBookmarkRed,
                          bgColor: palette.paper,
                          borderColor: palette.outerFrame,
                          tooltip:
                              'الانتقال إلى الحبل الأحمر (ص $_bookmarkedPage)',
                          onTap: () => _jumpToPage(_bookmarkedPage!),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_showBottomBar)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _FloatingBottomBar(
                      palette: palette,
                      currentPage: _currentPage,
                      isLandscapeSpread: isLandscape,
                      hasSecondaryBookmark: hasSecondaryOnCurrent,
                      secondaryBookmarkPage: _secondaryBookmarkPage,
                      wirdRead: _wirdReadToday,
                      wirdGoal: _dailyWirdGoalPages,
                      onJumpPage: _jumpToPage,
                      onOpenSurahs: () => _openSurahs(palette),
                      onOpenJuz: () => _openJuz(palette),
                      onOpenWird: _openWird,
                      onToggleSecondaryBookmark: _toggleSecondaryBookmark,
                      onJumpSecondaryBookmark: _secondaryBookmarkPage == null
                          ? null
                          : () => _jumpToPage(_secondaryBookmarkPage!),
                      onOpenScale: () => _openScale(palette),
                      onOpenTheme: () => _openThemeCustomizer(palette),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitFlipBook(PageThemePalette palette) {
    final int startIndex =
        kCrownPointEnabled ? 0 : (_currentPage - 1).clamp(0, totalPages - 1);
    final int remainingBeforeLast = (totalPages - 1) - startIndex;

    final List<Widget> flipChildren = List.generate(
      remainingBeforeLast,
      (offset) {
        final int pageNum = _allPageNumbers[startIndex + offset];
        return NotificationListener<ScrollNotification>(
          onNotification: (_) {
            if (pageNum != _currentPage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _onPageChanged(pageNum);
              });
            }
            return false;
          },
          child: _buildSingleSheet(pageNum, palette),
        );
      },
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: PageFlipWidget(
        key: _portraitFlipKey,
        backgroundColor: palette.paper,
        lastPage: _buildSingleSheet(totalPages, palette),
        children: flipChildren,
      ),
    );
  }

  Widget _buildLandscapeFlipBook(PageThemePalette palette) {
    final List<(int right, int? left)> spreads = [];
    for (int p = 1; p <= totalPages; p += 2) {
      spreads.add((p, p + 1 <= totalPages ? p + 1 : null));
    }

    final int currentSpreadIdx =
        ((_currentPage - 1) ~/ 2).clamp(0, spreads.length - 1);
    final int startSpread = kCrownPointEnabled ? 0 : currentSpreadIdx;
    final int lastSpreadIdx = spreads.length - 1;

    final List<Widget> spreadWidgets = List.generate(
      math.max(0, lastSpreadIdx - startSpread),
      (offset) {
        final int idx = startSpread + offset;
        final (int rPage, int? lPage) = spreads[idx];
        return NotificationListener<ScrollNotification>(
          onNotification: (_) {
            if (_currentPage != rPage && _currentPage != lPage) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _onPageChanged(rPage);
              });
            }
            return false;
          },
          child: _buildLandscapeSpread(rPage, lPage, palette),
        );
      },
    );

    final (int lastR, int? lastL) = spreads.last;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: PageFlipWidget(
        key: _landscapeSpreadFlipKey,
        backgroundColor: palette.background,
        lastPage: _buildLandscapeSpread(lastR, lastL, palette),
        children: spreadWidgets,
      ),
    );
  }

  void _openThemeCustomizer(PageThemePalette currentPalette) {
    double tempHue = _themeHue;
    double tempShade = _themeShade;
    String tempPresetId = _selectedThemeId;

    showModalBottomSheet(
      context: context,
      backgroundColor: currentPalette.paper,
      isScrollControlled: true,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocal) {
              final livePalette = PageThemePalette.fromHueAndShade(
                hue: tempHue,
                shade: tempShade,
              );

              return Container(
                color: livePalette.paper,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ثيم الصفحة (اللون والتدريجة)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: livePalette.ink,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: livePalette.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: livePalette.accent, width: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kPageThemePresets.map((preset) {
                        final bool selected = tempPresetId == preset.id;
                        final pCol = PageThemePalette.fromHueAndShade(
                          hue: preset.hue,
                          shade: preset.shade,
                        );
                        return ChoiceChip(
                          selected: selected,
                          label: Text(preset.name),
                          selectedColor: pCol.accent.withValues(alpha: 0.22),
                          backgroundColor: pCol.background,
                          labelStyle: TextStyle(
                            color: livePalette.ink,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setLocal(() {
                              tempPresetId = preset.id;
                              tempHue = preset.hue;
                              tempShade = preset.shade;
                            });
                            setState(() {
                              _selectedThemeId = preset.id;
                              _themeHue = preset.hue;
                              _themeShade = preset.shade;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'اللون: ${tempHue.round()}°',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: livePalette.ink,
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: 360.0,
                      value: tempHue,
                      activeColor: livePalette.accent,
                      onChanged: (v) {
                        setLocal(() {
                          tempHue = v;
                          tempPresetId = 'custom';
                        });
                        setState(() {
                          _themeHue = v;
                          _selectedThemeId = 'custom';
                        });
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'التدريجة: ${(tempShade * 100).round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: livePalette.ink,
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      value: tempShade,
                      activeColor: livePalette.accent,
                      onChanged: (v) {
                        setLocal(() {
                          tempShade = v;
                          tempPresetId = 'custom';
                        });
                        setState(() {
                          _themeShade = v;
                          _selectedThemeId = 'custom';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: livePalette.accent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _saveState();
                          Navigator.pop(ctx);
                        },
                        child: const Text('حفظ الثيم'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openSurahs(PageThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.paper,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'فهرس السور',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: palette.ink),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kSurahs.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1, color: palette.ink.withValues(alpha: 0.12)),
                  itemBuilder: (_, i) {
                    final s = kSurahs[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: palette.ink.withValues(alpha: 0.12),
                        child: Text('${s.number}',
                            style: TextStyle(color: palette.ink, fontSize: 13)),
                      ),
                      title: Text(s.name,
                          style: TextStyle(
                              color: palette.ink, fontWeight: FontWeight.w600)),
                      subtitle: Text(s.revelationType,
                          style: TextStyle(
                              color: palette.ink.withValues(alpha: 0.68))),
                      trailing: Text('ص ${s.startPage}',
                          style: TextStyle(
                              color: palette.ink.withValues(alpha: 0.85))),
                      onTap: () {
                        Navigator.pop(ctx);
                        _jumpToPage(s.startPage);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openJuz(PageThemePalette palette) {
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.paper,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  'أجزاء المصحف الثلاثون',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: palette.ink),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: kJuzList.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1, color: palette.ink.withValues(alpha: 0.12)),
                  itemBuilder: (_, i) {
                    final j = kJuzList[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: palette.ink.withValues(alpha: 0.12),
                        child: Text('${j.number}',
                            style: TextStyle(color: palette.ink, fontSize: 13)),
                      ),
                      title: Text(j.title,
                          style: TextStyle(
                              color: palette.ink, fontWeight: FontWeight.w600)),
                      trailing: Text('تبدأ من ص ${j.startPage}',
                          style: TextStyle(
                              color: palette.ink.withValues(alpha: 0.85))),
                      onTap: () {
                        Navigator.pop(ctx);
                        _jumpToPage(j.startPage);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWird() {
    int tempGoal = _dailyWirdGoalPages;
    final int khatmaPercent = ((_currentPage / totalPages) * 100).round();
    final int estimatedDays =
        tempGoal > 0 ? ((totalPages - _currentPage) / tempGoal).ceil() : 0;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: const Text('الختمة والورد اليومي'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                    'موضع الختمة الحالي: صفحة $_currentPage من $totalPages ($khatmaPercent%)'),
                const SizedBox(height: 4),
                Text('الورد اليومي: $_wirdReadToday / $tempGoal صفحة'),
                const SizedBox(height: 4),
                Text(
                    'الأيام المتبقية لإتمام الختمة تقريباً: $estimatedDays يوم'),
                const SizedBox(height: 10),
                Slider(
                  min: 1,
                  max: 60,
                  divisions: 59,
                  value: tempGoal.toDouble(),
                  onChanged: (v) => setLocal(() => tempGoal = v.round()),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء')),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _dailyWirdGoalPages = tempGoal;
                    if (_wirdReadToday > _dailyWirdGoalPages) {
                      _wirdReadToday = _dailyWirdGoalPages;
                    }
                  });
                  _saveState();
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openScale(PageThemePalette palette) {
    double tempScale = _pageScale;
    showModalBottomSheet(
      context: context,
      backgroundColor: palette.paper,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocal) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'حجم عرض الصفحة: ${(tempScale * 100).round()}%',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: palette.ink),
                  ),
                  Slider(
                    min: 0.9,
                    max: 1.25,
                    divisions: 14,
                    value: tempScale,
                    activeColor: palette.accent,
                    onChanged: (v) {
                      setLocal(() => tempScale = v);
                      setState(() => _pageScale = v);
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _saveState();
                        Navigator.pop(ctx);
                      },
                      child: const Text('تم'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopQuickChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final String tooltip;
  final VoidCallback onTap;

  const _TopQuickChip({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderColor, width: 1.6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }
}

class _RedBookmarkCordOverlay extends StatelessWidget {
  final double pageHeight;
  final double dropRatio;
  final ValueChanged<double> onDropRatioChanged;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;

  const _RedBookmarkCordOverlay({
    required this.pageHeight,
    required this.dropRatio,
    required this.onDropRatioChanged,
    required this.onDragEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double usableH = math.max(120.0, pageHeight);
    final double cordLength = (usableH * dropRatio).clamp(64.0, usableH * 0.85);

    return Positioned(
      top: 0,
      left: 72,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onVerticalDragUpdate: (details) {
          final double nextLength =
              (cordLength + details.delta.dy).clamp(64.0, usableH * 0.85);
          onDropRatioChanged((nextLength / usableH).clamp(0.14, 0.82));
        },
        onVerticalDragEnd: (_) => onDragEnd(),
        child: CustomPaint(
          size: Size(24, cordLength + 18),
          painter: _RedCordPainter(cordLength: cordLength),
        ),
      ),
    );
  }
}

class _RedCordPainter extends CustomPainter {
  final double cordLength;

  _RedCordPainter({required this.cordLength});

  @override
  void paint(Canvas canvas, Size size) {
    const double cordWidth = 6.0;
    final double centerX = size.width * 0.5;
    final double leftX = centerX - cordWidth * 0.5;
    final double rightX = centerX + cordWidth * 0.5;

    final Path shadowPath = Path()
      ..moveTo(leftX + 1.5, 0)
      ..lineTo(rightX + 1.5, 0)
      ..lineTo(rightX + 1.5, cordLength)
      ..lineTo(centerX + 1.5, cordLength + 11)
      ..lineTo(leftX + 1.5, cordLength)
      ..close();

    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    final Paint cordPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(leftX, 0),
        Offset(rightX, 0),
        const [
          _KhatmaMushafTabState._softBookmarkRedDark,
          _KhatmaMushafTabState._softBookmarkRedLight,
          _KhatmaMushafTabState._softBookmarkRed,
        ],
        const [0.0, 0.45, 1.0],
      );

    final Path cordPath = Path()
      ..moveTo(leftX, 0)
      ..lineTo(rightX, 0)
      ..lineTo(rightX, cordLength)
      ..lineTo(centerX, cordLength + 11)
      ..lineTo(leftX, cordLength)
      ..close();

    canvas.drawPath(cordPath, cordPaint);

    canvas.drawCircle(
      Offset(centerX, cordLength + 12),
      2.5,
      Paint()..color = _KhatmaMushafTabState._softBookmarkRedDark,
    );
  }

  @override
  bool shouldRepaint(covariant _RedCordPainter oldDelegate) =>
      oldDelegate.cordLength != cordLength;
}

class _FloatingBottomBar extends StatelessWidget {
  final PageThemePalette palette;
  final int currentPage;
  final bool isLandscapeSpread;
  final bool hasSecondaryBookmark;
  final int? secondaryBookmarkPage;
  final int wirdRead;
  final int wirdGoal;
  final ValueChanged<int> onJumpPage;
  final VoidCallback onOpenSurahs;
  final VoidCallback onOpenJuz;
  final VoidCallback onOpenWird;
  final VoidCallback onToggleSecondaryBookmark;
  final VoidCallback? onJumpSecondaryBookmark;
  final VoidCallback onOpenScale;
  final VoidCallback onOpenTheme;

  const _FloatingBottomBar({
    required this.palette,
    required this.currentPage,
    required this.isLandscapeSpread,
    required this.hasSecondaryBookmark,
    required this.secondaryBookmarkPage,
    required this.wirdRead,
    required this.wirdGoal,
    required this.onJumpPage,
    required this.onOpenSurahs,
    required this.onOpenJuz,
    required this.onOpenWird,
    required this.onToggleSecondaryBookmark,
    required this.onJumpSecondaryBookmark,
    required this.onOpenScale,
    required this.onOpenTheme,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio =
        wirdGoal > 0 ? (wirdRead / wirdGoal).clamp(0.0, 1.0) : 0.0;
    final int khatmaPct = ((currentPage / 604) * 100).round();
    final String modeLabel = isLandscapeSpread ? 'صفحتان' : 'ورقة';

    return Material(
      elevation: 6,
      color: palette.background.withValues(alpha: 0.98),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.ink.withValues(alpha: 0.16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'ص $currentPage ($modeLabel) • الختمة $khatmaPct% • الورد $wirdRead/$wirdGoal',
                  style: TextStyle(
                      fontSize: 11.5, color: palette.ink.withValues(alpha: 0.88)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      min: 1,
                      max: 604,
                      value: currentPage.toDouble().clamp(1, 604),
                      activeColor: palette.accent,
                      onChanged: (v) => onJumpPage(v.round()),
                    ),
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: palette.ink.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
              ),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _BarBtn(
                    icon: Icons.menu_book_outlined,
                    label: 'الفهرس',
                    color: palette.ink,
                    onTap: onOpenSurahs,
                  ),
                  _BarBtn(
                    icon: Icons.grid_view_outlined,
                    label: 'الأجزاء',
                    color: palette.ink,
                    onTap: onOpenJuz,
                  ),
                  _BarBtn(
                    icon: Icons.track_changes_outlined,
                    label: 'الورد',
                    color: palette.ink,
                    onTap: onOpenWird,
                  ),
                  _BarBtn(
                    icon: hasSecondaryBookmark
                        ? Icons.bookmark_added
                        : Icons.bookmark_add_outlined,
                    label: 'علامة ٢',
                    color: hasSecondaryBookmark ? palette.accent : palette.ink,
                    onTap: onToggleSecondaryBookmark,
                  ),
                  if (onJumpSecondaryBookmark != null &&
                      secondaryBookmarkPage != null)
                    _BarBtn(
                      icon: Icons.my_location,
                      label: 'ص $secondaryBookmarkPage',
                      color: palette.accent,
                      onTap: onJumpSecondaryBookmark!,
                    ),
                  _BarBtn(
                    icon: Icons.zoom_in_outlined,
                    label: 'الحجم',
                    color: palette.ink,
                    onTap: onOpenScale,
                  ),
                  _BarBtn(
                    icon: Icons.palette_outlined,
                    label: 'الثيم',
                    color: palette.ink,
                    onTap: onOpenTheme,
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

class _BarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BarBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10.5, color: color)),
          ],
        ),
      ),
    );
  }
}
