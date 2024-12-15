import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = "AIzaSyCNd3OWwHFDxhTzbeYonZMd4nCC2yPGxMI"; // Replace with your actual Google Maps Directions API key.

/// Fetch travel time data from Google Directions API.
/// Returns a List of routes, where each route is a List of leg times in minutes.
Future<List<List<double>>?> fetchTravelTime(
    String origin, 
    String destination, 
    DateTime departureTime
  ) async {
  
  final departureTimestamp = DateTime(departureTime.year, departureTime.month, departureTime.day, 10)
      .toUtc()
      .millisecondsSinceEpoch
      .toString();
  final url = Uri.parse(
    "https://maps.googleapis.com/maps/api/directions/json"
    "?origin=$origin"
    "&destination=$destination"
    "&alternatives=true"
    "&departure_time=$departureTimestamp"
    "&traffic_model=best_guess"
    "&key=$apiKey"
  );
print('url in bar chart is $url');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      List<List<double>> routes = [];
      for (var route in data['routes']) {
        List<double> legTimes = [];
        for (var leg in route['legs']) {
          final durationInTraffic = leg['duration_in_traffic']['value']; // seconds
          legTimes.add(durationInTraffic / 60.0);
        }
        routes.add(legTimes);
      }
      return routes;
    } else {
      print("Error fetching travel time: ${data['status']}");
      return null;
    }
  } else {
    print("HTTP Error: ${response.statusCode}");
    return null;
  }
}

/// Analyzes traffic given travel times and a baseline time.
/// Returns a structure similar to the Python code:
/// A list of routes, each route is a list of maps with details.
List<List<Map<String, dynamic>>> analyzeTraffic(List<List<List<double>>> travelTimes, double baselineTime) {
  List<List<Map<String, dynamic>>> results = [];

  for (var routeTimes in travelTimes) {
    // routeTimes: [ [slot1Times], [slot2Times], ..., [slot6Times] ]
    // each slotTimes is List<double> representing legs times at that slot
    List<Map<String, dynamic>> routeResults = [];

    for (var slotTimes in routeTimes) {
      // sum leg times for this slot if multiple legs
      double totalTime = slotTimes.reduce((a, b) => a + b);
      double totalExtraTime = totalTime - baselineTime;
      double congestionThreshold = baselineTime * 0.20;
      double timeInCongestion = (totalExtraTime - congestionThreshold) > 0 ? (totalExtraTime - congestionThreshold) : 0;
      double timeInSlowMove = (totalExtraTime > 0 ? totalExtraTime : 0) - timeInCongestion;

      String trafficCategory = "No congestion";
      if (timeInCongestion > 0) {
        if (timeInCongestion >= 5) {
          trafficCategory = "${timeInCongestion.toStringAsFixed(2)} min heavy congestion";
        } else if (timeInCongestion >= 2) {
          trafficCategory = "${timeInCongestion.toStringAsFixed(2)} min medium traffic";
        } else {
          trafficCategory = "${timeInCongestion.toStringAsFixed(2)} min light congestion";
        }
      }

      routeResults.add({
        "time": totalTime,
        "extra_time": totalExtraTime,
        "congestion": timeInCongestion,
        "slow_move": timeInSlowMove,
        "category": trafficCategory
      });
    }
    results.add(routeResults);
  }

  return results;
}