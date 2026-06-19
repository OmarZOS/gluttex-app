import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health/screens/informations_screen.dart';
import 'package:health/screens/serology_screen.dart';
import 'package:health/screens/symptoms_screen.dart';

class CeliacScreen extends StatefulWidget {
  const CeliacScreen({super.key});

  @override
  _CeliacScreenState createState() => _CeliacScreenState();
}

class _CeliacScreenState extends State<CeliacScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: Container(
            color: const Color.fromARGB(255, 131, 103, 66),
            child: const TabBar(
              // indicatorColor: Colors.orangeAccent,
              tabs: [
                Tab(icon: Icon(CupertinoIcons.suit_heart)),
                Tab(icon: Icon(CupertinoIcons.waveform_path_ecg)),
                Tab(icon: Icon(CupertinoIcons.info_circle)),
              ],
              indicatorColor: Colors.orange,
              // overlayColor: Colors.orange,
              labelColor: Colors
                  .orange, // Optional: set the color of the selected tab label
              unselectedLabelColor: Colors
                  .grey, // Optional: set the color of the unselected tab labels
            )),
        body: const TabBarView(
          children: [
            SymptomScreen(),
            SerologyScreen(),
            HealthInfoScreen(),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: CeliacScreen()));
