import "package:flowmi/state_manage/map_state/map_data_model.dart";
import 'package:flutter/material.dart';
import "../my_styles.dart";
import "../components/google_map/map_screen.dart";
import "package:provider/provider.dart";
import "../state_manage/map_state/map_provider.dart";

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {


  @override
  Widget build(BuildContext context) {

  String destination = "Nagarjuna College of IT";
  double homeDestDistance = 9.2;
  String weatherMessage = "Rainfall near Home while travelling from Home to Destination";


    return Stack(
      children: [
        // ************************ Replace the placeholder image with Map Here ************************
      //  SizedBox.expand(
      //   // ************************ MapScreen Widget with State Management Provider Wrap ************************ 
      //   child: MapScreen(),
      // ),

        // ************************ Floating Destination Indicator ************************  
        Positioned(
            top: 0, // Adjust top margin as needed
            left: 0,
            right: 0,
            child:Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40), // Adjust margins as needed
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 0), // changes position
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/icons/destination.png",
                            width: iconWidth),
                        // const SizedBox(width: 0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [
                                    purpleTheme,
                                    blueTheme
                                  ], // Adjust colors as needed
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text("To $destination",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13, 
                                            ), 
                                    ), // Set text color to white
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text("$homeDestDistance km",
                                  style: const TextStyle(
                                      fontSize: 11, color: darkGrayText )),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ),

          // **************** Weather Info and Traffic Analytica Button Container **************** 
           Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0), // Inner padding
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5), // Shadow positioned upwards
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ************************ Weather Info Box *************************
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: lightPurpleBG,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: purpleBorder, // Replace with your desired border color
                        width: 1.0, // Adjust border width as needed
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/icons/rain.png", width: 28),
                        const SizedBox(width: 8),

                        // Flexible container for long text to wrap it over
                        Flexible(child: 
                          Text(weatherMessage, 
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis, 
                            style: const TextStyle(color: darkPurpleText, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ********************* Commute and Analyze Buttons ***********************
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // First button with gray color
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // primary: Colors.grey[300], // Gray background
                              backgroundColor: lightPurpleBG,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                              ),
                            ),
                            // ************************ Commute Button Event Handler ************************ 
                            onPressed: () {},
                            child: const Text(
                              'Commute',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      // Second button with gradient color
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, // Removes default padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                              ),
                            ),
                            // ************************ Analyse Button Event Handler ************************
                            onPressed: () {},
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [purpleTheme, blueTheme],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Analyse',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
