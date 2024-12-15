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
  List<_RouteChartData> _routeChartsData = [];
  int _interval = 10; 
  bool _isGenerating = false;

  bool get isChartDataValid => _routeChartsData.isNotEmpty && _routeChartsData.any((r) => r.times.isNotEmpty);

  String origin = "27.7148996,85.29039569999999";
  String destination = "27.6915196,85.3420486";

  Future<void> _generateChartFromAPI() async {
    log('Start generating chart from API...');
    final baselineTime = DateTime.now().toUtc().add(Duration(days: 1, hours: 3 - DateTime.now().hour));
    log('Baseline time: $baselineTime');

    final baselineTravelTimes = await fetchTravelTime(origin, destination, baselineTime);
    if (baselineTravelTimes == null || baselineTravelTimes.isEmpty) {
      _showError("Could not retrieve baseline travel time.");
      return;
    }

    final baselineTravelTime = baselineTravelTimes[0][0];
    log('Baseline travel time (minutes): $baselineTravelTime');

    final initialTime = DateTime.now().toUtc().add(
      Duration(
        days: (DateTime.now().hour >= 10 && DateTime.now().minute >= 5) ? 1 : 0,
        hours: 10 - DateTime.now().hour,
        minutes: 5 - DateTime.now().minute,
      ),
    );
    log('Initial time (UTC): $initialTime');

    final timesToCheck = List.generate(6, (i) => initialTime.add(Duration(minutes: i * _interval)));
    log('Times to check: $timesToCheck');

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

    final routeCount = allTravelTimes[0]?.length ?? 0;
    log('Number of routes found: $routeCount');

    if (routeCount == 0) {
      log('No routes were returned by the API.');
      _showError("No routes found.");
      return;
    }

    List<List<List<double>>> routeWiseData = [];
    for (int r = 0; r < routeCount; r++) {
      List<List<double>> routeOverTime = [];
      for (var slot in allTravelTimes) {
        routeOverTime.add(slot![r]);
      }
      log('Route ${r+1} data over time: $routeOverTime');
      routeWiseData.add(routeOverTime);
    }

    final routeTrafficAnalysis = analyzeTraffic(routeWiseData, baselineTravelTime);

    List<_RouteChartData> routeCharts = [];
    for (int routeIndex = 1; routeIndex < routeTrafficAnalysis.length; routeIndex++) {
      final routeData = routeTrafficAnalysis[routeIndex];
      log('Route ${routeIndex+1} analysis data: $routeData');

      if (routeData.isEmpty) {
        log('Route ${routeIndex+1} has no data.');
        continue;
      }

      List<String> chartTimes = [];
      List<double> chartHeights = [];
      List<String> chartCategories = [];

      for (int i = 0; i < routeData.length; i++) {
        final analysis = routeData[i];
        double extraTime = analysis['extra_time'];
        String category = analysis['category'];

        log('Time slot $i: extra_time=$extraTime, category=$category');

        double height = extraTime;
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
    log('Building UI. isChartDataValid: $isChartDataValid');

    return Scaffold(
      // No longer centering the entire page; let the parent handle its own layout.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        log('Back button pressed.');
                        // Navigator.pop(context); // Uncomment if needed
                      },
                    ),
                    const Text(
                      'Commute Analysis',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 48),
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

                    origin = '${coordinates[1][0]},${coordinates[1][1]}';
                    destination = '${coordinates[0][0]},${coordinates[0][1]}';
                    print('in commute analysis page.dart Using coordinates from database: origin: $origin, destination: $destination');

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
                      : const Text('Generate Charts'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _routeChartsData.isEmpty
                      ? const Center(
                          child: Text(
                            'Click Generate Charts for real time predictions',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: _routeChartsData.map((routeData) {
                              log('Rendering chart for ${routeData.routeName} with ${routeData.times.length} bars');
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteChartData {
  final String routeName;
  final List<String> times; 
  final List<double> heights; 
  final List<String> categories; 

  _RouteChartData({
    required this.routeName,
    required this.times,
    required this.heights,
    required this.categories,
  });
}
