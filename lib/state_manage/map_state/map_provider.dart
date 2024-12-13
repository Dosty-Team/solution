import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import "map_data_model.dart";
import 'package:flutter/material.dart';
import "../../data/cam_data/cam_data.dart";

final LatLng homeLocData = const LatLng(27.720315813029938, 85.28665510352454);
// Nagarjuna College of IT
final LatLng destinationLocData =
    const LatLng(27.680002171733012, 85.32980000317724);

class MapProvider with ChangeNotifier {
  // Initialize the map data from the map data structure
  MapData _mapData = MapData(
    homeLoc: homeLocData,
    destinationLoc: destinationLocData,
    cameraPosition: const CameraPosition(
        target: LatLng(27.720315813029938, 85.28665510352454), zoom: 10.0),
    markers: {
      Marker(markerId: MarkerId("homeLoc"), position: homeLocData),
      Marker(
          markerId: MarkerId("destinationLoc"), position: destinationLocData),
    },
    camMarkers: Set<Marker>.from(cameraMarkers.map((cameraMarker) => Marker(
          markerId: MarkerId(cameraMarker.id),
          position: cameraMarker.position,
          icon: BitmapDescriptor.defaultMarker
        ))),
    polylines: {
      Polyline(
        polylineId: PolylineId("route1"),
        visible: true,
        // Add your actual route coordinates here
        points: [homeLocData, destinationLocData],
        color: Colors.blue,
      ),
    },
  );

// Getter to access the map data frm anywhere in the app
  MapData get mapData => _mapData;

  // ... other methods to update map data as needed

  void updateCameraPosition(CameraPosition newPosition) {
    _mapData.cameraPosition = newPosition;
    notifyListeners();
  }
  // ... other methods to update markers, polylines, etc.
}
