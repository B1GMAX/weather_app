import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  final String description;
  final double wind;
  final String city;

  const SecondScreen(
      {required this.description, required this.wind, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(city),
            Text(wind.toString()),
            Text(description),
          ],
        ),
      ),
    );
  }
}
