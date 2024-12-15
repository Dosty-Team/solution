import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng, GoogleMapController, Polyline, BitmapDescriptor;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; 
import 'package:flowmi/state_manage/map_state/map_provider.dart';

class TrafficDirectionsMap extends StatefulWidget {
  final String origin;         
  final String destination;    
  final String apiKey;         
  final DateTime departureTime; 
  final bool showAlternatives;

  const TrafficDirectionsMap({
    Key? key,
    required this.origin,
    required this.destination,
    required this.apiKey,
    required this.departureTime,
    this.showAlternatives = true,
  }) : super(key: key);

  @override
  State<TrafficDirectionsMap> createState() => _TrafficDirectionsMapState();
}

class _TrafficDirectionsMapState extends State<TrafficDirectionsMap> {
  GoogleMapController? _controller;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  LatLngBounds? _mapBounds;
  bool _isLoading = true;
  String? _errorMessage;

  late LatLng _originLatLng;
  late LatLng _destinationLatLng;

  // The given coordinate: 27°42'32.4"N 85°18'52.8"E ≈ (27.709, 85.3147)
  final cctvLatLng = const LatLng(27.709, 85.3147);

  @override
  void initState() {
    super.initState();
    _originLatLng = _parseLatLng(widget.origin);
    _destinationLatLng = _parseLatLng(widget.destination);
    _fetchAndDisplayRoutes();
  }

  LatLng _parseLatLng(String coordinateString) {
    final parts = coordinateString.split(',');
    final lat = double.tryParse(parts[0].trim()) ?? 0.0;
    final lng = double.tryParse(parts[1].trim()) ?? 0.0;
    return LatLng(lat, lng);
  }

  Future<void> _fetchAndDisplayRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _fetchDirections();
      if (response == null) {
        setState(() {
          _errorMessage = "No directions found.";
          _isLoading = false;
        });
        return;
      }

      final routes = response['routes'];
      if (routes == null || routes.isEmpty) {
        setState(() {
          _errorMessage = "No routes returned by the API.";
          _isLoading = false;
        });
        return;
      }

      log('Number of routes returned: ${routes.length}');
      _polylines.clear();
      _markers.clear();

      LatLngBounds? bounds;

      // Process dynamic routes from API
      for (int i = 0; i < routes.length; i++) {
        final route = routes[i];
        final overviewPolyline = route['overview_polyline']['points'];
        final List<LatLng> routePoints = _decodePolyline(overviewPolyline);

        final legs = route['legs'] as List;
        final segments = _buildSegments(legs);

        for (var segment in segments) {
          _polylines.add(Polyline(
            polylineId: PolylineId('route_${i}_segment_${segment.id}'),
            points: segment.points,
            color: segment.color,
            width: 6,
          ));
        }

        bounds = _computeBounds(routePoints, bounds);
      }

      // Add origin/destination markers as before
      _markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: _originLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: "Origin"),
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "Destination"),
        ),
      );

      // Retrieve camera markers from MapProvider
      final imageConfiguration = ImageConfiguration(devicePixelRatio: MediaQuery.of(context).devicePixelRatio);
        final cameraIcon = await BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/icons/big-cam.png');
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/icons/big-cam.png').then((cameraIcon) async {
        final camMarkers = context.read<MapProvider>().mapData.camMarkers
            ?.map((camMarker) => Marker(
                  markerId: camMarker.markerId,
                  position: camMarker.position,
                  icon: cameraIcon,
                  onTap: () {
                    final camId = camMarker.markerId.value;
                    GoRouter.of(context).push("/livecam/$camId");
                  },
                ))
            .toSet() ?? {};
        _markers.addAll(camMarkers);

        // Add separate static polyline (yellow) using given points
        String polyline1 = "{mdhDwgvgOBAHGFABADAF?F?J@jCZb@Fb@DpEj@@?`DZH@H@h@Fl@FZDlALfBPnBPLBt@F~@Jx@Fp@FH@H@p@F~@JfCT";
        String polyline2 = "{mdhDwgvgOBAHGFABADAF?F?J@jCZb@Fb@DpEj@@?`DZH@H@h@Fl@FZDlALfBPnBPLBt@F~@Jx@Fp@FH@H@p@F~@JfCT";
        final staticPoints1 = _decodePolyline(polyline1);
        final staticPoints2 = _decodePolyline(polyline2);
        final combinedStaticPoints = [...staticPoints1, ...staticPoints2];

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('static_source_dest'),
            points: combinedStaticPoints,
            color: Colors.yellow, // Color the static polyline yellow
            width: 5,
          ),
        );

        // Place a camera icon marker at the given coordinate (cctvLatLng)
        // final cameraIcon = await BitmapDescriptor.fromAssetImage(imageConfiguration, 'assets/icons/big-cam.png');
        _markers.add(
          Marker(
            markerId: const MarkerId('cctv_marker'),
            position: cctvLatLng,
            icon: cameraIcon,
            onTap: () {
              GoRouter.of(context).push("/livecam/jamal");
            },
          ),
        );

        setState(() {
          _isLoading = false;
          _mapBounds = bounds;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller != null && _mapBounds != null) {
            _controller!.animateCamera(CameraUpdate.newLatLngBounds(_mapBounds!, 50));
          }
        });
      });
    } catch (e, st) {
      log('Error fetching directions: $e\n$st');
      setState(() {
        _errorMessage = "Failed to fetch directions.";
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchDirections() async {
  final departureDateTime = widget.departureTime.toUtc().add(const Duration(days: 3));
  // Convert to a UNIX timestamp (in seconds) as a string
  final departureTimestamp = (departureDateTime.millisecondsSinceEpoch ~/ 1000).toString();

  final Uri url = Uri.parse("https://maps.googleapis.com/maps/api/directions/json").replace(
    queryParameters: {
      'origin': widget.origin,
      'destination': widget.destination,
      'departure_time': departureTimestamp, // Pass the numeric timestamp string
      'mode': 'driving',
      'alternatives': 'true',
      'key': widget.apiKey,
    },
  );

  log('Fetching directions: $url');
  final response = await http.get(url);

  log('Directions HTTP status: ${response.statusCode}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    log('Directions API status: ${data['status']}');
    if (data['status'] == 'OK') {
      return data;
    } else {
      log("Error fetching directions: ${data['status']}");
      log("Full response: $data");
      return null;
    }
  } else {
    log("HTTP Error: ${response.statusCode}");
    return null;
  }
}

  String stripHtmlTags(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0; 
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      final p = LatLng(lat / 1E5, lng / 1E5);
      poly.add(p);
    }

    return poly;
  }

  List<_Segment> _buildSegments(List legs) {
    List<_Segment> segments = [];
    int segmentId = 0;

    for (var leg in legs) {
      final steps = leg['steps'] as List;
      for (var step in steps) {
        final polyline = step['polyline']['points'];
        final stepPoints = _decodePolyline(polyline);

        final duration = step['duration']['value'];
        final durationInTraffic = step['duration_in_traffic'] != null
            ? step['duration_in_traffic']['value']
            : duration;

        final trafficRatio = durationInTraffic / duration;
        final segmentColor = _colorForTraffic(trafficRatio);

        if (step.containsKey('html_instructions')) {
          String htmlInstructions = step['html_instructions'];
          String parsedInstructions = stripHtmlTags(htmlInstructions);
          log("Instruction: $parsedInstructions");
        }

        segments.add(_Segment(
          id: segmentId++,
          points: stepPoints,
          color: segmentColor,
        ));
      }
    }

    return segments;
  }

  Color _colorForTraffic(double trafficRatio) {
    if (trafficRatio <= 1.2) {
      return Colors.green;
    } else if (trafficRatio <= 1.3) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  LatLngBounds _computeBounds(List<LatLng> points, LatLngBounds? existingBounds) {
    double south = points.first.latitude;
    double west = points.first.longitude;
    double north = points.first.latitude;
    double east = points.first.longitude;

    for (var p in points) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }

    final newBounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );

    if (existingBounds == null) return newBounds;

    double combinedSouth = existingBounds.southwest.latitude < south ? existingBounds.southwest.latitude : south;
    double combinedWest = existingBounds.southwest.longitude < west ? existingBounds.southwest.longitude : west;
    double combinedNorth = existingBounds.northeast.latitude > north ? existingBounds.northeast.latitude : north;
    double combinedEast = existingBounds.northeast.longitude > east ? existingBounds.northeast.longitude : east;

    return LatLngBounds(
      southwest: LatLng(combinedSouth, combinedWest),
      northeast: LatLng(combinedNorth, combinedEast),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(27.7224492,85.2927936),
            zoom: 30,
          ),
          onMapCreated: (controller) => _controller = controller,
          polylines: _polylines,
          markers: _markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          trafficEnabled: false,
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
        if (_errorMessage != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white.withOpacity(0.8),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.black)),
            ),
          ),
      ],
    );
  }
}

class _Segment {
  final int id;
  final List<LatLng> points;
  final Color color;

  _Segment({
    required this.id,
    required this.points,
    required this.color,
  });
}
