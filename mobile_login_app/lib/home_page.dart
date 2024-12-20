import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String userDisplayName;
  final String userEmail;

  const HomePage({super.key, required this.userDisplayName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $userDisplayName!", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text("Email: $userEmail", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
