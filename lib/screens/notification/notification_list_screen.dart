import 'package:flutter/material.dart';

class NotificationListScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'title': 'Test Notification 1',
      'message': 'This is a test notification 1'
    },
    {
      'title': 'Test Notification 2',
      'message': 'This is a test notification 2'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications, color: Colors.blue),
            title: Text(notifications[index]['title']!),
            subtitle: Text(notifications[index]['message']!),
            onTap: () {},
          );
        },
      ),
    );
  }
}
