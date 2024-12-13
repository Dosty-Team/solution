// import 'package:flowmi/pages/live_cam_page.dart';
// import 'package:flowmi/data/cam_data/cam_data.dart';
// import 'package:flowmi/state_manage/map_state/map_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import "package:http/http.dart" as http;
// import 'dart:convert';
// import 'dart:math';
// import "../../my_styles.dart";
// import "package:provider/provider.dart";
// import "../../state_manage/map_state/map_data_model.dart";


// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;
//   BitmapDescriptor cameraIcon = BitmapDescriptor.defaultMarker;
//   Map<PolylineId, Polyline> polylines = {};

//   @override
//   void initState() {
//     setCameraIcon();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MapProvider>(
//       builder: (context, mapProvider, child) {
//         return GoogleMap(
//           onMapCreated: (controller) {
//             _onMapCreated(controller, mapProvider);
//           },
//           initialCameraPosition: CameraPosition(
//             target: mapProvider.mapData.homeLoc,
//             zoom: 10,
//           ),
//           markers: _createMarkers(mapProvider),
//           polylines: Set<Polyline>.of(polylines.values),
//           trafficEnabled: true,
//         );
//       },
//     );
//   }

//   void _onMapCreated(GoogleMapController controller, MapProvider mapProvider) {
//     mapController = controller;
//     _fitCamera(mapProvider.mapData);

//     getPolylinePoints(mapProvider.mapData).then((coordinates) {
//       generatePolylineFromPoints(coordinates);
//     });
//   }

//   Set<Marker> _createMarkers(MapProvider mapProvider) {
//     return {
//       ...mapProvider.mapData.markers,
//       ...?mapProvider.mapData.camMarkers?.map((camMarker) => Marker(
//         markerId: camMarker.markerId,
//         position: camMarker.position,
//         icon: cameraIcon,
//         onTap: () {
//           print("Hi");
//           String camId = camMarker.markerId.value;
//           GoRouter.of(context).push("/livecam/$camId");
//         }
//       )),
//     };
//   }

//   void setCameraIcon() async {
//     final ImageConfiguration imageConfiguration = ImageConfiguration(devicePixelRatio: MediaQuery.of(context).devicePixelRatio);
//     BitmapDescriptor.fromAssetImage(
//       imageConfiguration,
//       'assets/icons/cam-icon.png',
//     ).then((icon) {
//       setState(() {
//         cameraIcon = icon;
//       });
//     });
//   }

//   Future<void> _fitCamera(MapData mapData) async {
//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(
//         min(mapData.homeLoc.latitude, mapData.destinationLoc.latitude),
//         min(mapData.homeLoc.longitude, mapData.destinationLoc.longitude),
//       ),
//       northeast: LatLng(
//         max(mapData.homeLoc.latitude, mapData.destinationLoc.latitude),
//         max(mapData.homeLoc.longitude, mapData.destinationLoc.longitude),
//       ),
//     );

//     double distance = Geolocator.distanceBetween(
//       mapData.homeLoc.latitude,
//       mapData.homeLoc.longitude,
//       mapData.destinationLoc.latitude,
//       mapData.destinationLoc.longitude,
//     );

//     double zoomLevel = 15.0;
//     if (distance > 1000) {
//       zoomLevel = 13.0;
//     } else if (distance > 5000) {
//       zoomLevel = 10.0;
//     }

//     CameraUpdate update = CameraUpdate.newLatLngBounds(bounds, zoomLevel);
//     await mapController.animateCamera(update);
//   }

//   Future<List<LatLng>> getPolylinePoints(MapData mapData) async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();

//     PointLatLng originPoint = PointLatLng(mapData.homeLoc.latitude, mapData.homeLoc.longitude);
//     PointLatLng destPoint = PointLatLng(mapData.destinationLoc.latitude, mapData.destinationLoc.longitude);

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      
//       googleApiKey: GOOGLE_MAPS_API_KEY, 
//       origin: originPoint, 
//       destination: destPoint, 
//       travelMode: TravelMode.driving,
//     );

//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     } else {
//       print(result.errorMessage);
//     }
//     return polylineCoordinates;
//   }

//   Future<List<LatLng>> getMultiRoutePolylinePoints(MapData mapData) async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();

//     final origin = "${mapData.homeLoc.latitude},${mapData.homeLoc.longitude}";
//     final destination = "${mapData.destinationLoc.latitude},${mapData.destinationLoc.longitude}";

//     final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$GOOGLE_MAPS_API_KEY&mode=driving&alternatives=true';
//     final response = await http.get(Uri.parse(url));
//     final data = jsonDecode(response.body);

//     if (data['status'] == 'OK') {
//       final routes = data['routes'];
//       setState(() {
//         polylines = routes.map((route) {
//           final polyPoints = polylinePoints.decodePolyline(route['overview_polyline']['points']);

//           polyPoints.forEach((PointLatLng point){
//             polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//           });
//           return Polyline(
//             polylineId: PolylineId(route['overview_polyline']['points']),
//             points: polylineCoordinates,
//             color: Colors.blue,
//             width: 5,
//           );
//         }).toSet();
//       });
//       print("Test***************");
//       print(polylines);
//     } else {
//       print('Error fetching routes: ${data['error_message']}');
//     }
//     return polylineCoordinates;
//   }

//   void generatePolylineFromPoints(List<LatLng> coords) async {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       visible: true,
//       points: coords,
//       color: Colors.blue,
//     );

//     setState(() {
//       polylines[id] = polyline;
//     });
//   }
// }