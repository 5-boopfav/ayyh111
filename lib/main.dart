import 'package:flutter/material.dart';
import 'package:page_flip_view/page_flip_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BahmadMushafFlipTestApp());
}

class BahmadMushafFlipTestApp extends StatelessWidget {
  const BahmadMushafFlipTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'مصحف بحمد - تجربة التقليب',
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: QuranPageFlip(
              pageCount: 604,
              initialPage: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class QuranPageFlip extends StatelessWidget {
  final int pageCount;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;

  const QuranPageFlip({
    super.key,
    this.pageCount = 604,
    this.initialPage = 0,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageFlipView(
      itemCount: pageCount,
      initialPage: initialPage,

      // اتجاه القراءة العربية
      reverse: true,

      // التحكم بالإصبع
      enableDrag: true,

      // تعطيل التكبير حتى لا يتعارض مع السحب
      enableZoom: false,

      // إظهار لون الورقة من الخلف
      paperColor: Colors.white,

      // سرعة استجابة انحناء الورقة للإصبع
      followFactor: 0.22,

      // إشعار التطبيق عند تغيير الصفحة
      onPageChanged: onPageChanged,

      // عرض صفحات المصحف
      itemBuilder: (context, index) {
        final pageNumber = index + 1;

        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/quran/$pageNumber.png',
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'تعذر تحميل صفحة $pageNumber',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
