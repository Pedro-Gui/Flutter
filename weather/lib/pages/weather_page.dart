import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/models/weather_model.dart';
import 'package:weather/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService(
    '416e2f0e4d8d7cde3c190412a4ba75e4',
  );
  Weather? _weather;
  void _fetchWeather() async {
    final String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String getAnimationPath(String? condition) {
    if (condition == null) return 'lib/assets/sunny.json';

    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'lib/assets/windy.json';
      case 'drizzle':
      case 'shower rain':
        return 'lib/assets/partly shower.json';
      case 'rain':
        return 'lib/assets/rain.json';
      case 'thunderstorm':
        return 'lib/assets/storm.json';
      case 'clear':
        return 'lib/assets/sunny.json';
      default:
        return 'lib/assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Theme.of(context).colorScheme.inversePrimary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    _weather?.cityName.toUpperCase() ?? 'CARREGANDO...',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 250,
                width: 250,
                child: Lottie.asset(
                  getAnimationPath(_weather?.mainCondition),
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              Text(
                '${_weather?.temperature.round().toString()}°C',
                style: GoogleFonts.poppins(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _weather?.mainCondition ?? 'Carregando condição...',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
