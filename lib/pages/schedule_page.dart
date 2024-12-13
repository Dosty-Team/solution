import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:withoutmap/Notification/notification.dart';
// import 'package:withoutmap/login/login.dart';
// import 'recommend/recommend_commute_page.dart';
// import 'setting/settings_page.dart';  // Import the settings page
// import 'analysis/trafficmap.dart';


class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF2F5FF),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                buildTopNav(),
                buildBottomafternav(),
                buildScheduleIndicator(context),
                buildHeading(),
                
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: buildTaskList(),
                ),
              ],
            ),
          ),
        ],
      ),    
      // IF GIVER LE COMMUTE PAGE KO FLOATING WINDOW BANAYENA VANE: USE THIS : floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: buildFloatingAddTaskButton(),
    );
  }

  Widget buildTopNav() {
  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/routebg.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset('assets/left-icon.svg', color: Colors.white, height: 38, width: 38),
                onPressed: () {
                  // Define the back button action, e.g., Navigator.pop(context);
                },
              ),
              Expanded(
                child: Text(
                  "Routine",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Opacity(
                opacity: 0,
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
          // Add a SizedBox for spacing at the bottom
      ],
    ),
  );
}
Widget buildBottomafternav() {
  return SizedBox(
    height: 35,
  );
}
Widget buildScheduleIndicator(BuildContext context) {
  
            
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5), // Different vertical padding
    child: SizedBox(height: 86, // Adjusted for better proportionality
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16), // Padding inside the container for elements
        decoration: BoxDecoration(
          color: Colors.white, // Optional: add background color if needed
          border: Border.all(
            color: Colors.blue, // Color of the border
            width: 2, // Width of the border
          ),
          borderRadius: BorderRadius.all(Radius.circular(50)), // Consistent rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3), // Shadow color
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2), // Shadow position
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Center align the contents
          children: <Widget>[
            SvgPicture.asset(
              'assets/average-indicator-home-icon.svg',
              height: 48, // Slightly reduced to fit better within the new height
              width: 48,
            ),
              SizedBox(
                width: 16, // Gap between the icons and the progress bar
              ),
           Expanded(
             
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Colors.green, Colors.red],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                child: LinearProgressIndicator(
                  
                  value: 0.5,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 10,
                  // for border radius in progress bar
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  
                ),
              ),
              ),
              SizedBox(
                width: 16, // Gap between the icons and the progress bar
              ),
              
            SvgPicture.asset(
              'assets/average-indicator-destination-icon.svg',
              height: 48, // Consistent size with the other icon
              width: 48,
            ),
          ],
        ),
      ),
    ),
  );
 
}

Widget buildHeading() {
  return Container(
    decoration: BoxDecoration(
       border: Border(
        bottom: BorderSide(
          color:Colors.grey[300]!,
          width: 1,
        )
       )
    ),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF4569DC), Color(0xFF9C27B0)],
              ).createShader(Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height)),
              child: Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
         
      ],
    ),
  );
}





  Widget buildTaskList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        buildTask("Workout", "08:00 AM"),
        buildTask("Eat Lunch", "10:00 AM"),
        buildTask("Iron Shirt", "10:45 AM"),
        buildTask("Drink Coffee", "10:50 AM"),
        buildTask("Departure", "11:00 AM"),
        buildTask("Departure", "11:00 AM"),
        buildTask("Departure", "11:00 AM"),
      ],
    );
  }

  Widget buildTask(String name, String time) {
    return Container(
      padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      height: 88.0,
      width: 349.0,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          'assets/calendericon.svg',
          height: 38,
          width: 38,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: Icon(Icons.more_vert),
      ),
    );
  }
//  Widget buildBottomNav(BuildContext  context) {
//     return BottomAppBar(
//       color: Colors.white.withOpacity(0.5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           SvgPicture.asset(
//             'assets/calendericon.svg',
//             height: 24,
//             width: 24,
//           ),
//           IconButton(
//             icon: SvgPicture.asset('assets/calendericon.svg', height: 24, width: 24),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => RoutePlanner()),
//               );
//             },
//           ),
           
//           IconButton(
//             icon: SvgPicture.asset('assets/calendericon.svg', height: 24, width: 24),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => RoutePlanner()),
//               );
//             },
//           ),
           
//            IconButton(
//   icon: SvgPicture.asset('assets/calendericon.svg', height: 24, width: 24),
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CommuteAnalysisPage()), // Navigating to MyBarChart
//     );
//   },
// ),
//           IconButton(
//   icon: SvgPicture.asset('assets/calendericon.svg', height: 24, width: 24),
//   onPressed: () {
//     // Navigator push method to navigate to the new page
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ManageNotificationsPage()), // NewPage is the destination page
//     );
//   },
// ),
// IconButton(
  

//   icon: SvgPicture.asset('assets/calendericon.svg', height: 24, width: 24),
//   onPressed: () {
//     // Navigator push method to navigate to the new page
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => LoginPage()), // NewPage is the destination page
//     );
//   },
// ),


           
//         ],
//       ),
//     );
  }
  // IF GIVER LE COMMUTE PAGE KO FLOATING WINDOW BANAYENA VANE: USE THIS :
  // THINGS TO DO: THAKKYA BOTTOM WIDGET KO MATHI SATAUNE SAME COLOR USE GARERA, 
  //JUST RUN AND SEE YOUTSELF
  //
  //
  // Widget buildFloatingAddTaskButton() {
  //   return Container(
  //     width: double.infinity, // Ensures the button stretches to match the screen width
  //     padding: EdgeInsets.symmetric(vertical: 60), // Padding above and below the button
  //     decoration: BoxDecoration(
  //       color: const Color.fromARGB(10, 104, 58, 183), // Background color of the button
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(10),
  //         topRight: Radius.circular(10),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black12,
  //           blurRadius: 8,
  //           spreadRadius: 4,
  //           offset: Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Container(
  //       width: 10,
  //       height: 60,
  //       decoration: BoxDecoration(
  //         color: const Color.fromARGB(255, 104, 58, 183),
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: TextButton(
  //         onPressed: () {
  //           // Define the button action here
  //         },
  //         child: Text(
  //           "+ Add Task",
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold,
  //             fontSize: 18,
  //           ),
  //       ),
  //     ),
  //     ),
  //   );
  // }

// }
 