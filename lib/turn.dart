class Turn {
  final int turn;
  final List<TurnEntry> entries;

  Turn(this.turn, this.entries);

  bool get hasBets {
    for (final TurnEntry entry in entries) {
      if (!entry.hasBet) {
        return false;
      }
    }

    return true;
  }

  factory Turn.create(int turn, int amountOfPlayers) {
    final List<TurnEntry> entries = [];

    for (int i = 0; i < amountOfPlayers; i++) {
      entries.add(TurnEntry(null, null));
    }

    return Turn(turn, entries);
  }
}

class TurnEntry {
  int? betValue;
  int? resultValue;

  TurnEntry(this.betValue, this.resultValue);

  bool get hasBet => betValue != null;

  String get bet => (betValue != null) ? '$betValue' : '';

  String get result => (resultValue != null) ? '$resultValue' : '';
}
