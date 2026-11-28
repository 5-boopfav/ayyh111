import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../main.dart';

class AdhanHomeTab extends StatefulWidget {
  final int khatmaPage;
  final int wirdRead;
  final int wirdGoal;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final ValueChanged<bool> onToggleSound;
  final ValueChanged<bool> onToggleVibration;
  final VoidCallback onOpenKhatma;
  final VoidCallback onOpenAthkar;

  const AdhanHomeTab({
    super.key,
    required this.khatmaPage,
    required this.wirdRead,
    required this.wirdGoal,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.onToggleSound,
    required this.onToggleVibration,
    required this.onOpenKhatma,
    required this.onOpenAthkar,
  });

  @override
  State<AdhanHomeTab> createState() => _AdhanHomeTabState();
}

class _AdhanHomeTabState extends State<AdhanHomeTab> {
  CityPreset _selectedCity = kCities.first;
  String _methodKey = 'umm_al_qura';
  bool _azanAlertEnabled = true;
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadAdhanPrefs();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadAdhanPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cityName = prefs.getString('adhan_city') ?? kCities.first.name;
    final city = kCities.firstWhere(
      (c) => c.name == cityName,
      orElse: () => kCities.first,
    );
    final method = prefs.getString('adhan_method') ?? city.methodKey;
    final alert = prefs.getBool('adhan_alert') ?? true;
    if (!mounted) return;
    setState(() {
      _selectedCity = city;
      _methodKey = method;
      _azanAlertEnabled = alert;
    });
  }

  Future<void> _saveAdhanPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adhan_city', _selectedCity.name);
    await prefs.setString('adhan_method', _methodKey);
    await prefs.setBool('adhan_alert', _azanAlertEnabled);
  }

  CalculationParameters _calculationMethodFromKey(String key) {
    switch (key) {
      case 'egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'dubai':
        return CalculationMethod.dubai.getParameters();
      case 'muslim_world_league':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'karachi':
        return CalculationMethod.karachi.getParameters();
      case 'north_america':
        return CalculationMethod.north_america.getParameters();
      case 'umm_al_qura':
      default:
        return CalculationMethod.umm_al_qura.getParameters();
    }
  }

  String _methodLabel(String key) {
    switch (key) {
      case 'egyptian':
        return 'الهيئة المصرية العامة للمساحة';
      case 'dubai':
        return 'دبي';
      case 'muslim_world_league':
        return 'رابطة العالم الإسلامي';
      case 'karachi':
        return 'جامعة العلوم الإسلامية بكراتشي';
      case 'north_america':
        return 'أمريكا الشمالية (ISNA)';
      case 'umm_al_qura':
      default:
        return 'أم القرى';
    }
  }

  PrayerTimes _computeTodayPrayerTimesForDate(DateTime dateTime) {
    final coords = Coordinates(_selectedCity.latitude, _selectedCity.longitude);
    final params = _calculationMethodFromKey(_methodKey);
    params.madhab = Madhab.shafi;
    final date = DateComponents.from(dateTime);
    return PrayerTimes(coords, date, params);
  }

  String _prayerArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      case Prayer.none:
        return 'الفجر';
    }
  }

  String _formatClock(DateTime dt) {
    final int hour24 = dt.hour;
    final int hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final String period = hour24 >= 12 ? 'م' : 'ص';
    final String min = dt.minute.toString().padLeft(2, '0');
    return '$hour12:$min $period';
  }

  String _formatRemaining(Duration diff) {
    if (diff.isNegative) return '00:00:00';
    final int h = diff.inHours;
    final int m = diff.inMinutes.remainder(60);
    final int s = diff.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final PrayerTimes pt = _computeTodayPrayerTimesForDate(_now);
    Prayer next = pt.nextPrayer();
    DateTime? nextTime = pt.timeForPrayer(next);
    DateTime? prevTime;

    final List<(Prayer, DateTime)> orderedToday = [
      (Prayer.fajr, pt.fajr),
      (Prayer.sunrise, pt.sunrise),
      (Prayer.dhuhr, pt.dhuhr),
      (Prayer.asr, pt.asr),
      (Prayer.maghrib, pt.maghrib),
      (Prayer.isha, pt.isha),
    ];

    if (next == Prayer.none || nextTime == null) {
      final tomorrow = _now.add(const Duration(days: 1));
      final tomorrowPt = _computeTodayPrayerTimesForDate(tomorrow);
      next = Prayer.fajr;
      nextTime = tomorrowPt.fajr;
      prevTime = pt.isha;
    } else {
      final int idx = orderedToday.indexWhere((e) => e.$1 == next);
      if (idx > 0) {
        prevTime = orderedToday[idx - 1].$2;
      } else {
        final yesterdayPt = _computeTodayPrayerTimesForDate(
            _now.subtract(const Duration(days: 1)));
        prevTime = yesterdayPt.isha;
      }
    }

    final Duration remaining = nextTime.difference(_now);
    final double windowProgress = () {
      if (prevTime == null) return 0.0;
      final int totalSec = nextTime!.difference(prevTime).inSeconds;
      if (totalSec <= 0) return 0.0;
      final int elapsedSec = _now.difference(prevTime).inSeconds;
      return (elapsedSec / totalSec).clamp(0.0, 1.0);
    }();

    const Color cardBg = Color(0xFFFFFCF6);
    const Color primary = Color(0xFF1B6B88);
    const Color ink = Color(0xFF1E2421);

    final int khatmaPct = ((widget.khatmaPage / 604) * 100).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'مواقيت الأذان — ${_selectedCity.name}',
          style: const TextStyle(
              color: ink, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: widget.soundEnabled ? 'الصوت مفعّل' : 'الصوت مكتوم',
            icon: Icon(
              widget.soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: primary,
            ),
            onPressed: () => widget.onToggleSound(!widget.soundEnabled),
          ),
          IconButton(
            tooltip:
                widget.vibrationEnabled ? 'الاهتزاز مفعّل' : 'الاهتزاز متوقف',
            icon: Icon(
              widget.vibrationEnabled
                  ? Icons.vibration
                  : Icons.phone_android_outlined,
              color: primary,
            ),
            onPressed: () => widget.onToggleVibration(!widget.vibrationEnabled),
          ),
          IconButton(
            tooltip:
                _azanAlertEnabled ? 'تنبيه الأذان مفعّل' : 'تنبيه الأذان متوقف',
            icon: Icon(
              _azanAlertEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: primary,
            ),
            onPressed: () {
              setState(() => _azanAlertEnabled = !_azanAlertEnabled);
              _saveAdhanPrefs();
              if (widget.vibrationEnabled) HapticFeedback.selectionClick();
              SubtleAudioEffects.playTap(enabled: widget.soundEnabled);
            },
          ),
          IconButton(
            tooltip: 'تغيير المدينة وطريقة الحساب',
            icon: const Icon(Icons.tune, color: primary),
            onPressed: _openLocationAndMethodSheet,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الصلاة القادمة: ${_prayerArabicName(next)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatClock(nextTime),
                      style: const TextStyle(
                        color: Color(0xFFE5F3F8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'المتبقي على الأذان: ${_formatRemaining(remaining)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: windowProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFE5F3F8)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'الحساب: ${_methodLabel(_methodKey)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onOpenKhatma,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'الختمة: صفحة ${widget.khatmaPage} من 604 ($khatmaPct%) • الورد: ${widget.wirdRead}/${widget.wirdGoal}',
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_left, color: primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...orderedToday.map((item) {
            final bool isNext = item.$1 == next;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isNext
                    ? primary.withValues(alpha: 0.12)
                    : cardBg.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNext ? primary : ink.withValues(alpha: 0.12),
                  width: isNext ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  isNext ? Icons.alarm_on : Icons.schedule,
                  color: isNext ? primary : ink.withValues(alpha: 0.65),
                ),
                title: Text(
                  _prayerArabicName(item.$1),
                  style: TextStyle(
                    color: ink,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  _formatClock(item.$2),
                  style: TextStyle(
                    color: isNext ? primary : ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    backgroundColor: cardBg.withValues(alpha: 0.85),
                    side: BorderSide(color: primary.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: widget.onOpenKhatma,
                  icon: const Icon(Icons.menu_book),
                  label: Text('المصحف والختمة (ص ${widget.khatmaPage})'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    backgroundColor: cardBg.withValues(alpha: 0.85),
                    side: BorderSide(color: primary.withValues(alpha: 0.45)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: widget.onOpenAthkar,
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('الأذكار'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openLocationAndMethodSheet() {
    CityPreset tempCity = _selectedCity;
    String tempMethod = _methodKey;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFCF6),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'المدينة وطريقة الحساب',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kCities.map((c) {
                        final selected = tempCity.name == c.name;
                        return ChoiceChip(
                          label: Text(c.name),
                          selected: selected,
                          onSelected: (_) {
                            setLocal(() {
                              tempCity = c;
                              tempMethod = c.methodKey;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: tempMethod,
                      decoration: const InputDecoration(
                        labelText: 'طريقة الحساب',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'umm_al_qura', child: Text('أم القرى')),
                        DropdownMenuItem(
                            value: 'egyptian',
                            child: Text('الهيئة المصرية العامة للمساحة')),
                        DropdownMenuItem(
                            value: 'muslim_world_league',
                            child: Text('رابطة العالم الإسلامي')),
                        DropdownMenuItem(
                            value: 'dubai', child: Text('دبي')),
                        DropdownMenuItem(
                            value: 'karachi',
                            child: Text('جامعة العلوم الإسلامية بكراتشي')),
                        DropdownMenuItem(
                            value: 'north_america',
                            child: Text('أمريكا الشمالية (ISNA)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setLocal(() => tempMethod = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _selectedCity = tempCity;
                          _methodKey = tempMethod;
                        });
                        _saveAdhanPrefs();
                        Navigator.pop(ctx);
                      },
                      child: const Text('حفظ'),
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
}
