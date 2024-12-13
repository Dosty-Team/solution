import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// *********************** Live Cam Icon ***********************
class CameraMarker {
  final String id;
  final LatLng position;
  final Function() onTap;

  const CameraMarker({required this.id, required this.position, required this.onTap});
}

// List of Traffic Cams in the Map
final List<CameraMarker> cameraMarkers = [
  CameraMarker(
      id: "cam0",
      position: LatLng(27.706773, 85.301715),
      onTap: () {
        print("I am camera 0");
      },
      ),
  CameraMarker(
      id: "cam1",
      position: LatLng(27.700002, 85.309245),
      onTap: () {
        print("I am camera 1");
      },
      ),
  CameraMarker(
      id: "cam2",
      position: LatLng(27.693231, 85.316775),
      onTap: (){
        print("I am camera 2");

      },
      ), 
];