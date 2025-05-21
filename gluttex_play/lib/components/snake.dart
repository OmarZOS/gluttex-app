import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int rows = 20; // 网格行数
  static const int cols = 20; // 网格列数
  double cellSize = 0.0; // 动态计算的单元格大小

  List<Offset> snake = [const Offset(10, 10)];
  Offset healthyFood = Offset.zero;
  List<String> healthyFoodAssets = [
    'assets/images/strawberry.svg',
    'assets/images/apple_pie.svg',
    'assets/images/watermelon.svg',
    'assets/images/banana.svg',
    'assets/images/fish.svg',
  ];
  List<String> unhealthyFoodAssets = [
    'assets/images/bread.svg',
    'assets/images/pizza.svg',
    'assets/images/croissant.svg',
    'assets/images/hamburger.svg',
    'assets/images/taco.svg',
    'assets/images/donut.svg',
  ];

  int healthyFoodListLength = 0;
  int unhealthyFoodListLength = 0;

  int healthyFoodIndex = 0;
  int unhealthyFoodIndex = 0;

  Offset unhealthyFood = Offset.zero;
  String direction = 'up';
  bool isGameOver = false;
  bool isPaused = false;
  int score = 0;

  Timer? gameLoop;

  @override
  void initState() {
    super.initState();
    healthyFoodListLength = healthyFoodAssets.length;
    unhealthyFoodListLength = unhealthyFoodAssets.length;
    spawnFood();
    startGame();
  }

  void startGame() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!isGameOver && !isPaused) {
        moveSnake();
      }
    });
  }

  void spawnFood() {
    Random random = Random();

    healthyFoodIndex = random.nextInt(healthyFoodListLength);
    unhealthyFoodIndex = random.nextInt(unhealthyFoodListLength);

    healthyFood = Offset(
      random.nextInt(cols).toDouble(),
      random.nextInt(rows).toDouble(),
    );
    do {
      unhealthyFood = Offset(
        random.nextInt(cols).toDouble(),
        random.nextInt(rows).toDouble(),
      );
    } while (unhealthyFood == healthyFood); // 避免食物重叠
  }

  void moveSnake() {
    setState(() {
      Offset newHead = snake.first;
      switch (direction) {
        case 'up':
          newHead += const Offset(0, -1);
          break;
        case 'down':
          newHead += const Offset(0, 1);
          break;
        case 'left':
          newHead += const Offset(-1, 0);
          break;
        case 'right':
          newHead += const Offset(1, 0);
          break;
      }

      // 处理边界穿越
      if (newHead.dx >= cols) newHead = Offset(0, newHead.dy);
      if (newHead.dx < 0) newHead = Offset(cols - 1, newHead.dy);
      if (newHead.dy >= rows) newHead = Offset(newHead.dx, 0);
      if (newHead.dy < 0) newHead = Offset(newHead.dx, rows - 1);

      // 检查是否撞到自己
      if (snake.contains(newHead)) {
        isGameOver = true;
        gameLoop?.cancel();
        showGameOverDialog();
        return;
      }

      snake.insert(0, newHead);

      // 检查是否吃到食物
      if (newHead == healthyFood) {
        score++;
        spawnFood();
      } else if (newHead == unhealthyFood) {
        isGameOver = true;
        gameLoop?.cancel();
        showGameOverDialog();
        return;
      } else {
        snake.removeLast(); // 如果没有吃到食物，移除尾部
      }
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.gameOver),
        content:
            Text(AppLocalizations.of(context)!.scoreStartOverMessage(score)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: Text(AppLocalizations.of(context)!.restartText),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      snake = [const Offset(10, 10)];
      direction = 'up';
      isGameOver = false;
      score = 0;
      spawnFood();
      startGame();
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        gameLoop?.cancel();
      } else {
        startGame();
      }
    });
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 动态计算单元格大小
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    cellSize = min(screenWidth / cols, screenHeight / rows);
    String? titleText =
        AppLocalizations.of(context)?.currentScore(score) ?? 'Score: $score';
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: togglePause,
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0 && direction != 'up') {
            direction = 'down';
          } else if (details.delta.dy < 0 && direction != 'down') {
            direction = 'up';
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0 && direction != 'left') {
            direction = 'right';
          } else if (details.delta.dx < 0 && direction != 'right') {
            direction = 'left';
          }
        },
        child: Container(
          color: Colors.black,
          child: Center(
            child: SizedBox(
              width: cols * cellSize,
              height: rows * cellSize,
              child: Stack(
                children: [
                  // 蛇
                  for (Offset segment in snake)
                    Positioned(
                      left: segment.dx * cellSize,
                      top: segment.dy * cellSize,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        width: cellSize,
                        height: cellSize,
                      ),
                    ),
                  // 健康食物
                  Positioned(
                    left: healthyFood.dx * cellSize,
                    top: healthyFood.dy * cellSize,
                    child: SvgPicture.asset(
                      healthyFoodAssets[healthyFoodIndex],
                      package: "gluttex_play",
                      height: cellSize,
                      width: cellSize,
                    ),
                  ),
                  // 不健康食物
                  Positioned(
                    left: unhealthyFood.dx * cellSize,
                    top: unhealthyFood.dy * cellSize,
                    child: SvgPicture.asset(
                      unhealthyFoodAssets[unhealthyFoodIndex],
                      package: "gluttex_play",
                      height: cellSize,
                      width: cellSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
