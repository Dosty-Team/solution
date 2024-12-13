import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/google_map/map_screen.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetCommutePage extends StatefulWidget {
  @override
  _SetCommutePageState createState() => _SetCommutePageState();
}

class _SetCommutePageState extends State<SetCommutePage> {
int _currentPageIndex = 0;
double _formHeight = 185;

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
        child: TopBar(title: 'Set Commute'),
      ),
      body: Stack(
        children: [
          // Positioned.fill(
          //   // child: Image.asset('assets/img/image-placeholder.png', fit: BoxFit.cover,),
          //   // ************** Modify the map to update as per the user input **************
          //   child: MapScreen(),
          // ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, -3), // Adjust the offset to control the shadow's position
                  ),
                ],
              ),
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    height: _formHeight, // Desired height
                    child: Container(
                      decoration: BoxDecoration(
                        color: lightPurpleBox, // Light purple color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          TextField(
                            maxLines: 1,
                            minLines: 1,
                            decoration: InputDecoration(
                              filled: true, // This makes the fill color visible
                              fillColor: Colors.white,
                              hintText: 'From',
                              hintStyle: TextStyle(
                                color: lightGrayText, // Hint text color
                              ),
                              suffixIcon: Icon(Icons.home, color: purpleBorder),
                              contentPadding: EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: purpleBorder, // Default border color
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: purpleBorder, // Initial border color
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.loop, color: purpleBorder, size: 28,),
                          Spacer(),
                          TextField(
                            decoration: InputDecoration(
                              filled: true, // This makes the fill color visible
                              fillColor: Colors.white,
                              hintText: 'To',
                              hintStyle: TextStyle(
                                color: lightGrayText, // Hint text color
                              ),
                              suffixIcon: Icon(Icons.location_on, color: purpleBorder),
                              contentPadding: EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: purpleBorder, // Default border color
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: purpleBorder, // Initial border color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                      height: 50, // Desired height
                      margin: EdgeInsets.only(top: 15.0),
                      child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, // Removes default padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50), // Rounded corners
                              ),
                            ),
                            // ************************ Next Button Event Handler ************************
                            onPressed: () {
                              GoRouter.of(context).push("/set_timing");
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [purpleTheme, blueTheme],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Container(
                                // padding: const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: mediumText
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ]),
                ],
              ),
            ),
          ),
        ],
      ),
    bottomNavigationBar: CustomBottomNavigationBar(initialIndex: _currentPageIndex),
    );
  }
}
