import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

class _CityPreset {
  final String name;
  final double latitude;
  final double longitude;
  final CalculationMethod Function() methodBuilder;

  const _CityPreset({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.methodBuilder,
  });
}

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  static final List<_CityPreset> _cities = <_CityPreset>[
    _CityPreset(
      name: 'الرياض',
      latitude: 24.7136,
      longitude: 46.6753,
      methodBuilder: CalculationMethod.umm_al_qura.getParameters,
    ),
    _CityPreset(
      name: 'مكة المكرمة',
      latitude: 21.3891,
      longitude: 39.8579,
      methodBuilder: CalculationMethod.umm_al_qura.getParameters,
    ),
    _CityPreset(
      name: 'المدينة المنورة',
      latitude: 24.5247,
      longitude: 39.5692,
      methodBuilder: CalculationMethod.umm_al_qura.getParameters,
    ),
    _CityPreset(
      name: 'جدة',
      latitude: 21.4858,
      longitude: 39.1925,
      methodBuilder: CalculationMethod.umm_al_qura.getParameters,
    ),
    _CityPreset(
      name: 'الدمام',
      latitude: 26.4207,
      longitude: 50.0888,
      methodBuilder: CalculationMethod.umm_al_qura.getParameters,
    ),
    _CityPreset(
      name: 'القاهرة',
      latitude: 30.0444,
      longitude: 31.2357,
      methodBuilder: CalculationMethod.egyptian.getParameters,
    ),
    _CityPreset(
      name: 'دبي',
      latitude: 25.2048,
      longitude: 55.2708,
      methodBuilder: CalculationMethod.dubai.getParameters,
    ),
    _CityPreset(
      name: 'عمّان',
      latitude: 31.9539,
      longitude: 35.9106,
      methodBuilder: CalculationMethod.muslim_world_league.getParameters,
    ),
  ];

  int _selectedCityIndex = 0;
  Madhab _madhab = Madhab.shafi;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  PrayerTimes _computePrayerTimes(DateTime targetDate) {
    final city = _cities[_selectedCityIndex];
    final coordinates = Coordinates(city.latitude, city.longitude);
    final params = city.methodBuilder()..madhab = _madhab;
    final dateComponents = DateComponents.from(targetDate);
    return PrayerTimes(coordinates, dateComponents, params);
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    final local = time.toLocal();
    final hour24 = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'م' : 'ص';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $period';
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
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

  DateTime? _timeForPrayer(PrayerTimes times, Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return times.fajr;
      case Prayer.sunrise:
        return times.sunrise;
      case Prayer.dhuhr:
        return times.dhuhr;
      case Prayer.asr:
        return times.asr;
      case Prayer.maghrib:
        return times.maghrib;
      case Prayer.isha:
        return times.isha;
      case Prayer.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final city = _cities[_selectedCityIndex];
    final todayTimes = _computePrayerTimes(_now);

    Prayer nextPrayer = todayTimes.nextPrayer();
    DateTime? nextPrayerTime = _timeForPrayer(todayTimes, nextPrayer);

    if (nextPrayer == Prayer.none || nextPrayerTime == null) {
      final tomorrow = _now.add(const Duration(days: 1));
      final tomorrowTimes = _computePrayerTimes(tomorrow);
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowTimes.fajr;
    }

    final remaining = nextPrayerTime.difference(_now);

    final rows = <({Prayer prayer, String title, DateTime time, IconData icon})>[
      (prayer: Prayer.fajr, title: 'الفجر', time: todayTimes.fajr, icon: Icons.wb_twilight),
      (prayer: Prayer.sunrise, title: 'الشروق', time: todayTimes.sunrise, icon: Icons.wb_sunny_outlined),
      (prayer: Prayer.dhuhr, title: 'الظهر', time: todayTimes.dhuhr, icon: Icons.wb_sunny),
      (prayer: Prayer.asr, title: 'العصر', time: todayTimes.asr, icon: Icons.sunny_snowing),
      (prayer: Prayer.maghrib, title: 'المغرب', time: todayTimes.maghrib, icon: Icons.nights_stay_outlined),
      (prayer: Prayer.isha, title: 'العشاء', time: todayTimes.isha, icon: Icons.bedtime),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مواقيت الصلاة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'المذهب الفقهي للعصر',
            icon: const Icon(Icons.tune),
            onPressed: () {
              setState(() {
                _madhab =
                    _madhab == Madhab.shafi ? Madhab.hanafi : Madhab.shafi;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _madhab == Madhab.shafi
                        ? 'تم ضبط العصر على جمهور الفقهاء (الشافعي/المالكي/الحنبلي).'
                        : 'تم ضبط العصر على المذهب الحنفي.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // شريط اختيار المدينة
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _cities[index];
                    final selected = index == _selectedCityIndex;
                    return ChoiceChip(
                      label: Text(item.name),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCityIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // بطاقة الصلاة القادمة والعد التنازلي
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${city.name} • ${_madhab == Madhab.hanafi ? 'الحنفي' : 'الجمهور'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الصلاة القادمة: ${_prayerArabicName(nextPrayer)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCountdown(remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'موعد الأذان: ${_formatTime(nextPrayerTime)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // جدول مواقيت اليوم
              Expanded(
                child: ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final isNext = row.prayer == nextPrayer;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isNext
                            ? primaryColor.withValues(alpha: 0.09)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isNext ? primaryColor : Colors.grey.shade200,
                          width: isNext ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            row.icon,
                            color: isNext ? primaryColor : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              row.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isNext ? FontWeight.bold : FontWeight.w600,
                                color: isNext ? primaryColor : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(row.time),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isNext ? primaryColor : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
