import 'package:dafluta/dafluta.dart';
import 'package:flutter/material.dart';
import 'package:pirates/game_state.dart';

class SelectPlayersAmountScreen extends StatelessWidget {
  final GameState state;

  const SelectPlayersAmountScreen(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              child: TextField(
                autofocus: true,
                controller: state.controllerAmountPlayers,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Number of players',
                  errorText: state.errorScreen1,
                ),
              ),
            ),
            const VBox(20),
            ElevatedButton(
              onPressed: _onSubmit,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                child: Text('CREATE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    final String value = state.controllerAmountPlayers.text;

    if (value.isNotEmpty) {
      try {
        final int amount = int.parse(value);

        if (amount > 1) {
          state.setAmountOfPlayers(amount);
        } else {
          state.setErrorScreen1('Invalid amount');
        }
      } catch (e) {
        state.setErrorScreen1('Invalid amount');
      }
    } else {
      state.setErrorScreen1('Invalid amount');
    }
  }
}
