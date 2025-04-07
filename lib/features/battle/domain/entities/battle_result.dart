class BattleResult {
  final PlayerResult player1;
  final PlayerResult player2;
  final int myRole;

  BattleResult({
    required this.player1,
    required this.player2,
    required this.myRole,
  });

  factory BattleResult.fromJson(Map<String, dynamic> json) {
    return BattleResult(
      player1: PlayerResult.fromJson(json['player_1']),
      player2: PlayerResult.fromJson(json['player_2']),
      myRole: json['my_role'],
    );
  }
}

class PlayerResult {
  final bool isEnded;
  final String nickname;
  final String status;
  final int score;

  PlayerResult({
    required this.isEnded,
    required this.nickname,
    required this.status,
    required this.score,
  });

  factory PlayerResult.fromJson(Map<String, dynamic> json) {
    return PlayerResult(
      isEnded: json['is_ended'],
      nickname: json['nickname'],
      status: json['status'],
      score: json['score'],
    );
  }
}
