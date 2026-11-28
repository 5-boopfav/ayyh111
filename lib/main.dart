import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BahmadMushafApp());
}

class BahmadMushafApp extends StatelessWidget {
  const BahmadMushafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'مصحف بحمد',
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MushafPageFlipScreen(),
      ),
    );
  }
}

class MushafPageFlipScreen extends StatefulWidget {
  const MushafPageFlipScreen({super.key});

  @override
  State<MushafPageFlipScreen> createState() => _MushafPageFlipScreenState();
}

class _MushafPageFlipScreenState extends State<MushafPageFlipScreen> {
  static const int totalPages = 604;
  final GlobalKey<PageFlipWidgetState> _pageFlipKey =
      GlobalKey<PageFlipWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: PageFlipWidget(
          key: _pageFlipKey,
          backgroundColor: const Color(0xFF1E1E1E),
          lastPage: _buildQuranPage(totalPages),
          children: List.generate(
            totalPages - 1,
            (index) => _buildQuranPage(index + 1),
          ),
        ),
      ),
    );
  }

  Widget _buildQuranPage(int pageNumber) {
    final String assetPath = 'assets/images/quran/$pageNumber.png';

    return Container(
      color: const Color(0xFFFDF7EA),
      child: SizedBox.expand(
        child: Image.asset(
          assetPath,
          fit: BoxFit.fill,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_stories,
                    size: 44,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'صفحة المصحف رقم $pageNumber من $totalPages',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    assetPath,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
