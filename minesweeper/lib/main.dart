import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum TileState { covered, wrong, open, flagged, reveal }

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
  List<List<bool>> tile;

  void reset() {
    stateUI = new List<List<TileState>>.generate(rows, (row) {
      return new List<TileState>.filled(cols, TileState.covered);
    });

    tile = new List<List<bool>>.generate(rows, (row) {
      return new List<bool>.filled(cols, false);
    });

    Random random = Random();
    int remainingMines = mines;
    while (remainingMines > 0) {
      int pos = random.nextInt(rows * cols);
      int row = pos ~/ rows; //integer division
      int col = pos % cols;
      if (!tile[row][col]) {
        tile[row][col] = true;
        remainingMines--;
      }
    }
  }

  @override
  void initState() {
    reset();
    super.initState();
  }

  Widget newBoard() {
    List<Row> boardRow = <Row>[];
    for (int i = 0; i < rows; i++) {
      List<Widget> rowChild = <Widget>[];
      for (int j = 0; j < cols; j++) {
        TileState state = stateUI[i][j];
        if (state == TileState.covered) {
          rowChild.add(GestureDetector(
            child: Listener(
              child: CoveredTile(
                flag: state == TileState.flagged,
                posX: i,
                posY: j,
              ),
            ),
          ));
        }
      }
      boardRow.add(Row(
        children: rowChild,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(i),
      ));
    }
    return Container(
      color: Colors.grey[700],
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: boardRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MineSweeper"),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: newBoard(),
        ),
      ),
    );
  }
}

Widget buildTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    height: 30.0,
    width: 30.0,
    color: Colors.grey[400],
    margin: EdgeInsets.all(2.0),
    child: child,
  );
}

Widget buildInnerTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    margin: EdgeInsets.all(2.0),
    height: 20.0,
    width: 20.0,
    child: child,
  );
}

class CoveredTile extends StatelessWidget {
  final bool flag;
  final int posX;
  final int posY;

  CoveredTile({this.flag, this.posX, this.posY});

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (flag) {
      text = buildInnerTile(RichText(
        text: TextSpan(
          text: "\u2691",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
      ));
    }
    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: 20.0,
      width: 20.0,
      color: Colors.grey[350],
      child: text,
    );
    return buildTile(innerTile);
  }
}

class OpenTile extends StatelessWidget {
  final TileState state;
  final int count;

  OpenTile(this.state, this.count);

  @override
  Widget build(BuildContext context) {
    Widget text;
    if(state == TileState.open) {
      if(count != 0) {
        text = RichText(
          text: TextSpan(
            text: '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          textAlign: TextAlign.center,
        );
      }
      } else {
        text = RichText(
          text: TextSpan(
            text: '\u2739',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          textAlign: TextAlign.center,
        );
      }
    return buildTile(buildInnerTile(text));
    }
  }

