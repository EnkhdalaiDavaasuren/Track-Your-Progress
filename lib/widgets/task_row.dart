// lib/widgets/task_row.dart
import 'package:flutter/material.dart';
import '../models/tasks.dart'; // Import your model

class TaskRow extends StatelessWidget {
  final Tasks task;
  final bool isHeader;

  // Constructor takes the DATA needed to build the UI
  TaskRow({required this.task, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Text(
        task.title, // Use the data from the model!
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}