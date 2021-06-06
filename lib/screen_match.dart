import 'package:dafluta/dafluta.dart';
import 'package:flutter/material.dart';
import 'package:pirates/game_state.dart';
import 'package:pirates/pirate_app.dart';
import 'package:pirates/turn.dart';

class MatchScreen extends StatelessWidget {
  final GameState state;

  const MatchScreen(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(width: 0.2, color: Colors.grey),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                const HeaderCell('TURN', null, false),
                for (int i = 0; i < state.names.length; i++)
                  HeaderCell(
                    state.names[i],
                    () => onPlayerSelected(i),
                    i == state.playerStarting,
                  )
              ],
            ),
            for (final Turn turn in state.turns)
              TableRow(
                children: [
                  HeaderCell(
                    '${turn.turn}',
                    () => onTurnSelected(context, turn),
                    false,
                  ),
                  for (final TurnEntry entry in turn.entries)
                    TurnEntryCell(
                      entry,
                      () => onTurnBetSelected(context, entry),
                      () => onTurnResultSelected(context, entry),
                    )
                ],
              ),
          ],
        ),
      ),
    );
  }

  void onPlayerSelected(int index) {
    state.setPlayerStarting(index);
  }

  void onTurnSelected(BuildContext context, Turn turn) {
    if (turn.hasBets) {
      if (turn.turn < MAX_TURNS) {
        selectWinner(context, turn);
      } else {
        requestResults(context, 0, turn, 0);
      }
    } else {
      requestBets(context, 0, turn);
    }
  }

  void requestBets(BuildContext context, int playerIndex, Turn turn) {
    if (playerIndex < state.amountOfPlayers) {
      showDialog(
        context: context,
        builder: (context) => NumberDialog(
          state.names[playerIndex],
          turn.turn,
          null,
          (value) {
            turn.entries[playerIndex].betValue = value;
            state.notify();
            requestBets(context, playerIndex + 1, turn);
          },
        ),
      );
    }
  }

  void requestResults(
    BuildContext context,
    int playerIndex,
    Turn turn,
    int sumOfResults,
  ) {
    if (playerIndex < state.amountOfPlayers) {
      showDialog(
        context: context,
        builder: (context) => NumberDialog(
          state.names[playerIndex],
          turn.turn,
          turn.entries[playerIndex].betValue,
          (value) =>
              resultSubmitted(context, playerIndex, turn, value, sumOfResults),
        ),
      );
    } else if (turn.turn != sumOfResults) {
      showDialog(
          context: context,
          builder: (context) => WrongResultDialog(turn.turn, sumOfResults));
    }
  }

  void selectWinner(BuildContext context, Turn turn) {
    showDialog(
      context: context,
      builder: (context) => WinnerDialog(
        state.names,
        (value) {
          state.setPlayerStarting(value);
          requestResults(context, 0, turn, 0);
        },
      ),
    );
  }

  void resultSubmitted(
    BuildContext context,
    int playerIndex,
    Turn turn,
    int value,
    int sumOfResults,
  ) {
    final TurnEntry entry = turn.entries[playerIndex];
    final bet = entry.betValue ?? 0;
    int lastScore = 0;

    if (turn.turn >= 2) {
      final TurnEntry pastTurn =
          state.turns[turn.turn - 2].entries[playerIndex];
      lastScore = pastTurn.resultValue ?? 0;
    }

    if (bet == 0) {
      if (value == bet) {
        entry.resultValue = lastScore + (turn.turn * 10);
      } else {
        entry.resultValue = lastScore - (turn.turn * 10);
      }
    } else {
      if (value == bet) {
        entry.resultValue = lastScore + (bet * 20);
      } else {
        final int diff = (bet - value).abs();
        entry.resultValue = lastScore - (diff * 10);
      }
    }

    state.notify();
    requestResults(context, playerIndex + 1, turn, sumOfResults + value);
  }

  void onTurnBetSelected(BuildContext context, TurnEntry entry) {
    showInputDialog(context, (value) {
      entry.betValue = value;
      state.notify();
    });
  }

  void onTurnResultSelected(BuildContext context, TurnEntry entry) {
    showInputDialog(context, (value) {
      entry.resultValue = value;
      state.notify();
    });
  }

  void showInputDialog(BuildContext context, Function(int) callback) {
    showDialog(
      context: context,
      builder: (context) => InputDialog(callback),
    );
  }
}

class HeaderCell extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final bool selected;

  const HeaderCell(this.text, this.onTap, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      color: selected ? const Color(0xffc0c0c0) : const Color(0xfff0f0f0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TurnEntryCell extends StatelessWidget {
  final TurnEntry entry;
  final Function()? onTapBet;
  final Function()? onTapResult;

  const TurnEntryCell(this.entry, this.onTapBet, this.onTapResult);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTapBet,
                child: Center(
                  child: Text(
                    entry.bet,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xffc0c0c0),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.grey,
              width: 0.2,
              height: 45,
            ),
            Expanded(
              child: InkWell(
                onTap: onTapResult,
                child: Center(
                  child: Text(
                    entry.result,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputDialog extends StatelessWidget {
  final Function(int) callback;
  final TextEditingController controller = TextEditingController();

  InputDialog(this.callback);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VBox(20),
          Container(
            width: 250,
            child: TextField(
              autofocus: true,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const VBox(15),
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 250),
            child: ElevatedButton(
              onPressed: () => onAccept(context),
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                child: Text('ACCEPT'),
              ),
            ),
          ),
          const VBox(10),
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 250),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                child: Text('CANCEL'),
              ),
            ),
          ),
          const VBox(20),
        ],
      ),
    );
  }

  void onAccept(BuildContext context) {
    final String value = controller.text;

    if (value.isNotEmpty) {
      callback(int.parse(value));
      Navigator.pop(context);
    }
  }
}

class NumberDialog extends StatelessWidget {
  final String playerName;
  final int maxValue;
  final int? highlight;
  final Function(int) callback;

  const NumberDialog(
      this.playerName, this.maxValue, this.highlight, this.callback);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (int i = 0; i <= maxValue; i++)
                  Container(
                    width: 80,
                    height: 80,
                    color: ((highlight == null) || (highlight != i))
                        ? const Color(0xfff0f0f0)
                        : const Color(0xffd0d0d0),
                    margin: const EdgeInsets.all(10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          callback(i);
                        },
                        child: Center(
                          child: Text(
                            '$i',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const VBox(15),
          ],
        ),
      ),
    );
  }
}

class WinnerDialog extends StatelessWidget {
  final List<String> names;
  final Function(int) callback;

  const WinnerDialog(this.names, this.callback);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Who won?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < names.length; i++)
                  Container(
                    color: const Color(0xfff0f0f0),
                    margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          callback(i);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              names[i],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const VBox(5),
          ],
        ),
      ),
    );
  }
}

class WrongResultDialog extends StatelessWidget {
  final int turn;
  final int results;

  const WrongResultDialog(this.turn, this.results);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VBox(15),
            Center(
              child: Text(
                'Turn: $turn - Results: $results',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const VBox(15),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 250),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                  child: Text('OK'),
                ),
              ),
            ),
            const VBox(15),
          ],
        ),
      ),
    );
  }
}
