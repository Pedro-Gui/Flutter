import 'package:flutter/material.dart';
import 'package:weather/pages/weather_page.dart';
import 'package:weather/theme/theme.dart';
void main() {
  
  runApp(  const MainApp(), );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: const WeatherPage()
    );
  }
}
