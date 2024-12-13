import 'dart:convert';
import 'package:flowmi/components/bottom_navbar/custom_bottom_navbar.dart';
import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class SetTaskPage extends StatefulWidget {
  const SetTaskPage({super.key});

  @override
  State<SetTaskPage> createState() => _SetTaskPageState();
}

class _SetTaskPageState extends State<SetTaskPage> {
  int _currentPageIndex = 0;
  late mongo.DbCollection tasksCollection;
	@override
		void initState() {
		super.initState();
			_connectToMongo();
		_currentPageIndex = pageIndex["setting"] as int;
	}
  List<Task> tasks = [
    Task(
      taskName: '',
      startTime: TimeOfDay.now(),
      endTime: TimeOfDay.now(),
      priority: 'Medium',
    ),
  ];

  void addTask() {
    setState(() {
      tasks.add(
        Task(
          taskName: '',
          startTime: TimeOfDay.now(),
          endTime: TimeOfDay.now(),
          priority: 'Medium',
        ),
      );
    });
  }
  

Future<void> _connectToMongo() async {
    final db = await mongo.Db.create('mongodb+srv://giver_kdk:giverdb123@cluster0.lfo9ghw.mongodb.net/flowmi_db?retryWrites=true&w=majority&appName=Cluster0'); // Replace with your MongoDB URI
    await db.open();
    tasksCollection = db.collection('tasks');
    // await _fetchTasks();
  }

  Task fromMap(Map<String, dynamic> map) {
    return Task(
		taskName: map["taskName"],
		startTime: parseTime(map["startTime"]),
		endTime: parseTime(map["endTime"]),
		priority: map["priority"],
	);
  }
Map<String, dynamic> toMap(Task task) {
    return {
      'taskName': task.taskName,
      'startTime': formatTimeOfDay(task.startTime),
      'endTime': formatTimeOfDay(task.endTime),
      'priority': task.priority,
    };
  }

//   Future<void> _fetchTasks() async {
//     final tasksFromDb = await tasksCollection.find().toList();
// 	print("FETCH**********");
// 	// print(tasksFromDb);
//     setState(() {
// 		tasks = tasksFromDb.map((map) => fromMap(map)).toList();
// 		print(tasks[0].taskName);
//     });
//   }
  Future<void> _createTasks(List<Task> tasksToCreate) async {
    try {
      final List<Map<String, dynamic>> tasksToInsert = tasksToCreate.map((task) => toMap(task)).toList();
      await tasksCollection.insertMany(tasksToInsert);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error inserting tasks: $e')));
    }
  }
    // await tasksCollection.insertOne(newTask.toMap());
    // await _fetchTasks(); // Refresh the list
  

  // ... other functions to handle time selection, priority selection, etc.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopBar(title: 'Set Commute'),
      ),
      backgroundColor: lightBlueBG,
      body: SafeArea(
        child: Column(
          children: [
            // First section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/large-home.png", width: 60),
                  SizedBox(height: 10),
                  Text('Add Tasks that you do at home before heading to destination', 
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: smallerText,
                    fontWeight: FontWeight.w400, // Add bold weight
                    color: lightGrayText
                  ),
                  ),
                ],
              ),
            ),

            // Second section: Gray box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: lightGrayBG,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, -3), // Adjust the offset to control the shadow's position
                    ),
                  ],
                ),
                
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Task forms
                        ...tasks.map((task) => _buildTaskForm(task)).toList(),
                      

                      // Add New Button
                      Align(
                        alignment: Alignment.centerLeft, // Aligns the child to the top left corner
                        child: Container(
                          width: 80,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, // Removes default padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                              ),
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              
                              side: BorderSide.none
                            ),
                            // ************************ Add New Button Event Handler ************************
                            onPressed: addTask,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [purpleTheme, blueTheme],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
                                alignment: Alignment.center,
                                child: const Text(
                                  '+ New',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                        // Bottom buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // First button with gray color
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // primary: Colors.grey[300], // Gray background
                                    backgroundColor: lightPurpleBG,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20), // Rounded corners
                                    ),
                                  ),
                                  // ************************ Skip Button Event Handler ************************ 
                                  onPressed: () {
                                    GoRouter.of(context).push("/${pageIndex["map"]}");
                                  },
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            // Second button with gradient color
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero, // Removes default padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20), // Rounded corners
                                    ),
                                  ),
                                  // ************************ Next Button Event Handler ************************
                                  onPressed: () {
                                    print("************************ TASK INFO ************************");
                                    print(tasks[0].taskName);
                                    print(tasks[0].startTime);
                                    print(tasks[0].endTime);
                                    print(tasks[0].priority);
									_createTasks(tasks);
                                    GoRouter.of(context).push("/${pageIndex["map"]}");
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [purpleTheme, blueTheme],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Next',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 13
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(initialIndex: _currentPageIndex),
    );
  }

  Widget _buildTaskForm(Task task) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.only(left: 16, right: 16, top:5, bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: purpleBorder, // Border color
        width: 1.0, // Border width
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Name
        TextField(
          onChanged: (value) {
            setState(() {
              task.taskName = value;
            });
          },
          style: TextStyle(fontSize: smallerText),
          decoration: InputDecoration(
            labelText: 'Task Name',
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue), // Adjust color as needed
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey), // Adjust color as needed
            ),
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            // Start Time
            Column(
              children: [
                Text('Start Time', 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: smallText,
                    fontWeight: FontWeight.w400, // Add bold weight
                    color: lightGrayText
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: task.startTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          task.startTime = pickedTime;
                        });
                      }
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Set the background color to white
                    elevation: 0, // Remove the shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    task.startTime.format(context),
                    style: TextStyle(
                      fontSize: mediumText - 2,
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.black, // Set the text color to black
                    ),
                  ),
                )
              ],
            ),
            Spacer(),
            // End Time
            Column(
              children: [
                Text('End Time', 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: smallText,
                    fontWeight: FontWeight.w400, // Add bold weight
                    color: lightGrayText
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: task.endTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          task.endTime = pickedTime;
                        });
                      }
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Set the background color to white
                    elevation: 0, // Remove the shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    task.endTime.format(context),
                    style: TextStyle(
                      fontSize: mediumText - 2,
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.black, // Set the text color to black
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        SizedBox(height: 10,),
        // Priority
        Row(
          children: [
            Text('Priority'),
          ],
        ),
        SizedBox(height: 3,),
        Row(
          children: [
            _buildPriorityChip('High', 'High', task),
            Spacer(),
            _buildPriorityChip('Medium', 'Medium', task),
            Spacer(),
            _buildPriorityChip('Low', 'Low', task),
          ],
        ),
      ],
    ),
  );
}

Widget _buildPriorityChip(String label, String value, Task task) {
  return ChoiceChip(
    label: SizedBox(
      width: 45, // Adjust the width as needed
      child: Text(
        label,
        textAlign: TextAlign.center, // Center the text within the SizedBox
      ),
    ),
    selected: value == task.priority,
    onSelected: (selected) {

      if (selected) {
        setState(() {
          task.priority = value;
        });
      }
    },
    labelStyle: TextStyle(
      color: value == task.priority ? Colors.white : Colors.black,
      fontSize: tinyText,  
    ),    
    // labelPadding: EdgeInsets.symmetric(vertical: 0),
    showCheckmark: false,
    selectedColor: purpleTheme,
    backgroundColor: lightPurpleBG,
    side: BorderSide.none,
  );
}


}

class TimePickerButton extends StatelessWidget {
  final TimeOfDay selectedTime;
  final VoidCallback onPressed;

  const TimePickerButton({
    required this.selectedTime,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(selectedTime.format(context)),
    );
  }
}
class Task {
  String taskName;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String priority;

  Task({
    required this.taskName,
    required this.startTime,
    required this.endTime,
    required this.priority,
  });
}

TimeOfDay parseTime(String timeString) {
  // Parse the string to extract the hour and minute
  final format = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
  final match = format.firstMatch(timeString);

  if (match != null) {
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String period = match.group(3)!.toUpperCase();

    // Convert to 24-hour format if PM
    if (period == "PM" && hour != 12) {
      hour += 12;
    }
    // Adjust for midnight (12:00 AM)
    if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  } else {
    throw FormatException("Invalid time format: $timeString");
  }
}
String formatTimeOfDay(TimeOfDay time) {
  final String hour = time.hourOfPeriod.toString().padLeft(2, '0'); // Ensures 2-digit hour
  final String minute = time.minute.toString().padLeft(2, '0'); // Ensures 2-digit minute
  final String period = time.period == DayPeriod.am ? "AM" : "PM";

  return "$hour:$minute $period";
}