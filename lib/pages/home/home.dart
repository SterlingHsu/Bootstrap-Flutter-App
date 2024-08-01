import 'package:flutter/material.dart';
import '../tracker/tracker.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 60.0,
                ),
                const Text(
                  "Supertracker",
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                ElevatedButton(
                  child: const Text("Get tracking"),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TrackerScreen()));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}