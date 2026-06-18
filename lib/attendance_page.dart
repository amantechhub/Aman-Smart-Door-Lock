import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  final List<String> attendanceList;

  const AttendancePage({
    super.key,
    required this.attendanceList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance List"),
      ),
      body: ListView.builder(
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(attendanceList[index]),
          );
        },
      ),
    );
  }
}