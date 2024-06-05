import 'package:flutter/material.dart';
import 'package:gluttex_play/components/game.dart';

class GamePlayScreen extends StatelessWidget {
  final Game game;

  const GamePlayScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playing ${game.name}'),
      ),
      body: Center(
        child:
            Text('Now playing: ${game.name}', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
