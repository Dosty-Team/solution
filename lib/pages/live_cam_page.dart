import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/google_map/map_screen.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "../components/live_cam_slider/live_cam_slider.dart";
import "../my_styles.dart";

class LiveCamPage extends StatefulWidget {
  final String cameraId;

  const LiveCamPage({super.key, required this.cameraId});

  @override
  _LiveCamPageState createState() => _LiveCamPageState();
}

class _LiveCamPageState extends State<LiveCamPage> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = pageIndex["map"] as int;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(title: 'Live Road Condition'),
      ),
      body: Center(
        child: LiveCam(camId: widget.cameraId),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: _currentPageIndex),
    );
  }
}