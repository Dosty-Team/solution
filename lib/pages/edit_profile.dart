import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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
        child: TopBar(title: 'Edit Profile'),
      ),
      body: Center(
        child: const Text('Edit Profile'),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: _currentPageIndex),
    );
  }
}



class _ManageNotificationsPageState extends State<EditProfilePage> {
  // A map holding the toggle state of each notification type
  final Map<String, bool> _notifications = {
    "Traffic": true,
    "Weather": false,
    "Real Time Alternative Route": false,
    "Reschedule Alert": true,
    "Others": false
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top Gradient Background
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F2FCC), Color(0xFF8C56F8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top navigation row with title and top right back arrow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Manage Notifications",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    color: Color(0xFFF9FAFB), // a very light background
                    child: Column(
                      children: [
                        // Notifications heading
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Notifications",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                        ),
                        // White card with round corners and switches
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildSwitchTile("Traffic"),
                                _buildDivider(),
                                _buildSwitchTile("Weather"),
                                _buildDivider(),
                                _buildSwitchTile("Real Time Alternative Route"),
                                _buildDivider(),
                                _buildSwitchTile("Reschedule Alert"),
                                _buildDivider(),
                                _buildSwitchTile("Others"),
                              ],
                            ),
                          ),
                        ),
                        // Spacer to push content above bottom nav
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  /// Builds a switch tile for the given notification [title] using the current state from [_notifications].
  Widget _buildSwitchTile(String title) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.black87)),
      value: _notifications[title] ?? false,
      onChanged: (val) {
        setState(() {
          _notifications[title] = val;
        });
      },
      activeColor: Color(0xFF4F2FCC),
    );
  }

  /// A simple divider line used between switch tiles.
  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey[200],
    );
  }

  /// Builds the bottom navigation bar.
  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2))],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.calendar_today_outlined, active: false),
            _buildNavItem(icon: Icons.show_chart, active: false),
            _buildNavItem(icon: Icons.map_outlined, active: false),
            _buildNotificationNavItem(),
            _buildNavItem(icon: Icons.grid_view, active: true), // highlighted last icon
          ],
        ),
      ),
    );
  }

  /// Helper to build individual nav item icons.
  Widget _buildNavItem({required IconData icon, required bool active}) {
    return Icon(
      icon,
      color: active ? Color(0xFF8C56F8) : Colors.grey[300],
      size: 30,
    );
  }

  /// Builds the notification nav item with a small purple dot indicator.
  Widget _buildNotificationNavItem() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.notifications_none,
          color: Colors.grey[300],
          size: 30,
        ),
        Positioned(
          right: 8,
          top: 10,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Color(0xFF8C56F8),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
