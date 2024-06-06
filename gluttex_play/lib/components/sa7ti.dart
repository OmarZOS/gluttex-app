// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';

class GamesScreen extends StatelessWidget {
  double? img_h = 200;
  double? img_w = 100;
  GamesScreen({super.key});
  // int _currentIndex = 3; // Index for the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Informative games to help your kid learn about\nceliac disease",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 10)
                ],
              ),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10.0, // Space between columns
                  mainAxisSpacing: 10.0, // Space between rows
                ),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/quizscreen1');
                    },
                    child: Material(
                        elevation: 1.0,
                        borderRadius: BorderRadius.circular(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset("assets/images/game1.jpg"),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/snakescreen');
                    },
                    child: Material(
                        elevation: 1.0,
                        borderRadius: BorderRadius.circular(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset("assets/images/game2.jpg"),
                        )),
                  ),
                  Material(
                      elevation: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Stack(
                            children: [
                              Image.asset('assets/images/game3.jpg'),
                              Positioned.fill(
                                child: Opacity(
                                    opacity: 0.6,
                                    child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.black))),
                              ),
                              const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock, color: Colors.white),
                                    Text(
                                      "available\nsoon",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ))),
                  Material(
                      elevation: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200]),
                  Material(
                      elevation: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200]),
                  Material(
                      elevation: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200]),
                  Material(
                      elevation: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200]),
                  Material(
                      elevation: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200]),
                  Material(
                      elevation: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
