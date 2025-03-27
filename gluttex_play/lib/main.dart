import 'package:flutter/material.dart';
import 'package:gluttex_play/screens/game_catalog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Games App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameSelectionScreen(),
    );
  }
}
