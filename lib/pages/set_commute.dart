import 'dart:convert';
import 'package:flowmi/pages/mapentry.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart' as mongo;

// Import your custom widgets and services
import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flowmi/pages/set_commute_database_service.dart';

// A global pageIndex map assumed from your code context
Map<String, int> pageIndex = {
  "setting": 0,
};

class SetCommutePage extends StatefulWidget {
  @override
  _SetCommutePageState createState() => _SetCommutePageState();
}

class _SetCommutePageState extends State<SetCommutePage> {
  int _currentPageIndex = 0;
  double _formHeight = 185;

  // Controllers for "From" and "To" text fields
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();

  // FocusNodes to track focus changes
  FocusNode _fromFocusNode = FocusNode();
  FocusNode _toFocusNode = FocusNode();

  // Keys to find position of TextFields
  GlobalKey _fromKey = GlobalKey();
  GlobalKey _toKey = GlobalKey();

  // Place Autocomplete data
  List<String> _fromPlaceList = [];
  List<String> _toPlaceList = [];
  Map<String, String> _fromPlaceIds = {};
  Map<String, String> _toPlaceIds = {};

  final String PLACES_API_KEY = "AIzaSyCNd3OWwHFDxhTzbeYonZMd4nCC2yPGxMI";
  final DatabaseService dbService = DatabaseService();

  OverlayEntry? _fromOverlayEntry;
  OverlayEntry? _toOverlayEntry;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = pageIndex["setting"]!;

    _fromFocusNode.addListener(() {
      if (!_fromFocusNode.hasFocus) {
        _removeFromOverlay();
      }
    });

    _toFocusNode.addListener(() {
      if (!_toFocusNode.hasFocus) {
        _removeToOverlay();
      }
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  Future<void> _getPlaceSuggestions(String input, bool isFrom) async {
    if (input.isEmpty) {
      setState(() {
        if (isFrom) {
          _fromPlaceList = [];
          _fromPlaceIds = {};
        } else {
          _toPlaceList = [];
          _toPlaceIds = {};
        }
      });
      _removeOverlays(isFrom);
      return;
    }

    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$PLACES_API_KEY';

    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> predictions = data['predictions'];
        List<String> placeNames = [];
        Map<String, String> placeIds = {};
        for (var prediction in predictions) {
          placeNames.add(prediction['description']);
          placeIds[prediction['description']] = prediction['place_id'];
        }
        setState(() {
          if (isFrom) {
            _fromPlaceList = placeNames;
            _fromPlaceIds = placeIds;
          } else {
            _toPlaceList = placeNames;
            _toPlaceIds = placeIds;
          }
        });
        _showOverlay(isFrom);
      } else {
        print("Failed to fetch predictions. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching place suggestions: $e");
    }
  }

  Future<Map<String, double>> _getLatLngFromPlaceId(String placeId) async {
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=$PLACES_API_KEY';
    try {
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var location = data['result']['geometry']['location'];
        return {
          'latitude': location['lat'],
          'longitude': location['lng'],
        };
      } else {
        print("Failed to fetch place details. Status code: ${response.statusCode}");
        throw Exception('Failed to load coordinates');
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
      throw Exception("Error fetching coordinates: $e");
    }
  }

  Future<void> _handleCoordinatesLogging(String sourceName, String destName) async {
    bool startcondition = true;  
    if (startcondition) {
      if (_fromPlaceIds.containsKey(_fromController.text) && 
          _toPlaceIds.containsKey(_toController.text)) {
        try {
          var fromCoordinates = await _getLatLngFromPlaceId(_fromPlaceIds[_fromController.text]!);
          var toCoordinates = await _getLatLngFromPlaceId(_toPlaceIds[_toController.text]!);

          double fromLat = fromCoordinates['latitude'] ?? 0.0;
          double fromLng = fromCoordinates['longitude'] ?? 0.0;
          double toLat = toCoordinates['latitude'] ?? 0.0;
          double toLng = toCoordinates['longitude'] ?? 0.0;

          await dbService.insertSourceCoordinates(fromLat, fromLng, sourceName);
          await dbService.insertDestinationCoordinates(toLat, toLng,   destName);
          print("Coordinates logged to database.");
        } catch (e) {
          print("Error in inserting coordinates: $e");
        }
      } else {
        print("No valid place IDs found for From/To.");
      }
    } else {
      print('Attempting to fetch coordinates');
      List<List<dynamic>> listlog = await dbService.fetchData();
      print('The list of logged coordinates: $listlog');
    }
  }

  /// Posts the source and destination place names to a server
  /// Adjust the URL and JSON structure as per your backend requirements.
   
  void _showOverlay(bool isFrom) {
    _removeOverlays(isFrom);

    RenderBox box = (isFrom ? _fromKey.currentContext!.findRenderObject() : _toKey.currentContext!.findRenderObject()) as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        List<String> suggestions = isFrom ? _fromPlaceList : _toPlaceList;
        if (suggestions.isEmpty) return SizedBox.shrink();

        return Positioned(
          left: position.dx,
          top: position.dy + box.size.height,
          width: box.size.width,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 200, // Limit height if too many suggestions
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      setState(() {
                        if (isFrom) {
                          _fromController.text = suggestions[index];
                          _fromPlaceList = [];
                        } else {
                          _toController.text = suggestions[index];
                          _toPlaceList = [];
                        }
                      });
                      _removeOverlays(isFrom);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (isFrom) {
      _fromOverlayEntry = overlayEntry;
    } else {
      _toOverlayEntry = overlayEntry;
    }

    Overlay.of(context).insert(overlayEntry);
  }

  void _removeFromOverlay() {
    _fromOverlayEntry?.remove();
    _fromOverlayEntry = null;
  }

  void _removeToOverlay() {
    _toOverlayEntry?.remove();
    _toOverlayEntry = null;
  }

  void _removeOverlays(bool isFrom) {
    if (isFrom) {
      _removeFromOverlay();
    } else {
      _removeToOverlay();
    }
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
          MyDirectionsScreen(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Container(
                    height: _formHeight,
                    decoration: BoxDecoration(
                      color: lightPurpleBox,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        // "From" Text Field
                        TextField(
                          key: _fromKey,
                          controller: _fromController,
                          focusNode: _fromFocusNode,
                          maxLines: 1,
                          minLines: 1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'From',
                            hintStyle: TextStyle(
                              color: lightGrayText,
                            ),
                            suffixIcon: Icon(Icons.home, color: purpleBorder),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: purpleBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: purpleBorder,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            _getPlaceSuggestions(value, true);
                          },
                        ),
                        const Spacer(),
                        Icon(Icons.loop, color: purpleBorder, size: 28,),
                        const Spacer(),

                        // "To" Text Field
                        TextField(
                          key: _toKey,
                          controller: _toController,
                          focusNode: _toFocusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'To',
                            hintStyle: TextStyle(
                              color: lightGrayText,
                            ),
                            suffixIcon: Icon(Icons.location_on, color: purpleBorder),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: purpleBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: purpleBorder,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            _getPlaceSuggestions(value, false);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Next Button
                  Column(
                    children: [
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () async {
                            // Show a loader while awaiting
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator.adaptive(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 255, 255)),
                                  strokeWidth: 4.0,
                                  semanticsLabel: 'Loading...',
                                  semanticsValue: 'Loading commute coordinates...',
                                ),
                              ),
                            );

                            // Log coordinates before navigating
                            await _handleCoordinatesLogging(_fromController.text, _toController.text);

                  
                            Navigator.of(context).pop(); // Remove the loader
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
                    ],
                  ),
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
