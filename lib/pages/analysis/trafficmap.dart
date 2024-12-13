import 'dart:developer';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:/analysis/trafficservice.dart';
import "./trafficservice.dart";
import 'chart_area.dart';

class CommuteAnalysisPage extends StatefulWidget {
  @override
  _CommuteAnalysisPageState createState() => _CommuteAnalysisPageState();
}

class _CommuteAnalysisPageState extends State<CommuteAnalysisPage> {
  List<String> _times = [];
  List<double> _heights = [];
  List<String> _categories = [];
  int _interval = 10; // Interval between measurements in minutes

  bool get isChartDataValid => _times.isNotEmpty && _heights.isNotEmpty && _times.length == _heights.length;

  // Example origin/destination. Replace these with desired coordinates/addresses.
  String origin = "24.85085,67.01778";
  String destination = "24.8657238,67.0142184";

  Future<void> _generateChartFromAPI() async {
    log('Fetching data from API...');

    final baselineTime = DateTime(2024, 12, 14, 3, 0);
    final baselineTravelTimes = await fetchTravelTime(origin, destination, baselineTime);
    if (baselineTravelTimes == null || baselineTravelTimes.isEmpty) {
      _showError("Could not retrieve baseline travel time.");
      return;
    }

    final baselineTravelTime = baselineTravelTimes[0][0]; // first route's first leg

    final initialTime = DateTime.now().toUtc();
    final timesToCheck = List.generate(6, (i) => initialTime.add(Duration(minutes: i * _interval)));

    List<List<List<double>>?> allTravelTimes = [];
    for (var t in timesToCheck) {
      var tt = await fetchTravelTime(origin, destination, t);
      if (tt == null) {
        _showError("Could not retrieve travel times for all time slots.");
        return;
      }
      allTravelTimes.add(tt);
    }

    // We have data structured by time, we need to reorganize by route:
    final routeCount = allTravelTimes[0]?.length ?? 0;
    // Group data by route
    List<List<List<double>>> routeWiseData = [];
    for (int r = 0; r < routeCount; r++) {
      List<List<double>> routeOverTime = [];
      for (var slot in allTravelTimes) {
        routeOverTime.add(slot![r]);
      }
      routeWiseData.add(routeOverTime);
    }

    // Analyze traffic by route
    final routeTrafficAnalysis = analyzeTraffic(routeWiseData, baselineTravelTime);

    // For demonstration, pick the first route:
    final firstRouteData = routeTrafficAnalysis[0];

    // Extract times and extra_time to form chart data
    List<String> chartTimes = [];
    List<double> chartHeights = [];
    List<String> chartCategories = [];

    for (int i = 0; i < firstRouteData.length; i++) {
      final analysis = firstRouteData[i];
      double extraTime = analysis['extra_time'];
      String category = analysis['category'];

      double height = extraTime;
      // Clamp height between 0 and 100 for display
      if (height < 0) height = 0; 
      if (height > 100) height = 100;

      DateTime t = timesToCheck[i].toLocal();
      String formattedTime = DateFormat('HH:mm').format(t);
      chartTimes.add(formattedTime);
      chartHeights.add(height);
      chartCategories.add(category);
    }

    setState(() {
      _times = chartTimes;
      _heights = chartHeights;
      _categories = chartCategories;
    });
  }

  void _showError(String message) {
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(title: 'Commute Analysis'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: lightBlueBG,
        ),
        child: Container(
            width: maxWidth,
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _generateChartFromAPI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Generate Chart from API'),
                  ),

                  const SizedBox(height: 20),
                  // Chart Display Card
                  Container(
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
                            const Text(
                              'Route 1',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
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
                        // Chart Area
                        ChartArea(
                          times: _times,
                          heights: _heights,
                          categories: _categories,
                          interval: _interval,
                          isChartDataValid: isChartDataValid,
                        ),
                      ],
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
