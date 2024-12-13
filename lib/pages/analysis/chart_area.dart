import 'package:flutter/material.dart';

/// A widget that displays the chart area with grid lines, bars, and associated time labels.
///
/// This widget takes:
/// - [times]: A list of time labels corresponding to each bar.
/// - [heights]: A list of bar heights (0-100).
/// - [categories]: A list of categories corresponding to each bar.
/// - [interval]: The interval in minutes for the grid lines.
/// - [isChartDataValid]: A boolean indicating if there's valid chart data to display.
///
/// If data is invalid, a placeholder "No Data" message is shown.
class ChartArea extends StatelessWidget {
  final List<String> times;
  final List<double> heights;
  final List<String> categories;
  final int interval;
  final bool isChartDataValid;

  const ChartArea({
    Key? key,
    required this.times,
    required this.heights,
    required this.categories,
    required this.interval,
    required this.isChartDataValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const chartHeight = 350.0;

    // If data is invalid, display a placeholder.
    if (!isChartDataValid) {
      return Container(
        height: chartHeight,
        color: const Color(0xFFF0F0F0),
        alignment: Alignment.center,
        child: const Text('No Data', style: TextStyle(color: Colors.black54)),
      );
    }

    // Calculate number of grid lines based on a fixed 50-minute scale.
    final numLines = (50 / interval).ceil();

    // Prepare interval labels on the left.
    List<Widget> intervalLabels = [];
    for (int i = 0; i <= numLines; i++) {
      double ratio = (i * interval) / 50.0;
      double linePos = ratio * chartHeight;
      intervalLabels.add(
        Positioned(
          bottom: linePos,
          left: 0,
          child: Text(
            '${i * interval}min',
            style: const TextStyle(color: Colors.black, fontSize: 10),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column for interval labels
            SizedBox(
              width: 40,
              height: chartHeight,
              child: Stack(
                children: intervalLabels,
              ),
            ),
            const SizedBox(width: 10),
            // Right side for chart (lines + bars), then labels below
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chart area with bars and grid lines
                  Stack(
                    children: [
                      Container(
                        height: chartHeight,
                        color: const Color(0xFFFFFFFF),
                      ),
                      // Grid lines
                      ...List.generate(numLines + 1, (i) {
                        double ratio = (i * interval) / 50.0;
                        double linePos = ratio * chartHeight;
                        return Positioned(
                          bottom: linePos,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: const Color.fromARGB(255, 230, 230, 230),
                          ),
                        );
                      }),
                      // Bars at the bottom of the chart
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(heights.length, (index) {
                            double h = heights[index];
                            String category = categories[index];
                            final barColors = getGradientColorsForCategory(category);
                            return Container(
                              width: 24,
                              height: (h / 100) * chartHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: barColors,
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Labels row below the chart area to align with bars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: times.map((time) {
                      return Text(
                        time,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Determine gradient colors for a bar based on traffic category.
  /// For demonstration:
  /// - "No congestion" = Green gradient
  /// - "light" or "medium" = Yellowish gradient
  /// - "heavy" = Red gradient
  List<Color> getGradientColorsForCategory(String category) {
    if (category.contains("heavy")) {
      return [Colors.red, Colors.orangeAccent];
    } else if (category.contains("medium") || category.contains("light")) {
      return [Colors.yellow, Colors.orange];
    } else {
      // No congestion
      return [Colors.green, Colors.lightGreenAccent];
    }
  }
}
