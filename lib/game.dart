import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, PhysicalKeyboardKey, KeyRepeatEvent, ServicesBinding;

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Position> positions = [Position(0, 0)];
  final Key _key = const Key('main');
  AxisDirection directionality = AxisDirection.right;
  Position goal = Position.empty();
  bool _onKeyDown(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.backspace) {
        setState(() {
          if (positions.length != 1) {
            positions.removeAt(positions.length - 1);
          }
        });
        return true;
      }
      if (directionality != AxisDirection.down &&
          (event.physicalKey == PhysicalKeyboardKey.keyW || event.physicalKey == PhysicalKeyboardKey.arrowUp)) {
        directionality = AxisDirection.up;
      } else if (directionality != AxisDirection.up &&
          (event.physicalKey == PhysicalKeyboardKey.keyS || event.physicalKey == PhysicalKeyboardKey.arrowDown)) {
        directionality = AxisDirection.down;
      } else if (directionality != AxisDirection.right &&
          (event.physicalKey == PhysicalKeyboardKey.keyA || event.physicalKey == PhysicalKeyboardKey.arrowLeft)) {
        directionality = AxisDirection.left;
      } else if (directionality != AxisDirection.left &&
          (event.physicalKey == PhysicalKeyboardKey.keyD || event.physicalKey == PhysicalKeyboardKey.arrowRight)) {
        directionality = AxisDirection.right;
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKeyDown);
    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      for (int i = 0; i + 1 < positions.length; i++) {
        positions[i] = Position(positions[i + 1].left, positions[i + 1].top);
      }
      Position myPosition = positions.last;
      if (directionality == AxisDirection.up) {
        myPosition.top = myPosition.top - 80;
      } else if (directionality == AxisDirection.down) {
        myPosition.top = myPosition.top + 80;
      } else if (directionality == AxisDirection.left) {
        myPosition.left = myPosition.left - 80;
      } else if (directionality == AxisDirection.right) {
        myPosition.left = myPosition.left + 80;
      }
      //collision
      for (int i = 0; i + 1 < positions.length; i++) {
        if (positions[i].top == myPosition.top && positions[i].left == myPosition.left) {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    height: 250,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurpleAccent,
                          Colors.blueGrey[700]!,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Game Over",
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // const SizedBox(height: 20.0),
                        // Text(
                        //   "Score: ${score.value}",
                        //   style: const TextStyle(
                        //     fontSize: 20.0,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //   ),
                        // ),
                        const SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Play Again",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
          positions = [Position.empty()];
          directionality = AxisDirection.right;
        }
      }

      setState(() {});
      _checkGoalReached();
    });
  }

  @override
  void didChangeDependencies() {
    _generateGoal();
    super.didChangeDependencies();
  }

  void _generateGoal() {
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final goalLeft = (random.nextDouble() * (screenWidth - 50)).round().toDouble();
    final goalTop = (random.nextDouble() * (screenHeight - 50)).round().toDouble();
    goal = Position(goalLeft, goalTop);
  }

  // Check if the snake has reached the goal and generate a new goal if it has
  void _checkGoalReached() {
    final lastPosition = positions.last;
    if ((lastPosition.left - goal.left).abs() <= 50 && (lastPosition.top - goal.top).abs() <= 50) {
      _generateGoal();
      Position myPosition = positions.last;
      if (directionality == AxisDirection.up) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
      } else if (directionality == AxisDirection.down) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
      } else if (directionality == AxisDirection.left) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
      } else if (directionality == AxisDirection.right) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ...positions.mapIndexed(
            (index, entry) => AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              key: index == positions.length - 1 ? _key : null,
              curve: Curves.linear,
              left: entry.left,
              top: entry.top,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: index == positions.length - 1 ? Colors.blue : Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: (index == positions.length - 1 ? Colors.blue : Colors.red).withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: goal.left,
            top: goal.top,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Position {
  double left;
  double top;

  Position(this.left, this.top);

  Position.empty({this.left = 0, this.top = 0});
}
