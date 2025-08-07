import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_play/components/sa7ti.dart';
import 'package:gluttex_play/components/snake.dart';

class GameSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar:
      //     AppBar(title: Text(AppLocalizations.of(context)!.selectGameMessage)),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              const SizedBox(height: 8), // Top spacing
              _buildGameCard(
                context,
                title: AppLocalizations.of(context)!.snakeTitle,
                imagePath: "assets/images/snake.jpg",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SnakeGame()),
                  );
                },
              ),
              const SizedBox(height: 16), // Spacing between cards
              _buildGameCard(
                context,
                title: AppLocalizations.of(context)!.quizTitle,
                imagePath: "assets/images/quiz.jpg",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GlutenFreeQuiz()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          )),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch horizontally
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9, // Standard widescreen ratio
                child: Image.asset(
                  imagePath,
                  package: "gluttex_play",
                  fit: BoxFit.cover, // Fill space without distortion
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
