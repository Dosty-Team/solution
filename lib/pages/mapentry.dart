import 'package:flowmi/pages/map.dart';
import 'package:flowmi/pages/set_commute_database_service.dart';
import 'package:flutter/material.dart';
 
class MyDirectionsScreen extends StatelessWidget {
  const MyDirectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseService().fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a centered loader
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          print('No coordinates found in the database.');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No coordinates found in the database.')),
            );
          });
          return const Center(child: Text('Error loading directions.'));
        } else {
          final coordinates = snapshot.data as List<List<dynamic>>;
          // Coordinates are assumed to be in this order: [ [destLat, destLng], [originLat, originLng] ]
          // Adjust indexing if needed based on your data structure.
          final origin = '${coordinates[1][0]},${coordinates[1][1]}';
          print('checking origin from mapentry.dart is $origin');
          final destination = '${coordinates[0][0]},${coordinates[0][1]}';
          print('checking destination from mapentry.dart is $destination');
          final departureTime = DateTime.now().toUtc().add(const Duration(minutes: 10));
          final apiKey = "AIzaSyCNd3OWwHFDxhTzbeYonZMd4nCC2yPGxMI"; // Replace with your Directions API key

          // Directly return the TrafficDirectionsMap without a Scaffold or AppBar
          return TrafficDirectionsMap(
            origin: origin,
            destination: destination,
            apiKey: apiKey,
            departureTime: departureTime,
            showAlternatives: true,
          );
        }
      },
    );
  }
}/*************  ✨ Codeium Command ⭐  *************/
/******  9b6fe770-e75b-4217-b157-0e853efb7b33  *******/  /// Computes the bounding box of a list of points, and combines it with an

  /// existing bounding box if provided.
