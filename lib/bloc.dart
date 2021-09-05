import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/information.dart';
import 'package:weather_app/location.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Bloc {
  StreamController<List<Information>> _controller =
      StreamController<List<Information>>();
  StreamController<Location> _controllerPosition = StreamController<Location>();
  StreamController<String> _controllerString = StreamController<String>();
  StreamController<bool> _controllerToggle = StreamController<bool>();

  Stream<List<Information>> get stream => _controller.stream;

  Stream<bool> get toggleStream => _controllerToggle.stream;

  Stream<String> get streamString => _controllerString.stream;

  Stream<Location> get streamPosition => _controllerPosition.stream;

  final List<Information> _information = [];
  final List<Information> _informationDaily = [];
  bool _toggleHourly = true;

  void loadData(String url) async {
    String responseBody;
    bool error = false;
    Response? response;
    try {
      response = await get(Uri.parse(url));
    } catch (e) {
      error = true;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!error && response!.statusCode == 200) {
      responseBody = response.body;
      prefs.setString('response', response.body);
    } else {
      if (prefs.containsKey('response')) {
        return;
      }
      responseBody = prefs.getString('response') ?? '';
    }
    Map<String, dynamic> json = jsonDecode(responseBody);
    List<dynamic> list = json['list'];
    Map<String, dynamic> cities = json['city'];
    String city = cities['name'];
    for (int i = 0; i < list.length; i++) {
      Map<String, dynamic> element = list[i];
      Map<String, dynamic> main = element['main'];
      double temp = main['temp'].toDouble();
      List<dynamic> w = element['weather'];
      String weather = w.first['main'];
      String description = w.first['description'];
      String iconWeather = w.first['icon'];
      Map<String, dynamic> wind = element['wind'];
      double speedOfWind = wind['speed'].toDouble();
      String dtTxt = element['dt_txt'];
      _information.add(Information(
          temp: temp,
          description: description,
          speedOfWind: speedOfWind,
          dtTxt: dtTxt,
          city: city,
          weather: weather,
          iconWeather: iconWeather));
      if (dtTxt.contains('12:00:00')) {
        _informationDaily.add(Information(
            temp: temp,
            description: description,
            speedOfWind: speedOfWind,
            dtTxt: dtTxt.replaceAll(('12:00:00'), ''),
            city: city,
            weather: weather,
            iconWeather: iconWeather));
      }
    }
    _controller.add(_information);
    _controllerString.add(city);
  }

  void changeData() {
    if (_toggleHourly) {
      _controller.add(_informationDaily);
    } else {
      _controller.add(_information);
    }
    _toggleHourly = !_toggleHourly;
    _controllerToggle.add(_toggleHourly);
  }

  void getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    Location location = Location();
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    String myLocale = Platform.localeName.split('_').first;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || !serviceEnabled) {
      loadData(
          'https://api.openweathermap.org/data/2.5/forecast?q=Kiev&appid=a5c5ebc2548f9619db98a62ec0c65cbb&units=metric&lang=$myLocale');
    } else {
      await location.getCurrentLocation();
      loadData(
          'https://api.openweathermap.org/data/2.5/forecast?lat=${location.latitude}&lon=${location.longitude}&appid=a5c5ebc2548f9619db98a62ec0c65cbb&units=metric&lang=$myLocale');
      _controllerPosition.add(location);
    }
  }

  void dispose() {
    _controller.close();
    _controllerPosition.close();
    _controllerString.close();
    _controllerToggle.close();
  }
}
