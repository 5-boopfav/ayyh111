import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCity = 'الرياض';
  String _selectedMethod = 'أم القرى';
  bool _prayerAlerts = true;
  bool _azkarReminders = true;

  final List<String> _cities = const [
    'الرياض',
    'مكة المكرمة',
    'المدينة المنورة',
    'جدة',
    'الدمام',
  ];

  final List<String> _methods = const [
    'أم القرى',
    'رابطة العالم الإسلامي',
    'الهيئة العامة للمساحة المصرية',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مواقيت الصلاة والحساب',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'المدينة الافتراضية',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _cities
                      .map(
                        (city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCity = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'طريقة الحساب',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _methods
                      .map(
                        (method) => DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMethod = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تنبيهات مواقيت الصلاة'),
                  subtitle: const Text('تفعيل مؤشرات التنبيه للصلوات الخمس'),
                  value: _prayerAlerts,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _prayerAlerts = val;
                    });
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                SwitchListTile(
                  title: const Text('تذكير الأذكار والورد'),
                  subtitle: const Text('تنبيهات أذكار الصباح والمساء ومتابعة الختمة'),
                  value: _azkarReminders,
                  activeTrackColor: primaryColor,
                  onChanged: (val) {
                    setState(() {
                      _azkarReminders = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عن التطبيق والمصادر',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تطبيق «يومك بنور الله» — مواقيت الصلاة، حصن المسلم، ومتابعة الختمة.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 6),
                Text(
                  'المراجع المعتمدة: «حصن المسلم» للأذكار، ومصحف المدينة النبوية (604 صفحات) للختمة.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
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
