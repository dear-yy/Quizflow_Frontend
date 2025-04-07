class BattleRecord {
  final int playerId1;
  final int playerId2;
  final String player1;
  final String player2;
  final String image1;
  final String image2;
  final int score1;
  final int score2;
  final String startDate;
  final bool isEnded;
  final String matchResult;

  BattleRecord({
    required this.playerId1,
    required this.playerId2,
    required this.player1,
    required this.player2,
    required this.image1,
    required this.image2,
    required this.score1,
    required this.score2,
    required this.startDate,
    required this.isEnded,
    required this.matchResult,
  });

  factory BattleRecord.fromJson(Map<String, dynamic> json) {
    if (json['player_1'] == null || json['player_2'] == null) {
      throw Exception('player_1 또는 player_2 데이터가 없습니다.');
    }

    final player1Id = json['player_1']['user']['id'];
    final player2Id = json['player_2']['user']['id'];

    if (player1Id == null || player2Id == null) {
      throw Exception('플레이어 ID가 null입니다.');
    }

    return BattleRecord(
      playerId1: player1Id,
      playerId2: player2Id,
      player1: json['player_1']['nickname'] ?? '익명1',
      player2: json['player_2']['nickname'] ?? '익명2',
      image1: json['player_1']['image'] ?? '',
      image2: json['player_2']['image'] ?? '',
      score1: json['total_score_1'] ?? 0,
      score2: json['total_score_2'] ?? 0,
      startDate: json['start_date'] ?? '',
      isEnded: json['is_ended'] ?? false,
      matchResult: json['match_result'] ?? "win",
    );
  }
}
