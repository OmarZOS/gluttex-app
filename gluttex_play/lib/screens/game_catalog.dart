import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_play/components/sa7ti.dart';
import 'package:gluttex_play/components/snake.dart';

class GameSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.selectGameMessage)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildGameCard(
              context,
              title: AppLocalizations.of(context)!.snakeTitle,
              imagePath: "assets/images/snake.jpg",
              onTap: () {
                // Navigate to Snake game
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SnakeGame()),
                );
              },
            ),
            _buildGameCard(
              context,
              title: AppLocalizations.of(context)!.quizTitle,
              imagePath: "assets/images/quiz.jpg",
              onTap: () {
                // Navigate to Quiz game
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GlutenFreeQuiz()),
                );
              },
            ),
            _buildGameCard(
              context,
              title: AppLocalizations.of(context)!.comingSoon,
              imagePath: "assets/images/coming_soon.jpeg",
              onTap: () {
                // Disabled
              },
            ),
            // _buildDisabledCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context,
      {required String title, required String imagePath, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5, // Set image opacity to 50%
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imagePath, package: "gluttex_play"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                backgroundColor: Colors.black54, // Background for readability
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade700,
      ),
      child: Center(
        child: Text(
          "Coming Soon",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
