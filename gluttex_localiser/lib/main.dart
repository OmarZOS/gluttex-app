import 'package:flutter/material.dart';
import 'package:gluttex_localiser/map_locations_screen.dart';
import 'package:gluttex_localiser/swiper_widget.dart';
import 'package:locator/locator.dart';

void setupLocator() {
  // Register your services or dependencies here
  // For example:
  // locator.registerSingleton<ApiService>(ApiService());
}

void main() {
  setupLocator(); // Initialize the service locator
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'GeoJSON Map', home: SwipeFloatingWidget());
  }
}
