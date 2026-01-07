// -----------------------------------------------------------------------
// Filename: screen_home.dart
// Original Author: Dan Grissom
// Creation Date: 10/31/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the screen for a dummy home screen
//               history screen.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////

// Flutter imports
import 'dart:async';

// Flutter external package imports

import 'package:csc322_starter_app/models/weather_data.dart';
import 'package:csc322_starter_app/providers/weather_provider.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_app_drawer.dart';
import 'package:csc322_starter_app/widgets/navigation/widget_primary_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// App relative file imports

//////////////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the state object.
//////////////////////////////////////////////////////////////////////////
class ScreenWeather extends ConsumerStatefulWidget {
  static const routeName = '/weather';

  @override
  ConsumerState<ScreenWeather> createState() => _ScreenWeatherState();
}

//////////////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////////////
class _ScreenWeatherState extends ConsumerState<ScreenWeather> {
  // The "instance variables" managed in this state
  bool _isInit = true;


  ////////////////////////////////////////////////////////////////
  // Runs the following code once upon initialization
  ////////////////////////////////////////////////////////////////
  @override
  void didChangeDependencies() {
    // If first time running this code, update provider settings
    if (_isInit) {
      _init();
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  void initState() {
    super.initState();
  }


  ////////////////////////////////////////////////////////////////
  // Initializes state variables and resources
  ////////////////////////////////////////////////////////////////
  Future<void> _init() async {}

  //////////////////////////////////////////////////////////////////////////
  // Primary Flutter method overridden which describes the layout and bindings for this widget.
  //////////////////////////////////////////////////////////////////////////
  String getRecommendation(WeatherData data) {
    if (data.temp < 0 || data.temp > 35 || data.windSpeed > 10 || data.rain > 2 || data.condition.toLowerCase().contains('snow')) {
      return 'Not ideal for a run.';
    } else {
      return 'Good conditions for a run!';
    }
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return FontAwesomeIcons.cloudRain;
      case 'snow':
        return FontAwesomeIcons.snowflake;
      case 'thunderstorm':
        return Icons.flash_on;
      default:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      appBar: WidgetPrimaryAppBar(title: Text('Weather Forecast')),
      drawer: WidgetAppDrawer(),
      body: Center(
        child: weatherAsync.when(
          data: (data) {
            if (data == null) return const Text('Unable to fetch weather.');
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(getWeatherIcon(data.condition), size: 80),
                const SizedBox(height: 20),
                Text('${data.temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text('Wind: ${data.windSpeed} m/s'),
                Text('Rain: ${data.rain} mm'),
                const SizedBox(height: 20),
                Text(getRecommendation(data),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }
}


