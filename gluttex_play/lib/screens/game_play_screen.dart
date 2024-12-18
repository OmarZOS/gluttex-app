import 'package:flutter/material.dart';
import 'package:gluttex_play/components/game.dart';

class GamePlayScreen extends StatelessWidget {
  final Game game;

  const GamePlayScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playing ${game.name}'),
      ),
      body: Center(
        child: Text('Now playing: ${game.name}',
            style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
