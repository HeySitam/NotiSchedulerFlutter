import 'package:flutter/material.dart';
import 'package:noti_scheduler/utils/notification_service.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              // Schedule a notification at a specific time
              DateTime selectedTime = DateTime.now().add(Duration(minutes: 2)); // For testing purposes
              NotificationService().scheduleNotification(selectedTime);
            }, child: const Text("NOTIFY")),
            ElevatedButton(onPressed: (){
              // For testing purposes
              NotificationService().cancelNotification(0);
            }, child: const Text("CANCEL")),
          ],
        )
      ),
    );
  }
}
