import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../my_styles.dart';


class PageSliderCarousel extends StatefulWidget {
  final List<Widget> pages;
  final int initialPage;

  const PageSliderCarousel({
    super.key,
    required this.pages,
    required this.initialPage,
  });

  @override
  _PageSliderCarouselState createState() => _PageSliderCarouselState();
}

class _PageSliderCarouselState extends State<PageSliderCarousel> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    // ****************** Wrap the page list in a Page Viewer ****************** 
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: widget.pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/calendar.png', width: barIconWidth),
            label: '',
            activeIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: const [purpleTheme, blueTheme],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child:
                  Image.asset('assets/icons/calendar.png', width: barIconWidth),
            ),
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset('assets/icons/analytics.png', width: barIconWidth),
            label: '',
            activeIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: const [purpleTheme, blueTheme],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: Image.asset('assets/icons/analytics.png',
                  width: barIconWidth),
            ),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/map.png', width: barIconWidth),
            label: '',
            activeIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: const [purpleTheme, blueTheme],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: Image.asset('assets/icons/map.png', width: barIconWidth),
            ),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/notification.png',
                width: barIconWidth),
            label: '',
            activeIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: const [purpleTheme, blueTheme],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: Image.asset('assets/icons/notification.png',
                  width: barIconWidth),
            ),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/menu.png', width: barIconWidth),
            label: '',
            activeIcon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: const [purpleTheme, blueTheme],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: Image.asset('assets/icons/menu.png', width: barIconWidth),
            ),
          ),
        ],
        currentIndex: _currentPageIndex,
        unselectedItemColor: const Color(0xFFD1D7EA),
        selectedItemColor: null,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}