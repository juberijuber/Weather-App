import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/AdditionalInfo.dart';
import 'package:weather_app/HourlyForecastItems.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/openweatherkey.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController =
      TextEditingController(text: 'Erode'); // Controller for the city name
  String _cityName = 'Erode'; // Default city
  String n = "";

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "City not found"; // Handle error if city is not found
      }
      return data;
    } catch (e) {
      throw e.toString(); // Forward the error to handle it in UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {}); // Refresh the screen
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      // This ensures the screen resizes when the keyboard appears
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        // Allows scrolling if content overflows
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TextField for city input
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter City Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _cityName = value; // Update city name on submission
                  });
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder(
                future: getCurrentWeather(
                    _cityName), // Pass the updated city name to the API
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                        "Error: ${snapshot.error}"); // Show error message
                  }

                  final data = snapshot.data!;
                  final temp = (data['list'][0]['main']['temp']) - 273.15;
                  final currentSky = data['list'][0]['weather'][0]['main'];
                  final currentPressure = data['list'][0]['main']['pressure'];
                  final currentWindSpeed = data['list'][0]['wind']['speed'];
                  final currentHumidity = data['list'][0]['main']['humidity'];
                  n = temp.toStringAsFixed(2);

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main card showing temperature and weather info
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        '$n °C',
                                        style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      Icon(
                                        currentSky == 'Clouds' ||
                                                currentSky == 'Rain' ||
                                                currentSky == 'Snow'
                                            ? Icons.cloud
                                            : Icons.sunny,
                                        size: 60,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "$currentSky",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Hourly Forecast",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              final hourlyForecast = data['list'][index + 1];
                              final hourlyforecasttemp =
                                  hourlyForecast['main']['temp'].toString();
                              final time = DateTime.parse(
                                  hourlyForecast['dt_txt'].toString());
                              return HourlyForecastItems(
                                temp: hourlyforecasttemp,
                                time: DateFormat.Hm().format(time),
                                icon: hourlyForecast['weather'][0]
                                                ['main'] ==
                                            'Clouds' ||
                                        hourlyForecast['weather'][0]['main'] ==
                                            'Rain' ||
                                        hourlyForecast['weather'][0]['main'] ==
                                            'Snow'
                                    ? Icons.cloud
                                    : Icons.sunny,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Additional Information",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalInfo(
                              icon: Icons.water_drop,
                              label: "Humidity",
                              value: currentHumidity.toString(),
                            ),
                            AdditionalInfo(
                                icon: Icons.air,
                                label: "Wind Speed",
                                value: currentWindSpeed.toString()),
                            AdditionalInfo(
                              icon: Icons.beach_access,
                              label: "Pressure",
                              value: currentPressure.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
