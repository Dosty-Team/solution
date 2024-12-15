import 'package:flowmi/main.dart';
import 'package:flowmi/pages/edit_profile.dart';
import 'package:flowmi/pages/edit_task.dart';
import 'package:flowmi/pages/live_cam_page.dart';
import 'package:flowmi/pages/login.dart';
import 'package:flowmi/pages/manage_notification.dart';
import 'package:flowmi/pages/schedule_page.dart';
import 'package:flowmi/pages/set_commute.dart' as commute;
 
import 'package:flowmi/pages/set_task.dart';
import 'package:flowmi/pages/set_timing.dart';
import 'package:flowmi/pages/setting_page.dart';
import 'package:go_router/go_router.dart';
import "../my_styles.dart";
import 'package:flowmi/my_styles.dart' as styles;
 
class FlowmiAppRouter{
  final GoRouter router = GoRouter(
    // Initially go to the the map page index
    initialLocation: '/${pageIndex['map'] as int}',
    // initialLocation: '/${pageIndex['setting'] as int}',
    // initialLocation: '/set_commute',
    // initialLocation: '/set_timing',
    // initialLocation: '/set_task',
    routes: [
      GoRoute(
        path: '/set_commute',
        builder: (context, state) {
          return commute.SetCommutePage();
        },
      ),
      GoRoute(
        path: '/set_timing',
        builder: (context, state) {
          return SetTimingPage();
        },
      ),
      GoRoute(
        path: '/set_task',
        builder: (context, state) {
          return SetTaskPage();
        },
      ),
      GoRoute(
        path: '/livecam/:cameraId',
        builder: (context, state) {
          final cameraId = state.pathParameters['cameraId']!;  // Retrieve the parameter from the route
          return LiveCamPage(cameraId: cameraId);
        },
      ),
       GoRoute(
        path: '/edit_profile',
        builder: (context, state) {
          return EditProfilePage();
        },
      ),
       GoRoute(
        path: '/manage_notification',
        builder: (context, state) {
          return ManageNotificationsPage();
        },
      ),
       GoRoute(
        path: '/edit_task',
        builder: (context, state) {
          return EditTaskPage();
        },
      ),
       GoRoute(
        path: '/login',
        builder: (context, state) {
          return LoginPage();
        },
      ),
      GoRoute(
        path: '/:index',
        // builder: (context, state) => MyHomePage(title: "Map Page", startIndex: 2,),
        builder: (context, state) {
          final index = state.pathParameters['index']!;  // Retrieve the parameter from the route
          return MyHomePage(title: "Home Page", startIndex: index);
        },
      ),
    ],
  );
}