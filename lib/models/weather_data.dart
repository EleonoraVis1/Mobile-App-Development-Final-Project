class WeatherData {
  final double temp;
  final double windSpeed;
  final double rain;
  final String condition;

  WeatherData({
    required this.temp,
    required this.windSpeed,
    required this.rain,
    required this.condition,
  });

  static WeatherData fromJson(Map<String, dynamic> json) {
    double rainAmount = 0;
    if (json.containsKey('rain') && json['rain']['1h'] != null) {
      rainAmount = (json['rain']['1h'] as num).toDouble();
    }

    return WeatherData(
      temp: (json['main']['temp'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      rain: rainAmount,
      condition: (json['weather'][0]['main'] as String),
    );
  }
}