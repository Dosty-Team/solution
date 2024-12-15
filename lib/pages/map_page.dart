import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flowmi/pages/mapentry.dart';
import 'package:flowmi/pages/set_commute_database_service.dart';
import '../my_styles.dart';
import '../components/google_map/map_screen.dart';
import 'package:flowmi/pages/set_commute_source_and_destination.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _showPopup = false; // To control the visibility of the popup
  
  String origin_name = "";
  String destination_name = "";

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
  }

  Future<void> _fetchCoordinates() async {
    try {
      final coordinates = await DatabaseService().fetchData();
      if (coordinates.isEmpty) {
        log('No coordinates found in the database.');
        _showError('No coordinates found in the database.');
        return;
      }

      origin_name = '${coordinates[1][2]}';
      destination_name = '${coordinates[0][2]}';

      setState(() {});
    } catch (e) {
      log('Error fetching coordinates: $e');
      _showError('Error fetching coordinates.');
    }
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String destination = destination_name.isNotEmpty ? destination_name : "Destination";
    destination = destination.length > 20 ? '${destination.substring(0, 17)}...' : destination;
    double homeDestDistance = 9.2;
    String weatherMessage = "Rainfall near Home while travelling from Home to Destination";

    final screenWidth = MediaQuery.of(context).size.width;
    // Choose a width for the popup, for example 80% of the screen width
    final popupWidth = screenWidth * 0.8;
    // Choose a fixed height or a fraction of the screen height
    final popupHeight = 300.0; 

    return Stack(
      children: [
        const MyDirectionsScreen(),

        // ************************ Floating Help Icon ************************
        Positioned(
          bottom: 160,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _showPopup = !_showPopup;
              });
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.help, color: Colors.white),
          ),
        ),

        // ************************ Floating Popup Screen ************************
        if (_showPopup)
          Positioned(
            bottom: 220,
            right: 20,
            child: Container(
              width: popupWidth,
              height: popupHeight,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Need Help?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("1. Head southwest on Sanobharyang Rd."),
                        SizedBox(height: 4),
                        Text("2. Turn right onto Kathmandu Ring Rd (NH39) and keep following it."),
                        SizedBox(height: 4),
                        Text("3. Keep left, then turn left onto Damkal Chakrapath Marg."),
                        SizedBox(height: 4),
                        Text("4. Turn right onto Lamochaur Sadak, continue straight on Machindra Nath Sadak Uttar."),
                        SizedBox(height: 4),
                        Text("5. Follow NH39/Ring Rd, then take left turns onto Museum Marg and Tahachal Marg."),
                        SizedBox(height: 4),
                        Text("6. Turn right onto Tankeshwar Marg, then left onto Ganeshman Singh Rd (NH03)."),
                        SizedBox(height: 4),
                        Text("7. At Tripureshwar, take the 3rd exit to stay on NH03/Tripura Marg."),
                        SizedBox(height: 4),
                        Text("8. Turn right onto Bagmati Bridge (Kupondole Rd) and keep right to Pulchowk Rd/Yala Sadak."),
                        SizedBox(height: 4),
                        Text("9. Go straight, then at the roundabout, take the 3rd exit onto Jawalakhel Ekantakuna Sadak."),
                        SizedBox(height: 4),
                        Text("10. Turn left onto Damodar Marg and keep right to stay on NH39/Ring Rd."),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ************************ Floating Destination Indicator ************************
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 0),
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
                      Image.asset("assets/icons/destination.png", width: iconWidth),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: [purpleTheme, blueTheme],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "To $destination",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              "$homeDestDistance km",
                              style: const TextStyle(fontSize: 11, color: darkGrayText),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),

        // **************** Weather Info and Traffic Analytica Button Container ****************
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
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
                  offset: Offset(0, -5),
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
                      color: purpleBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/icons/rain.png", width: 28),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          weatherMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: darkPurpleText, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ********************* Commute and Analyse Buttons ***********************
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Commute Button
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightPurpleBG,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Commute',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    // Analyse Button
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
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
                                    fontSize: 13),
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
