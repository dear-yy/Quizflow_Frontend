class BattleRecord {
  final int id;
  final String player1;
  final String player2;
  final int score1;
  final int score2;
  final String startDate;
  final bool isEnded;

  BattleRecord({
    required this.id,
    required this.player1,
    required this.player2,
    required this.score1,
    required this.score2,
    required this.startDate,
    required this.isEnded,
  });

  factory BattleRecord.fromJson(Map<String, dynamic> json) {
    return BattleRecord(
      id: json['id'],
      player1: json['player_1']['nickname'],
      player2: json['player_2']['nickname'],
      score1: json['total_score_1'],
      score2: json['total_score_2'],
      startDate: json['start_date'],
      isEnded: json['is_ended'],
    );
  }
}
