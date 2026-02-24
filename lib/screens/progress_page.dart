import 'package:flutter/material.dart';
import 'package:my_app/services/task_service.dart';

// This is the "Public" part of the widget
class ProgressPage extends StatefulWidget {
  @override
  _ProgressPage createState() => _ProgressPage(); // Fixed: must be 'createState'
}

// This is the "Private" part where the logic lives
class _ProgressPage extends State<ProgressPage> { // Fixed: must extend State<HomePage>

  final TextEditingController _textController = TextEditingController();
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }


  // void _showAddTrackDialog() {
  // showDialog(
  //   context: context,
  //   builder: (context) {
  //     return AlertDialog(
  //       title: Text("Add New Track"),
  //       content: TextField(
  //         controller: _textController, // Connect the bridge
  //         decoration: InputDecoration(hintText: "Exercise Name"),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context), // Close without saving
  //           child: Text("Cancel"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             // 1. Grab the text from the controller
  //             String userInput = _textController.text;

  //             if (userInput.isNotEmpty) {
  //               // 2. Call your logic to save it (using the service we discussed)
  //                 addTask(userInput); 
                
  //               // 3. Clear the box for next time
  //                 _textController.clear(); 
                
  //               // 4. Close the popup
  //                 Navigator.pop(context); 
  //               }
  //             },
  //             child: Text("Save"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Progress")),
      body: ListView(
        padding: EdgeInsets.all(18),
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2)
            ),
            child: Column(
              children: [
                _buildRow("Exercise", isHeader: true),
                _buildRow("Cleaning")
              ],
            ),
          )
        ],
      )
    );
  }

  Widget _buildRow(String title, {bool isHeader = false, bool hasBottomBorder = true}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: hasBottomBorder
           ? Border(bottom: BorderSide(color: Colors.grey, width: 1))
           : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
}