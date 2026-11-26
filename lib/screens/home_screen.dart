import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

class HomePrayerScreen extends StatefulWidget {
  const HomePrayerScreen({super.key});

  @override
  State<HomePrayerScreen> createState() => _HomePrayerScreenState();
}

class _HomePrayerScreenState extends State<HomePrayerScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  double _latitude = 24.7136;
  double _longitude = 46.6753;

  final Map<Prayer, bool> _alertEnabled = {
    Prayer.fajr: true,
    Prayer.dhuhr: true,
    Prayer.asr: true,
    Prayer.maghrib: true,
    Prayer.isha: true,
  };

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  PrayerTimes _computePrayerTimes(DateTime date) {
    final coordinates = Coordinates(_latitude, _longitude);
    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;
    final dateComponents = DateComponents.from(date);
    return PrayerTimes(coordinates, dateComponents, params);
  }

  String _prayerArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'صلاة الفجر';
      case Prayer.sunrise:
        return 'الشروق';
      case Prayer.dhuhr:
        return 'صلاة الظهر';
      case Prayer.asr:
        return 'صلاة العصر';
      case Prayer.maghrib:
        return 'صلاة المغرب';
      case Prayer.isha:
        return 'صلاة العشاء';
      case Prayer.none:
        return 'صلاة الفجر';
    }
  }

  String _shortPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return '';
    }
  }

  String _formatCountdown(Duration diff) {
    if (diff.isNegative) return '00:00:00';
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatTime12h(DateTime? dt) {
    if (dt == null) return '--:--';
    final local = dt.toLocal();
    final isAm = local.hour < 12;
    int hour12 = local.hour % 12;
    if (hour12 == 0) hour12 = 12;
    final h = hour12.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m ${isAm ? 'ص' : 'م'}';
  }

  @override
  Widget build(BuildContext context) {
    final todayPrayers = _computePrayerTimes(_now);
    final mainPrayers = <Prayer>[
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    Prayer nextPrayer = Prayer.fajr;
    DateTime? nextPrayerTime;

    for (final p in mainPrayers) {
      final t = todayPrayers.timeForPrayer(p);
      if (t != null && t.isAfter(_now)) {
        nextPrayer = p;
        nextPrayerTime = t;
        break;
      }
    }

    if (nextPrayerTime == null) {
      final tomorrow = _now.add(const Duration(days: 1));
      final tomorrowPrayers = _computePrayerTimes(tomorrow);
      nextPrayer = Prayer.fajr;
      nextPrayerTime = tomorrowPrayers.fajr;
    }

    final remaining = nextPrayerTime.difference(_now);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'يومك بنور الله',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'تغيير المدينة',
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {
              setState(() {
                if ((_latitude - 24.7136).abs() < 0.01) {
                  _latitude = 21.3891;
                  _longitude = 39.8579;
                } else {
                  _latitude = 24.7136;
                  _longitude = 46.6753;
                }
              });
              final city = (_latitude - 21.3891).abs() < 0.01 ? 'مكة المكرمة' : 'الرياض';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تحديث الموقع إلى: $city')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4F8CC9),
                  Color(0xFF9EC5E8),
                  Color(0xFFEAF2F8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _prayerArabicName(nextPrayer),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCountdown(remaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'متبقي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: List.generate(mainPrayers.length, (index) {
                final p = mainPrayers[index];
                final pTime = todayPrayers.timeForPrayer(p);
                final isNext = p == nextPrayer;
                final enabled = _alertEnabled[p] ?? true;

                return Container(
                  decoration: BoxDecoration(
                    color: isNext ? const Color(0xFFEBF4FC) : Colors.transparent,
                    border: index < mainPrayers.length - 1
                        ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    leading: IconButton(
                      icon: Icon(
                        enabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                        color: enabled ? const Color(0xFF4F8CC9) : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _alertEnabled[p] = !enabled;
                        });
                      },
                    ),
                    title: Text(
                      _formatTime12h(pTime),
                      style: TextStyle(
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Text(
                      _shortPrayerName(p),
                      style: TextStyle(
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                        fontSize: 16,
                        color: isNext ? const Color(0xFF2B6CB0) : Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
