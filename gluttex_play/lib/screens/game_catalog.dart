import 'package:flutter/material.dart';
import 'package:gluttex_play/components/game.dart';
import 'package:gluttex_play/components/snake.dart';
import 'package:gluttex_play/screens/game_play_screen.dart';

class GameListScreen extends StatelessWidget {
  final List<Game> games = [
    Game(name: 'Snake', screen: SnakeGame()),
    Game(name: 'Game 2', screen: SnakeGame()),
    Game(name: 'Game 3', screen: SnakeGame()),
    // Add more games as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 3 / 2,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => games[index].screen,
                  ),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    games[index].name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
