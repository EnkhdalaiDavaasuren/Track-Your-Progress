import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.account_circle_outlined, size: 50),
              const SizedBox(width: 10),
              const Text("Username", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          const Text("Progress", style: TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          // Progress Table
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
            child: Column(
              children: List.generate(4, (index) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: index < 3 ? const Border(bottom: BorderSide(color: Colors.black)) : null,
                ),
                child: Text(index == 0 ? "Exercise" : ""),
              )),
            ),
          ),
        ],
      ),
    );
  }
}