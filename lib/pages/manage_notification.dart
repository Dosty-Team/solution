import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';

class ManageNotificationPage extends StatefulWidget {
  const ManageNotificationPage({super.key});

  @override
  State<ManageNotificationPage> createState() => _ManageNotificationPageState();
}

class _ManageNotificationPageState extends State<ManageNotificationPage> {
  int _currentPageIndex = 0;

   @override
  void initState() {
    super.initState();
    _currentPageIndex = pageIndex["setting"] as int;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(title: 'Manage Notification'),
      ),
      body: Center(
        child: const Text('Manage Notification'),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: _currentPageIndex),
    );
  }
}