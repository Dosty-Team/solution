import 'dart:developer';
import 'package:flowmi/pages/analysis/chart_area.dart';
import 'package:flowmi/pages/analysis/trafficservice.dart';
import 'package:flowmi/pages/set_commute_database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../set_commute_source_and_destination.dart';

class CommuteAnalysisPage extends StatefulWidget {
  const CommuteAnalysisPage({super.key});

  @override
  _CommuteAnalysisPageState createState() => _CommuteAnalysisPageState();
}

class _CommuteAnalysisPageState extends State<CommuteAnalysisPage> {
  // Data for multiple routes
  List<_RouteChartData> _routeChartsData = [];
  int _interval = 10; // Interval between measurements in minutes
  bool _isGenerating = false;

  bool get isChartDataValid => _routeChartsData.isNotEmpty && _routeChartsData.any((r) => r.times.isNotEmpty);

  // String origin = "${SourceAndDestinationCoordinates().sourceLat},${SourceAndDestinationCoordinates().sourceLong}";
  // String destination = "${SourceAndDestinationCoordinates().destLat},${SourceAndDestinationCoordinates().destLong}";

String origin = "27.7148996,85.29039569999999";
  String destination = "27.6915196,85.3420486";
    Future<void> _generateChartFromAPI() async {
    log('Start generating chart from API...');

    // Set a baseline time in the future
    final baselineTime = DateTime.now().toUtc().add(Duration(days: 1, hours: 3 - DateTime.now().hour));
    log('Baseline time: $baselineTime');

    // Fetch baseline travel time
    final baselineTravelTimes = await fetchTravelTime(origin, destination, baselineTime);
    if (baselineTravelTimes == null || baselineTravelTimes.isEmpty) {
      _showError("Could not retrieve baseline travel time.");
      return;
    }

    final baselineTravelTime = baselineTravelTimes[0][0];
    log('Baseline travel time (minutes): $baselineTravelTime');

    // Generate 6 time slots spaced by _interval minutes
    final initialTime = DateTime.now().toUtc().add(const Duration(minutes: 5));
    log('Initial time (UTC): $initialTime');

    final timesToCheck = List.generate(6, (i) => initialTime.add(Duration(minutes: i * _interval)));
    log('Times to check: $timesToCheck');

    // Fetch travel times for each of the 6 times
    List<List<List<double>>?> allTravelTimes = [];
    for (var t in timesToCheck) {
      log('Fetching travel times for $t');
      var tt = await fetchTravelTime(origin, destination, t);
      if (tt == null) {
        log('Failed to fetch travel times for $t');
        _showError("Could not retrieve travel times for all time slots.");
        return;
      }
      log('Fetched travel times for $t: $tt');
      allTravelTimes.add(tt);
    }

    // Determine how many routes we have
    final routeCount = allTravelTimes[0]?.length ?? 0;
    log('Number of routes found: $routeCount');

    if (routeCount == 0) {
      log('No routes were returned by the API.');
      _showError("No routes found.");
      return;
    }

    // Group data by route
    List<List<List<double>>> routeWiseData = [];
    for (int r = 0; r < routeCount; r++) {
      List<List<double>> routeOverTime = [];
      for (var slot in allTravelTimes) {
        routeOverTime.add(slot![r]);
      }
      log('Route ${r+1} data over time: $routeOverTime');
      routeWiseData.add(routeOverTime);
    }

    // Analyze traffic for each route
    final routeTrafficAnalysis = analyzeTraffic(routeWiseData, baselineTravelTime);
    // routeTrafficAnalysis should now have 6 entries per route, corresponding to the 6 time slots

    // Build charts data for each route
    List<_RouteChartData> routeCharts = [];
    for (int routeIndex = 0; routeIndex < routeTrafficAnalysis.length; routeIndex++) {
      final routeData = routeTrafficAnalysis[routeIndex];
      log('Route ${routeIndex+1} analysis data: $routeData');

      if (routeData.isEmpty) {
        log('Route ${routeIndex+1} has no data.');
        continue;
      }

      // Ensure we have 6 bars
      if (routeData.length != 6) {
        log('Unexpected data length for route ${routeIndex+1}. Expected 6 entries, got ${routeData.length}.');
      }

      List<String> chartTimes = [];
      List<double> chartHeights = [];
      List<String> chartCategories = [];

      for (int i = 0; i < routeData.length; i++) {
        final analysis = routeData[i];
        double extraTime = analysis['extra_time'];
        String category = analysis['category'];

        // log details for debugging
        log('Time slot $i: extra_time=$extraTime, category=$category');

        double height = extraTime;
        // Clamp height between 0 and 100 for display
        if (height < 0) height = 0; 
        if (height > 100) height = 100;

        DateTime t = timesToCheck[i].toLocal();
        String formattedTime = DateFormat('h:mm a').format(t);
        chartTimes.add(formattedTime);
        chartHeights.add(height);
        chartCategories.add(category);
      }

      log('Route ${routeIndex+1} chart times: $chartTimes');
      log('Route ${routeIndex+1} chart heights: $chartHeights');
      log('Route ${routeIndex+1} chart categories: $chartCategories');

      // Create chart data for this route
      routeCharts.add(_RouteChartData(
        routeName: "Route ${routeIndex + 1}",
        times: chartTimes,
        heights: chartHeights,
        categories: chartCategories,
      ));
    }

    setState(() {
      _routeChartsData = routeCharts;
    });

    log('Completed chart generation. Number of routes in charts: ${_routeChartsData.length}');
  }

  void _showError(String message) {
    log('Showing error: $message');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              log('Error dialog dismissed.');
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = 400.0;

    log('Building UI. isChartDataValid: $isChartDataValid');
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: maxWidth,
            padding: const EdgeInsets.all(7),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          log('Back button pressed.');
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        'Commute Analysis',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isGenerating = true;
                      });

                      final coordinates = await DatabaseService().fetchData();
                      if (coordinates.isEmpty) {
                        log('No coordinates found in the database.');
                        _showError('No coordinates found in the database.');
                        setState(() {
                          _isGenerating = false;
                        });
                        return;
                      }

                      // Extract coordinates from DB results
                      // Suppose structure: [[destLat, destLng, ...],[originLat,originLng,...]]
                      origin = '${coordinates[1][0]},${coordinates[1][1]}';
                      destination = '${coordinates[0][0]},${coordinates[0][1]}';
                      print('in trafficmap.dart Using coordinates from database: origin: $origin, destination: $destination');

                      await _generateChartFromAPI();

                      setState(() {
                        _isGenerating = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: _isGenerating
                        ? const CircularProgressIndicator()
                        : const Text('Generate Charts from API'),
                  ),

                  const SizedBox(height: 20),
                  // Display a chart card for each route
                  if (_routeChartsData.isEmpty)
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const Text('No Data', style: TextStyle(color: Colors.white)),
                    )
                  else
                    Column(
                      children: _routeChartsData.map((routeData) {
                        log('Rendering chart for ${routeData.routeName} with ${routeData.times.length} bars');
                        // Expecting routeData.times.length = 6
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.1),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              // Card Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    routeData.routeName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9c27b0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Optimal',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              // Chart Area for this route
                              ChartArea(
                                times: routeData.times,
                                heights: routeData.heights,
                                categories: routeData.categories,
                                interval: _interval,
                                isChartDataValid: routeData.times.isNotEmpty && routeData.heights.isNotEmpty,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteChartData {
  final String routeName;
  final List<String> times;    // 6 timeslots
  final List<double> heights;  // 6 bars heights
  final List<String> categories; // 6 categories

  _RouteChartData({
    required this.routeName,
    required this.times,
    required this.heights,
    required this.categories,
  });
}
