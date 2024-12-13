import 'package:google_maps_flutter/google_maps_flutter.dart';

// ***************** Data Model for Map  *****************
class MapData {
  LatLng homeLoc;
  LatLng destinationLoc;
  CameraPosition cameraPosition;
  Set<Marker> markers;
  Set<Marker>? camMarkers;
  Set<Polyline> polylines;



  MapData({
    required this.homeLoc,
    required this.destinationLoc,
    required this.cameraPosition,
    required this.markers,
    this.camMarkers,
    required this.polylines,
  });
}