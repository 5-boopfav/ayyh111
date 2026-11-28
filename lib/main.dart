import 'package:flutter/material.dart';

void main() {
  runApp(const MushafApp());
}

class MushafApp extends StatelessWidget {
  const MushafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MushafReaderScreen(),
    );
  }
}

class MushafReaderScreen extends StatefulWidget {
  const MushafReaderScreen({super.key});

  @override
  State<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends State<MushafReaderScreen> {
  int _currentPageIndex = 0;

  // ضع هنا مسارات صور المصحف الفعلية عند توفرها، مثل:
  // final List<String> _mushafAssets = [
  //   'assets/mushaf/001.png',
  //   'assets/mushaf/002.png',
  // ];
  final List<String> _mushafAssets = const [];

  List<Widget> _buildPages() {
    if (_mushafAssets.isNotEmpty) {
      return _mushafAssets
          .map((path) => MushafAssetPage(assetPath: path))
          .toList();
    }

    return List.generate(
      10,
      (index) => MushafPlaceholderPage(pageNumber: index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Scaffold(
      backgroundColor: const Color(0xFF171512),
      appBar: AppBar(
        backgroundColor: const Color(0xFF231F1A),
        foregroundColor: const Color(0xFFF5EEDB),
        title: Text('صفحة ${_currentPageIndex + 1}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: MushafSelfTwistingPager(
          initialPage: _currentPageIndex,
          pages: pages,
          imageAssetPaths: _mushafAssets.isNotEmpty ? _mushafAssets : null,
          onPageChanged: (newIndex) {
            setState(() {
              _currentPageIndex = newIndex;
            });
          },
        ),
      ),
    );
  }
}

class MushafAssetPage extends StatelessWidget {
  final String assetPath;

  const MushafAssetPage({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFBF0),
      alignment: Alignment.center,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              'تعذر تحميل الصفحة:\n$assetPath',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF5A4A32)),
            ),
          );
        },
      ),
    );
  }
}

class MushafPlaceholderPage extends StatelessWidget {
  final int pageNumber;

  const MushafPlaceholderPage({
    super.key,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD9CBA8), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'صفحة $pageNumber',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B2419),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'اسحب من اليمين لليسار للصفحة التالية، أو من اليسار لليمين للصفحة السابقة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF4A3F2D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TurnDirection { none, next, previous }

class MushafSelfTwistingPager extends StatefulWidget {
  final List<Widget> pages;
  final List<String>? imageAssetPaths;
  final int initialPage;
  final ValueChanged<int>? onPageChanged;

  const MushafSelfTwistingPager({
    super.key,
    required this.pages,
    this.imageAssetPaths,
    this.initialPage = 0,
    this.onPageChanged,
  }) : assert(pages.length > 0, 'يجب تمرير صفحة واحدة على الأقل');

  @override
  State<MushafSelfTwistingPager> createState() =>
      _MushafSelfTwistingPagerState();
}

class _MushafSelfTwistingPagerState extends State<MushafSelfTwistingPager>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _currentIndex;

  _TurnDirection _direction = _TurnDirection.none;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage.clamp(0, widget.pages.length - 1);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        setState(() {
          _progress = _controller.value;
        });
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheNeighbors(_currentIndex);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheNeighbors(_currentIndex);
  }

  void _precacheNeighbors(int index) {
    final paths = widget.imageAssetPaths;
    if (paths == null || paths.isEmpty) return;

    final indicesToCache = <int>[
      index,
      if (index + 1 < paths.length) index + 1,
      if (index - 1 >= 0) index - 1,
    ];

    for (final i in indicesToCache) {
      if (i >= 0 && i < paths.length) {
        precacheImage(AssetImage(paths[i]), context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasNext => _currentIndex < widget.pages.length - 1;
  bool get _hasPrevious => _currentIndex > 0;

  void _onDragUpdate(DragUpdateDetails details, double width) {
    final dx = details.primaryDelta ?? 0;
    if (dx == 0) return;

    _controller.stop();

    if (_direction == _TurnDirection.none) {
      if (dx < 0 && _hasNext) {
        _direction = _TurnDirection.next;
      } else if (dx > 0 && _hasPrevious) {
        _direction = _TurnDirection.previous;
      } else {
        return;
      }
    }

    if (_direction == _TurnDirection.next) {
      final delta = -dx / width;
      setState(() {
        _progress = (_progress + delta).clamp(0.0, 1.0);
        if (_progress == 0.0) _direction = _TurnDirection.none;
      });
    } else if (_direction == _TurnDirection.previous) {
      final delta = dx / width;
      setState(() {
        _progress = (_progress + delta).clamp(0.0, 1.0);
        if (_progress == 0.0) _direction = _TurnDirection.none;
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_direction == _TurnDirection.none) return;

    final vx = details.primaryVelocity ?? 0;
    final bool completeTurn = switch (_direction) {
      _TurnDirection.next => _progress > 0.38 || vx < -500,
      _TurnDirection.previous => _progress > 0.38 || vx > 500,
      _TurnDirection.none => false,
    };

    if (completeTurn) {
      final finishedDirection = _direction;
      _controller.animateTo(1.0, curve: Curves.easeOutCubic).then((_) {
        if (!mounted) return;
        setState(() {
          if (finishedDirection == _TurnDirection.next && _hasNext) {
            _currentIndex++;
          } else if (finishedDirection == _TurnDirection.previous &&
              _hasPrevious) {
            _currentIndex--;
          }
          _progress = 0.0;
          _direction = _TurnDirection.none;
          _controller.value = 0.0;
        });
        _precacheNeighbors(_currentIndex);
        widget.onPageChanged?.call(_currentIndex);
      });
    } else {
      _controller.animateBack(0.0, curve: Curves.easeOutCubic).then((_) {
        if (!mounted) return;
        setState(() {
          _progress = 0.0;
          _direction = _TurnDirection.none;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
          onHorizontalDragEnd: _onDragEnd,
          child: SizedBox(
            width: width,
            height: height,
            child: _buildLayeredPages(width),
          ),
        );
      },
    );
  }

  Widget _buildLayeredPages(double width) {
    final currentPage = widget.pages[_currentIndex];

    if (_direction == _TurnDirection.next && _hasNext) {
      final nextPage = widget.pages[_currentIndex + 1];
      final twistFactor = _progress * (1.0 - _progress * 0.45);
      final translateX = -width * _progress;
      final rotateZ = -0.09 * twistFactor;

      return Stack(
        fit: StackFit.expand,
        children: [
          nextPage,
          _EdgeShadow(
            left: (width + translateX).clamp(0.0, width),
            opacity: (0.22 * (1.0 - _progress * 0.5)).clamp(0.0, 0.25),
          ),
          _TwistingPageLayer(
            progress: twistFactor,
            transform: Matrix4.identity()
              ..translate(translateX, 0.0)
              ..rotateZ(rotateZ),
            child: currentPage,
          ),
        ],
      );
    }

    if (_direction == _TurnDirection.previous && _hasPrevious) {
      final prevPage = widget.pages[_currentIndex - 1];
      final twistFactor = (1.0 - _progress) * (1.0 - (1.0 - _progress) * 0.45);
      final translateX = -width * (1.0 - _progress);
      final rotateZ = 0.09 * twistFactor;

      return Stack(
        fit: StackFit.expand,
        children: [
          currentPage,
          _EdgeShadow(
            left: (width + translateX).clamp(0.0, width),
            opacity: (0.22 * _progress).clamp(0.0, 0.25),
          ),
          _TwistingPageLayer(
            progress: twistFactor,
            transform: Matrix4.identity()
              ..translate(translateX, 0.0)
              ..rotateZ(rotateZ),
            child: prevPage,
          ),
        ],
      );
    }

    return currentPage;
  }
}

class _TwistingPageLayer extends StatelessWidget {
  final Widget child;
  final Matrix4 transform;
  final double progress;

  const _TwistingPageLayer({
    required this.child,
    required this.transform,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.centerLeft,
      transform: transform,
      child: ClipPath(
        clipper: _PageTwistClipper(progress: progress),
        child: child,
      ),
    );
  }
}

class _PageTwistClipper extends CustomClipper<Path> {
  final double progress;

  _PageTwistClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final indent = (size.width * 0.08 * progress).clamp(0.0, size.width * 0.12);
    final edgeX = size.width - indent;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(edgeX, 0)
      ..quadraticBezierTo(
        (edgeX - indent * 0.65).clamp(0.0, size.width),
        size.height * 0.5,
        edgeX,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _PageTwistClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _EdgeShadow extends StatelessWidget {
  final double left;
  final double opacity;

  const _EdgeShadow({
    required this.left,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: left,
      width: 20,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: opacity),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
