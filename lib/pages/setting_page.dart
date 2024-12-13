import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(title: 'Menu'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            // User profile section
            _buildUserProfile(),

            const SizedBox(height: 20),

            // Settings options section
            _buildSettingOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Column(
      children: [
        Stack(
      children: [
        // User profile photo (rounded)
        CircleAvatar(
          radius: 45,
          backgroundImage: const AssetImage('assets/img/user-profile.png'), // Replace with your asset path
        ),

        // Edit icon positioned on bottom right
        Positioned(
          bottom: -12,
          right: -12,
          child: IconButton(
            onPressed: () {},
            icon: Image.asset("assets/icons/profile-edit.png", width: 20,),
            iconSize: 20,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    ),
    SizedBox(height: 5,),
    // User name below photo (medium bold text)
    Container(
      child: Text(
        'Aayush Sharma',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: darkGrayText
        ),
      ),
    ),

    // User email below username (very small text)
    Container(
      child: Text(
        'aayushsharma123@gmail.com',
        style: TextStyle(
          fontSize: 12,
          color: darkGrayText,
        ),
      ),
    ),
    ]
  ); 
}

  Widget _buildSettingOptions() {
    return Column(
      children: [
        _buildSettingOption("assets/icons/edit-profile-option.png", 'Edit Profile', "edit_profile"),
        _buildSettingOption("assets/icons/manage-notification-option.png", 'Manage Notifications', "manage_notification"),
        _buildSettingOption("assets/icons/edit-task-option.png", 'Edit Task', "edit_task"),
        _buildSettingOption("assets/icons/add-commute-option.png", 'Add Commute', "set_commute"),
        _buildSettingOption("assets/icons/edit-commute-option.png", 'Edit Commute', "set_commute"),
        _buildSettingOption("assets/icons/logout-option.png", 'Logout', "login", textColor: redText),
      ],
    );
  }

  Widget _buildSettingOption(String iconPath, String text, String route, {Color textColor=darkGrayText}) {
    return ListTile(
      visualDensity: VisualDensity.compact, 
      leading: Image.asset(iconPath, width: 24,),
      title: Text(text, style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w400,
        fontSize: smallerText
      ),),
      onTap: () {
        GoRouter.of(context).push("/$route");
      },
      splashColor: optionSelectedBG,
    );
  }
}