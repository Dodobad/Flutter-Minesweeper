import 'dart:async';

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

  bool alive;
  bool won;
  int minesFound;
  Timer timer;
  Stopwatch watch = Stopwatch();

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void reset() {
    alive = true;
    won = false;
    minesFound = 0;
    watch.reset();
    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });

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
    bool hasCoveredCell = false;
    List<Row> boardRow = <Row>[];
    for (int y = 0; y < rows; y++) {
      List<Widget> rowChild = <Widget>[];
      for (int x = 0; x < cols; x++) {
        TileState state = stateUI[y][x];
        int count = mineCount(x, y);
        if (alive != null) {
          if (!alive) {
            if (state != TileState.wrong)
              state = tile[y][x] ? TileState.reveal : state;
          }
        }
        if (state == TileState.covered || state == TileState.flagged) {
          rowChild.add(GestureDetector(
            onLongPress: () {
              flag(x, y);
            },
            onTap: () {
              if (state == TileState.covered) probe(x, y);
            },
            child: Listener(
              child: CoveredTile(
                flag: state == TileState.flagged,
                posX: y,
                posY: x,
              ),
            ),
          ));
          if (state == TileState.covered) {
            hasCoveredCell = true;
          }
        } else {
          rowChild.add(OpenTile(state, count));
        }
      }
      boardRow.add(Row(
        children: rowChild,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(y),
      ));
    }
    if (!hasCoveredCell) {
      if ((minesFound == mines) && alive) {
        won = true;
        watch.stop();
      }
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
    int timeElapsed = watch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("MineSweeper"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                child: Text(
                  'Reset Board',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => reset(),
                highlightColor: Colors.red,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: Colors.blue[200],
                  ),
                ),
                color: Colors.blueAccent[100],
              ),
              Container(
                height: 40.0,
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                      text: won
                          ? "Congratulations!  $timeElapsed seconds of play."
                          : alive
                              ? "Found $minesFound of $mines mines. Current playtime: $timeElapsed"
                              : "Lost the game! $timeElapsed seconds of play."),
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: newBoard(),
        ),
      ),
    );
  }

  void probe(int x, int y) {
    if (!alive) return;
    if (stateUI[y][x] == TileState.flagged) return;
    setState(() {
      if (tile[y][x]) {
        stateUI[y][x] = TileState.wrong;
        alive = false;
        timer.cancel();
      } else {
        open(x, y);
        if (!watch.isRunning) watch.start();
      }
    });
  }

  void open(int x, int y) {
    if (!inBoard(x, y)) return;
    if (stateUI[y][x] == TileState.open) return;
    stateUI[y][x] = TileState.open;
    if (mineCount(x, y) > 0) return;

    open(x - 1, y);
    open(x + 1, y);
    open(x - 1, y - 1);
    open(x - 1, y + 1);
    open(x + 1, y - 1);
    open(x - 1, y + 1);
    open(x, y - 1);
    open(x, y + 1);
  }

  void flag(int x, int y) {
    if (!alive) return;
    setState(() {
      if (stateUI[y][x] == TileState.flagged) {
        stateUI[y][x] = TileState.covered;
        --minesFound;
      } else {
        stateUI[y][x] = TileState.flagged;
        ++minesFound;
      }
    });
  }

  int mineCount(int x, int y) {
    int count = 0;
    count += bombs(x - 1, y);
    count += bombs(x + 1, y);
    count += bombs(x, y - 1);
    count += bombs(x, y + 1);
    count += bombs(x - 1, y - 1);
    count += bombs(x - 1, y + 1);
    count += bombs(x + 1, y - 1);
    count += bombs(x + 1, y + 1);
    return count;
  }

  int bombs(int x, int y) => inBoard(x, y) && tile[y][x] ? 1 : 0;

  bool inBoard(int x, int y) => x >= 0 && x < cols && y >= 0 && y < rows;
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
    if (state == TileState.open) {
      if (count != 0) {
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
