import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SecondScreen extends StatelessWidget {
  final String description;
  final double wind;
  final String city;
  final IconData iconWeatherData;

  const SecondScreen({
    required this.description,
    required this.wind,
    required this.city,
    required this.iconWeatherData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(city),
              Text('${AppLocalizations.of(context).speedofwind} $wind'),
              Row(

                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(description),
                  Icon(iconWeatherData),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
