import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, PhysicalKeyboardKey, KeyRepeatEvent, ServicesBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Position> positions = [Position(0, 0)];
  final Key _key = const Key('main');
  AxisDirection directionality = AxisDirection.right;
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

      if (event.physicalKey == PhysicalKeyboardKey.keyW || event.physicalKey == PhysicalKeyboardKey.arrowUp) {
        directionality = AxisDirection.up;
      } else if (event.physicalKey == PhysicalKeyboardKey.keyS || event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        directionality = AxisDirection.down;
      } else if (event.physicalKey == PhysicalKeyboardKey.keyA || event.physicalKey == PhysicalKeyboardKey.arrowLeft) {
        directionality = AxisDirection.left;
      } else if (event.physicalKey == PhysicalKeyboardKey.keyD || event.physicalKey == PhysicalKeyboardKey.arrowRight) {
        directionality = AxisDirection.right;
      }
      setState(() {});
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKeyDown);
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      Position myPosition = positions.last;
      if (directionality == AxisDirection.up) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
        myPosition.top = myPosition.top - 80;
      } else if (directionality == AxisDirection.down) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
        myPosition.top = myPosition.top + 80;
      } else if (directionality == AxisDirection.left) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
        myPosition.left = myPosition.left - 80;
      } else if (directionality == AxisDirection.right) {
        positions.insert(positions.length - 1, Position(myPosition.left, myPosition.top));
        myPosition.left = myPosition.left + 80;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: positions
            .mapIndexed(
              (index, entry) => AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                key: index == positions.length - 1 ? _key : null,
                curve: Curves.easeInOutCubicEmphasized,
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
            )
            .toList(),
      ),
    );
  }
}

class PositionList extends StateNotifier<List<Position>> {
  PositionList(List<Position> state) : super(state);

  void add(Position position) {
    state = [...state, position];
  }

  void removeLast() {
    state = state.sublist(0, state.length - 1);
  }

  Position get last => state.last;
}

class Position {
  double left;
  double top;

  Position(this.left, this.top);

  Position.empty({this.left = 0, this.top = 0});
}
