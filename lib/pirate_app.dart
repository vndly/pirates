import 'package:dafluta/dafluta.dart';
import 'package:flutter/material.dart';
import 'package:pirates/game_state.dart';
import 'package:pirates/screen_amount_players.dart';
import 'package:pirates/screen_match.dart';
import 'package:pirates/screen_players_name.dart';

const int MAX_TURNS = 10;

class PiratesApp extends StatelessWidget {
  final GameState state = GameState();

  @override
  Widget build(BuildContext context) {
    // TODO(momo): REMOVE
    //state.test();

    const int color = 0xff0493B1;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          color,
          {
            50: Color(color),
            100: Color(color),
            200: Color(color),
            300: Color(color),
            400: Color(color),
            500: Color(color),
            600: Color(color),
            700: Color(color),
            800: Color(color),
            900: Color(color)
          },
        ),
      ),
      home: StateProvider<GameState>(
        state: state,
        builder: _screen,
      ),
    );
  }

  Widget _screen(BuildContext context, GameState state) {
    if (state.isSelectPlayersAmount) {
      return SelectPlayersAmountScreen(state);
    } else if (state.isEnterPlayersName) {
      return EnterPlayersNameScreen(state);
    } else if (state.isMatch) {
      return MatchScreen(state);
    } else {
      return const Empty();
    }
  }
}
