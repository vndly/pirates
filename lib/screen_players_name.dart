import 'package:dafluta/dafluta.dart';
import 'package:flutter/material.dart';
import 'package:pirates/game_state.dart';

class EnterPlayersNameScreen extends StatelessWidget {
  final GameState state;

  const EnterPlayersNameScreen(this.state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                child: Column(
                  children: [
                    for (int i = 0; i < state.amountOfPlayers; i++)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 200,
                              child: TextField(
                                autofocus: true,
                                maxLines: 1,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: state.controllersPlayersName[i],
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Player ${i + 1}',
                                  errorText: state.errorsScreen2[i],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const VBox(20),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                  child: Text('START'),
                ),
              ),
              const VBox(20),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    final List<String> names = [];

    for (int i = 0; i < state.amountOfPlayers; i++) {
      final String name = state.controllersPlayersName[i].text;

      if (name.isNotEmpty) {
        names.add(name);
        state.setErrorScreen2(i, null);
      } else {
        state.setErrorScreen2(i, 'Invalid name');
      }
    }

    if (names.length == state.amountOfPlayers) {
      state.setPlayersName(names);
    }
  }
}
