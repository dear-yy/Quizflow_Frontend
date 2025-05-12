class Profile {
  final String nickname;
  final int rankingScore;
  final String image;
  final int? rank;

  Profile({
    required this.nickname,
    required this.rankingScore,
    required this.image,
    this.rank,
  });
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nickname: json['nickname'] ?? "unknown",
      rankingScore: json['ranking_score'] ?? 0,
      image: json['image'] ?? "/default.png",
      rank: json['rank'],
    );
  }
}

class RankingResponse {
  final Profile myProfile;
  final int todayScore;
  final double monthlyPercentage;
  final List<Profile> rankingInfo;

  RankingResponse({
    required this.myProfile,
    required this.todayScore,
    required this.monthlyPercentage,
    required this.rankingInfo,
  });

  factory RankingResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawList = json['ranking_info'];
    final List<Profile> rankedList = [];

    for (int i = 0; i < rawList.length; i++) {
      rankedList.add(Profile.fromJson(rawList[i])); // ✅ 여긴 rank 있음
    }

    return RankingResponse(
      myProfile: Profile.fromJson(json['profile']), // ✅ 여긴 rank 없음
      todayScore: json['today_score'] ?? 0,
      monthlyPercentage: (json['monthly_percentage'] ?? 0).toDouble(),
      rankingInfo: rankedList,
    );
  }
}