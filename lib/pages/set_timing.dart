import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class SetTimingPage extends StatefulWidget {
  @override
  _SetTimingPageState createState() => _SetTimingPageState();
}

class _SetTimingPageState extends State<SetTimingPage> {
  int _currentPageIndex = 0;
  late double _currentRangeValues;
  late RangeValues _currentRangeValues2;
  late TimeOfDay _departureTime;
  late TimeOfDay _leaveTime;
  List<bool> _selectedDays = List.generate(7, (_) => false);

  @override
  void initState() {
    super.initState();
    _currentPageIndex = pageIndex["setting"] as int;
    _currentRangeValues = 1;
    _currentRangeValues2 = RangeValues(1, 120);
    _departureTime = TimeOfDay.now();
    _leaveTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(title: 'Set Commute'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Adjust the padding as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconRow(),
              _buildTimingSection(),
              _buildActiveDays(),
              _buildInfoAndNextButton(),
            ],
          ),
        )
      ),
        bottomNavigationBar: CustomBottomNavigationBar(initialIndex: _currentPageIndex),
    );
  }

  Widget _buildIconRow() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: lightPurpleBanner,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset("assets/icons/home.png", height: bigIconSize),
          Image.asset("assets/icons/commute-arrow.png", height: iconWidth),
          Image.asset("assets/icons/destination.png", height: bigIconSize),
        ],
      ),
    );
  }

  Widget _buildTimingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Your Timing", 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: mediumText,
            fontWeight: FontWeight.bold, // Add bold weight
            color: darkerPurpleText
          ),
          ),
        ),
        Column(
          children: [
            Positioned(
              top: -20, // Adjust the top position as needed
              left: 0,
              right: 0,
              child: Center(
                child: Text('${_currentRangeValues.round()} min'),
              ),
            ),
            SliderTheme(
            data: SliderThemeData(
              thumbColor: purpleBorder, // Thumb color
              
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 7, // Thumb size
                
              ),
              trackHeight: 3.5,
              activeTrackColor: purpleBorder,
              inactiveTrackColor: lightGrayBanner,
            ),
            child: Slider(
              value: _currentRangeValues,
              min: 1,
              max: 120,
              divisions: 119,
              onChanged: (double value) {
                setState(() {
                  _currentRangeValues = value;
                });
              },
            ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeColumn("Departure", _departureTime, (newTime) {
              setState(() {
                _departureTime = newTime;
              });
            }),
            Image.asset("assets/icons/small-right-arrow.png", width: 24,),
            _buildTimeColumn("Leave", _leaveTime, (newTime) {
              setState(() {
                _leaveTime = newTime;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeColumn(String title, TimeOfDay time, Function(TimeOfDay) onSelected) {
    return Column(
      children: [
        Text(title, 
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: mediumText - 1,
            fontWeight: FontWeight.w300, // Add bold weight
            color: darkerPurpleText
          ),
        ),
        SizedBox(height: 5),
        ElevatedButton(
          onPressed: () async {
            TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null && picked != time) {
              onSelected(picked);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0, // Remove shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Customize border radius
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Ensure the row takes minimum space
            children: [
              Text(
                '${time.format(context)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: smallerText,
                  fontWeight: FontWeight.w500,
                  color: darkerPurpleText,
                ),
              ),
              SizedBox(width: 5,),
              const Icon(Icons.access_time, size: 20,color: darkPurpleText,), // Clock icon
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDays() {
    List<String> dayLabels = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text("Active Days",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: mediumText,
            fontWeight: FontWeight.bold, // Add bold weight
            color: darkerPurpleText
          ),
          ),
          SizedBox(height: 5),
          Wrap(
            spacing: -10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List<Widget>.generate(7, (index) {
              return ChoiceChip(
                label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child:Text(dayLabels[index], 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    
                      fontSize: tinyText,
                      fontWeight: FontWeight.w500, // Add bold weight
                      color: darkerPurpleText,
                    ),
                  ),
                ),
                selected: _selectedDays[index],
                onSelected: (bool selected) {
                  setState(() {
                    _selectedDays[index] = selected;
                  });
                },
                showCheckmark: false,
                selectedColor: checkMarkPurpleBG,
                backgroundColor: lightBlueBG,
                shape: CircleBorder(),
                side: BorderSide.none,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoAndNextButton() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "The above timing should be set with respect to normal average traffic.",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: smallerText,
              fontWeight: FontWeight.w400, // Add bold weight
              color: lightGrayText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Column(
            children: [
              Container(
              height: 50, // Desired height
              child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Removes default padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50), // Rounded corners
                      ),
                    ),
                    // ************************ Next Button Event Handler ************************
                    onPressed: () {
                      GoRouter.of(context).push("/set_task");
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [purpleTheme, blueTheme],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Container(
                        // padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: mediumText
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ]),
      ],
    );
  }

  void _submitData() {
    // Handle the submission of all data
    // This might involve navigating to another page or sending data to a server
    Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage(data: {
      'range': _currentRangeValues,
      'departureTime': _departureTime,
      'leaveTime': _leaveTime,
      'activeDays': _selectedDays,
    })));
  }
}

class NextPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const NextPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Review Timing")),
      body: Center(
        child: Text("Data received."),
      ),
    );
  }
}
