import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int ROWS = 20;
  static const int COLUMNS = 20;
  static const int CELL_SIZE = 20;
  static const int START_LENGTH = 5;
  static const Duration GAME_SPEED = Duration(milliseconds: 300);

  List<Offset> snake = [];
  Offset fruit = const Offset(0, 0);
  Direction direction = Direction.right;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    snake.clear();
    snake.add(const Offset(ROWS / 2, COLUMNS / 2));
    for (int i = 1; i < START_LENGTH; i++) {
      snake.add(Offset(ROWS / 2 - i, COLUMNS / 2));
    }
    spawnFruit();
    isPlaying = true;
    Timer.periodic(GAME_SPEED, (Timer timer) {
      if (!isPlaying) {
        timer.cancel();
      } else {
        moveSnake();
      }
    });
  }

  void moveSnake() {
    setState(() {
      Offset head = snake.first;
      switch (direction) {
        case Direction.up:
          head = Offset(head.dx, head.dy - 1);
          break;
        case Direction.down:
          head = Offset(head.dx, head.dy + 1);
          break;
        case Direction.left:
          head = Offset(head.dx - 1, head.dy);
          break;
        case Direction.right:
          head = Offset(head.dx + 1, head.dy);
          break;
      }
      if (head.dx < 0 ||
          head.dx >= ROWS ||
          head.dy < 0 ||
          head.dy >= COLUMNS ||
          snake.contains(head)) {
        isPlaying = false;
        return;
      }
      snake.insert(0, head);
      if (head == fruit) {
        spawnFruit();
      } else {
        snake.removeLast();
      }
    });
  }

  void spawnFruit() {
    setState(() {
      fruit = Offset(Random().nextInt(ROWS).toDouble(),
          Random().nextInt(COLUMNS).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0 && direction != Direction.up) {
            direction = Direction.down;
          } else if (details.delta.dy < 0 && direction != Direction.down) {
            direction = Direction.up;
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0 && direction != Direction.left) {
            direction = Direction.right;
          } else if (details.delta.dx < 0 && direction != Direction.right) {
            direction = Direction.left;
          }
        },
        child: Container(
          color: Colors.grey[300],
          child: GridView.builder(
            itemCount: ROWS * COLUMNS,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ROWS,
            ),
            itemBuilder: (BuildContext context, int index) {
              int row = index ~/ ROWS;
              int col = index % ROWS;
              Offset cell = Offset(row.toDouble(), col.toDouble());
              if (snake.contains(cell)) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                );
              } else if (fruit == cell) {
                return SvgPicture.asset(
                  'assets/images/apple_pie.svg',
                  // height: 100.0,
                  // width: 100.0,
                  // color: Colors.red,
                )
                    // Container(

                    //   decoration: BoxDecoration(
                    //     color: Colors.red,
                    //     shape: BoxShape.circle,
                    //     icon:Icon(Icons.g_mobiledata)
                    //   ),
                    // )
                    ;
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

enum Direction {
  up,
  down,
  left,
  right,
}
