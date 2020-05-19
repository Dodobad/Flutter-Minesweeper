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
  void initState(){
    reset();
    super.initState();
  }

  Widget newBoard() {
    List<Row> boardRow = <Row>[];
    for(int i =0; i< rows; i++) {
      List<Widget> rowChild = <Widget>[];
      for(int j=0; j<cols; j++){
        TileState state = stateUI[i][j];
        if(state == TileState.covered) {
          rowChild.add(GestureDetector(
            child: Listener(
              child: Container(
                margin: EdgeInsets.all(2.0),
                height: 20.0,
                width: 20.0,
                color: Colors.grey,
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
    return Container();
  }
}

