// ignore_for_file: prefer_const_constructors

import 'package:flowmi/components/page_slider/page_slider.dart';
import 'package:flowmi/pages/schedule_page.dart';
import 'package:flowmi/pages/setting_page.dart';
import 'package:flowmi/routes/app_routes.dart';
import 'package:flowmi/state_manage/map_state/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'my_styles.dart';
import 'pages/map_page.dart';


void main() {
  runApp(
    // ******************* Run App with Providers ******************* 
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=> MapProvider()),
    ],
    child: const MyApp(),)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Connecting the defined routes
      routerConfig: FlowmiAppRouter().router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.startIndex});

  final String title;
  final String startIndex;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  double barIconWidth = 20;

@override
void initState() {
  super.initState();
  // Assign the passes start index for home page
  _selectedIndex = int.parse(widget.startIndex);
}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	  // extendBodyBehindAppBar: true,
		
	  // ***************** Page Selector ******************
      body:PageSliderCarousel(
        pages: [
          Center(child: SchedulePage()),
          Center(child: Text('Page 2')),
          Center(child: MapPage()),
          Center(child: Text('Page 4')),
          Center(child: SettingPage()),
          // ... more pages
        ],
        initialPage: _selectedIndex,
      ),
    );
  }
}
