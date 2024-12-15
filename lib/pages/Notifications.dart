import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Example list of notifications, this should ideally be a list of a custom class or map
  List<Map<String, dynamic>> notifications = [
    {
      'icon': 'assets/danger-alert.svg',
      'title': 'Clear Route Available!',
      'message': 'Save 15 mins with a faster route for your commute...',
      'time': '2m'
    },
    {
      'icon': 'assets/danger-alert.svg',
      'title': 'Major Delay Ahead',
      'message': 'Expect delays of up to 30 minutes...',
      'time': '23m'
    },
    {
      'icon': 'assets/rain-alert.svg',
      'title': 'Rain on Your Route',
      'message': 'Consider shifting your trip 15 minutes ahead...',
      'time': '50m'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications'),
        backgroundColor: Colors.deepPurple, // Customize app bar color
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Dismissible(
            key: ValueKey(item),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification dismissed')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(item['icon'], width: 50, height: 50),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['message'],
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      item['time'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
