import 'package:flutter/material.dart';


enum TileState {covered, wrong, open, flagged, reveal}


void main() => runApp(MineSweeper());

class MineSweeper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MineSweeper",
      home: Board(),
    );
  }
}

class Board extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final int rows = 9;
  final int cols = 9;
  final int mines = 11;
  List<List<TileState>> stateUI;


  void reset() {
    stateUI = new List<List<TileState>>.generate(rows, (row) {
      return new List<TileState>.filled(cols, TileState.covered);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

