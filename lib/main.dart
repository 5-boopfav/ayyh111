import 'package:flutter/material.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/azkar_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YoumakBinourAllahApp());
}

class YoumakBinourAllahApp extends StatelessWidget {
  const YoumakBinourAllahApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF0E6B5D);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'يومك بنور الله',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1D1F),
          elevation: 0.5,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    PrayerTimesScreen(),
    QuranScreen(),
    AzkarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withValues(alpha: 0.14),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'مواقيت الصلاة',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'الختمة',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: 'الأذكار',
          ),
        ],
      ),
    );
  }
}
