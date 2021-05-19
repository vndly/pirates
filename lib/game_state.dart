import 'package:dafluta/dafluta.dart';
import 'package:flutter/widgets.dart';
import 'package:pirates/pirate_app.dart';
import 'package:pirates/turn.dart';

class GameState with BaseState {
  int state = 0; // 0: players | 1: names | 2: match
  int playerStarting = 0;
  int amountOfPlayers = 0;
  List<String> names = [];

  TextEditingController controllerAmountPlayers = TextEditingController();
  String? errorScreen1;

  final List<TextEditingController> controllersPlayersName = [];
  List<String?> errorsScreen2 = [];

  List<Turn> turns = [];

  bool get isSelectPlayersAmount => state == 0;

  bool get isEnterPlayersName => state == 1;

  bool get isMatch => state == 2;

  void test() {
    amountOfPlayers = 3;
    setPlayersName(['Momo', 'Eric', 'Pauline']);
  }

  void setErrorScreen1(String value) {
    errorScreen1 = value;
    notify();
  }

  void setErrorScreen2(int index, String? value) {
    errorsScreen2[index] = value;
    notify();
  }

  void setAmountOfPlayers(int value) {
    amountOfPlayers = value;
    state = 1;

    controllersPlayersName.clear();
    errorsScreen2.clear();

    for (int i = 0; i < amountOfPlayers; i++) {
      errorsScreen2.add(null);
      controllersPlayersName.add(TextEditingController());
    }

    notify();
  }

  void setPlayersName(List<String> list) {
    state = 2;

    names = list;
    names.shuffle();

    for (int i = 1; i <= MAX_TURNS; i++) {
      turns.add(Turn.create(i, amountOfPlayers));
    }

    notify();
  }

  void setPlayerStarting(int value) {
    playerStarting = value;
    notify();
  }
}
