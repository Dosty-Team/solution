import 'package:flowmi/components/top_bar/top_bar.dart';
import 'package:flowmi/my_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late mongo.DbCollection tasksCollection;
  
  List<Task> tasks = [
   
   
     
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _connectToMongo();
  }

  Future<void> _connectToMongo() async {
    setState(() {
      _isLoading = true;
    });
    final db = await mongo.Db.create(
        'mongodb+srv://giver_kdk:giverdb123@cluster0.lfo9ghw.mongodb.net/flowmi_db?retryWrites=true&w=majority&appName=Cluster0'); 
    await db.open();
    tasksCollection = db.collection('tasks');
    await _fetchTasks();
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
      'startTime': task.startTime,
      'endTime': task.endTime,
      'priority': task.priority,
    };
  }

  bool _isLoading = false;

  Future<void> _fetchTasks() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final tasksFromDb = await tasksCollection.find().toList();
      print("FETCH**********");
      setState(() {
        tasks = tasksFromDb.map((map) => fromMap(map)).toList();
        print(tasks[0].taskName);
        _isLoading = false;
      });
    } on Exception catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: TopBar(title: 'Routine'),
      ),
      body: Container(
        color: const Color(0xFFF2F5FF),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              buildBottomafternav(),
              buildScheduleIndicator(context),
              buildHeading(),
              // Use Expanded to let the task list fill available space
              Expanded(
                child: buildTaskList(),
              ),
              // Add Task button container at the bottom
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, -5), 
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50), 
                      ),
                    ),
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: const Text(
                          '+ Add Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: smallText
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomafternav() {
    return const SizedBox(
      height: 35,
    );
  }

  Widget buildScheduleIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
      child: SizedBox(
        height: 70,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white, 
            border: Border.all(
              color: Colors.blue, 
              width: 2, 
            ),
            borderRadius: const BorderRadius.all(Radius.circular(50)), 
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), 
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, 
            children: <Widget>[
              SvgPicture.asset(
                'assets/schedule/average-indicator-home-icon.svg',
                height: 48,
                width: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Colors.green, Colors.red],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds);
                  },
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/schedule/average-indicator-destination-icon.svg',
                height: 48,
                width: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeading() {
    return Container(
      decoration: BoxDecoration(
         border: Border(
          bottom: BorderSide(
            color:Colors.grey[300]!,
            width: 1,
          )
         )
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF4569DC), Color(0xFF9C27B0)],
            ).createShader(Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height)),
            child: const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: largerText,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTaskList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: tasks.map((task) {
        return buildTask(task.taskName, formatTimeOfDay(task.startTime));
      }).toList(),
    );
  }

  Widget buildTask(String name, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      height: 88.0,
      width: 349.0,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          'assets/schedule/calendericon.svg',
          height: 38,
          width: 38,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: const Icon(Icons.more_vert),
      ),
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
  final format = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
  final match = format.firstMatch(timeString);

  if (match != null) {
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String period = match.group(3)!.toUpperCase();

    if (period == "PM" && hour != 12) {
      hour += 12;
    }
    if (period == "AM" && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  } else {
    throw FormatException("Invalid time format: $timeString");
  }
}

String formatTimeOfDay(TimeOfDay time) {
  final String hour = time.hourOfPeriod.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  final String period = time.period == DayPeriod.am ? "AM" : "PM";
  return "$hour:$minute $period";
}
