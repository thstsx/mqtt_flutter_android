import 'package:flutter/material.dart';

// // HOME PAGE
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Home (Flutter)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/publisher');
              },
              child: const Text('Go to Publisher'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/subscriber');
              },
              child: const Text('Go to Subscriber'),
            ),
          ],
        ),
      ),
    );
  }
}
