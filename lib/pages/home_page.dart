import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app13/components/custom_icon_button.dart';
import 'package:weather_app13/constants/api_const.dart';
import 'package:weather_app13/constants/app_text.dart';
import 'package:weather_app13/models/weather_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<Position> weatherLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<WeatherModel?> fetchData() async {
    final dio = Dio();
    final response = await dio.get(ApiConst.api);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final weatherModel = WeatherModel(
        id: response.data['weather'][0]['id'],
        main: response.data['weather'][0]['main'],
        description: response.data['weather'][0]['description'],
        icon: response.data['weather'][0]['icon'],
        temp: response.data['main']['temp'],
        country: response.data['sys']['country'],
        city: response.data['name'],
      );
      //setState(() {});
      return weatherModel;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          AppText.appBarText,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.none) {
              return const Center(
                child: Text('Internet bailanyshynda uzgultuk bar'),
              );
              //connectionState -danniydyn abaly
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/img.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomIconsButton(
                              onPressed: () async {
                                weatherLocation();
                              },
                              icon: Icons.near_me),
                          const CustomIconsButton(icon: Icons.location_city),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            Text(
                              '${temp(snapshot.data!.temp!)}',
                              // kachan gana ishenimduu kelet deser ilep belgi koulat pagoda misaly
                              style: const TextStyle(
                                fontSize: 36,
                                color: Color(0xff000000),
                              ),
                            ),
                            Image.network(
                                ApiConst.getIcon(snapshot.data!.icon, 4)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              snapshot.data!.description.replaceAll(' ', '\n'),
                              style: const TextStyle(
                                fontSize: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Text(
                              snapshot.data!.city,
                              style: const TextStyle(
                                fontSize: 42,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            } else {
              return const Center(child: Text('Belgisiz kata bar...'));
            }
          }),
    );
  }

  int temp(double temp) {
    return (temp - 273.15).toInt();
  }
  //butun bolugun 4ygaryp beret bul logika
}
