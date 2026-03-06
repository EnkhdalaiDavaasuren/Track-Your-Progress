import 'package:flutter/material.dart';

class DonePage extends StatelessWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDoneCard("Exercise (Completed)"),
          _buildDoneCard("Gym (Incomplete)"),
        ],
      ),
    );
  }

  Widget _buildDoneCard(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(title)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
              child: const Text("Check", style: TextStyle(color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}