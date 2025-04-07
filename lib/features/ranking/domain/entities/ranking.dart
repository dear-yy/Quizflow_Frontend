class Profile {
  final String nickname;
  final int rankingScore;
  final String image;

  Profile({
    required this.nickname,
    required this.rankingScore,
    required this.image,
  });
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      nickname: json['nickname'] ?? "unknown",
      rankingScore: json['ranking_score'] ?? 0,
      image: json['image'] ?? "/default.png",
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
    return RankingResponse(
      myProfile: Profile.fromJson(json['profile']),
      todayScore: json['today_score'] ?? 0,
      monthlyPercentage: json['monthly_percentage'].toDouble() ?? 0,
      rankingInfo: (json['ranking_info'] as List)
          .map((e) => Profile.fromJson(e))
          .toList(),
    );
  }
}