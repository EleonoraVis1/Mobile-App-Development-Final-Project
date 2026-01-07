import 'package:csc322_starter_app/models/weather_data.dart';
import 'package:csc322_starter_app/services/location_service.dart';
import 'package:csc322_starter_app/services/weather_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weatherProvider = FutureProvider<WeatherData?>((ref) async {
  final locService = LocationService();
  final locData = await locService.getCurrentLocation();

  if (locData == null) return null;

  final weatherService = WeatherService(apiKey: '65b726cc5442537347d5389ec67730bc');
  final data = await weatherService.getCurrentWeather(
      locData.latitude!, locData.longitude!);

  if (data == null) return null;

  return WeatherData.fromJson(data);
});




