import 'package:flutter/material.dart';
import '../tracker/tracker.dart';
import '../../services/auth_service.dart';

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
                ),
                const SizedBox(height: 30),
                _logout(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logout(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff0D6EFD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
        ),
        onPressed: () async {
          await AuthService().signout(context: context);
        },
        child: const Text(
          "Sign Out",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
