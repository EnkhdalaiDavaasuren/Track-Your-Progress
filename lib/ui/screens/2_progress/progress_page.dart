import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTrackCard("Exercise (In process)", context),
          _buildTrackCard("Gym (Not Set)", context),
          const Spacer(),
          const Text("You may add up to 10 tracks", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTrackCard(String title, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              const Icon(Icons.edit_outlined, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {}, // Navigate to detail page later
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
              child: const Text("View", style: TextStyle(color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}