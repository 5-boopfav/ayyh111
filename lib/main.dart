import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YoumkBinourAllahApp());
}

class YoumkBinourAllahApp extends StatelessWidget {
  const YoumkBinourAllahApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primarySky = Color(0xFF4F8CC9);
    const surfaceTint = Color(0xFFF3F6F9);

    return MaterialApp(
      title: 'يومك بنور الله',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySky,
          primary: primarySky,
          surface: surfaceTint,
        ),
        scaffoldBackgroundColor: surfaceTint,
        appBarTheme: const AppBarTheme(
          backgroundColor: primarySky,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const HomePrayerScreen(),
    const _PlaceholderTab(
      title: 'حصن المسلم والأذكار',
      subtitle: 'أذكار الصباح والمساء وعداد التسبيح التفاعلي',
      icon: Icons.favorite_border,
    ),
    const _PlaceholderTab(
      title: 'الختمة',
      subtitle: 'متابعة صفحات المصحف وحفظ آخر موضع قراءة',
      icon: Icons.menu_book_outlined,
    ),
    const _PlaceholderTab(
      title: 'الإعدادات',
      subtitle: 'الموقع الجغرافي، طريقة حساب المواقيت، والتنبيهات',
      icon: Icons.more_horiz,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_checked),
            label: 'الأذكار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'المصحف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'والإعدادات',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
