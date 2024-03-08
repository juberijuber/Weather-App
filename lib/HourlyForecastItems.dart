import 'package:flutter/material.dart';

class HourlyForecastItems extends StatelessWidget {
  final String time;
  final String temp;
  final IconData icon;
  const HourlyForecastItems(
      {super.key, required this.temp, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 10,
            ),
            Icon(
              icon,
              size: 30,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              temp,
            ),
          ],
        ),
      ),
    );
  }
}
