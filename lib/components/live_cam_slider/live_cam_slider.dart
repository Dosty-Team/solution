import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import "../../data/cam_data/live_cam_data.dart";
import "package:cached_network_image/cached_network_image.dart";

class LiveCam extends StatefulWidget {
  final String camId;

  const LiveCam({super.key, required this.camId});
  @override
  _LiveCamState createState() => _LiveCamState();
}

class _LiveCamState extends State<LiveCam> {
  int _current = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  Color activeDotColor = Colors.white; // Active dot color
  Color inactiveDotColor = Colors.white70; // Active dot color
  double dotSize = 8.0; // Dot size
  double dotVerticalPosition = 110.0;


 @override
  void initState() {
    super.initState();

    // Set the initial page of carousel according to the selected camera ID
    setState(() {
      _current = _getCamNum(widget.camId);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              initialPage: _current,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }
            ),
            // ****************************** Using Live Cam Data from File ****************************** 
            items: camData.map((item) => Container(
              child: CachedNetworkImage(
                imageUrl: item['image']!,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            )).toList(),
            
          ),
          Positioned(
            bottom: dotVerticalPosition, // Adjusted for visibility of indicators
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: camData.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _carouselController.animateToPage(entry.key),
                  child: Container(
                    width: _current == entry.key ? dotSize : dotSize * 0.8,
                    height: _current == entry.key ? dotSize : dotSize * 0.8,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key ? activeDotColor : inactiveDotColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // Existing white container with title, traffic, weather
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 50,
                    offset: Offset(0, -5), // changes position of shadow
                  ),
                ],
              ),
              
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(camData[_current]['title']!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: mediumText)),
                        SizedBox(height: 6.0),
                        RichText(
                          text: TextSpan(
                            text: 'Traffic: ',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: smallerText),
                            children: <TextSpan>[
                              TextSpan(text: camData[_current]['traffic']!, style: TextStyle(color: _getTrafficColor(camData[_current]['traffic'] as String))),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Text('Weather: ${camData[_current]['weather']}', style: TextStyle(color: Colors.grey.shade700, fontSize: smallerText)),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset("assets/icons/big-cam.png", width: iconWidth),
                      Text(camData[_current]['cam']!, style: TextStyle(color: Colors.grey.shade700, fontSize: smallerText)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// *************** Get test color based upon the traffic value ***************
Color _getTrafficColor(String trafficLevel) {
  switch (trafficLevel.toLowerCase()) {
    case 'low':
      return Colors.green;
    case 'medium':
      return Colors.yellow.shade800;
    case 'high':
      return Colors.red;
    default:
      return Colors.grey; // Default color for unknown traffic level
  }
}

// ****************** Extract the last number from camera id ***********************
int _getCamNum(String input) {
  RegExp regex = RegExp(r'(\d+)$'); // Matches the last number in the string
  Match? match = regex.firstMatch(input);

  if (match != null) {
    int result = int.parse(match.group(1)!);
    if(result <= camData.length) {
      return result;
    }
    else {
      return 0;
    }
  } 
  else {
    return 0; // Or handle the case where no number is found
  }
}