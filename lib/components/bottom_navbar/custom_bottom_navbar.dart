import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int initialIndex;

  const CustomBottomNavigationBar({Key? key, required this.initialIndex}) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    
    return BottomNavigationBar(
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
          GoRouter.of(context).push("/$index");

        },
      );
  }
}