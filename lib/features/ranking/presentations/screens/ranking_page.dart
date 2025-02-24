import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/ranking/data/datasources/ranking_remote_data_source.dart';
import 'package:quizflow_frontend/features/ranking/data/repositories/ranking_repository_impl.dart';
import 'package:quizflow_frontend/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:quizflow_frontend/features/ranking/domain/usecases/get_ranking_usecase.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<String> rankings = [];
  bool _isLoading = true;
  String? _errorMessage;

  late final GetRankingUseCase getRankingUseCase;

  @override
  void initState() {
    super.initState();
    _setupDependencies();
    _fetchRankings();
  }

  void _setupDependencies() {
    final httpClient = http.Client();
    final rankingRemoteDataSource = RankingRemoteDataSource(client: httpClient);
    final RankingRepository rankingRepository = RankingRepositoryImpl(rankingRemoteDataSource);
    getRankingUseCase = GetRankingUseCase(rankingRepository);
  }

  Future<void> _fetchRankings() async {
    try {
      final data = await getRankingUseCase.execute();
      if (!mounted) return; // ✅ 위젯이 dispose된 상태라면 setState 실행 방지
      setState(() {
        rankings = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return; // ✅ 위젯이 dispose된 상태라면 setState 실행 방지
      setState(() {
        _errorMessage = "랭킹 불러오기 실패: $error";
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Top Rankings",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: rankings.isNotEmpty
                ? ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text("${index + 1}"),
                  ),
                  title: Text(rankings[index]),
                );
              },
            )
                : const Center(child: Text("랭킹 데이터 없음")),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fetchRankings, // 버튼 클릭 시 랭킹 새로고침
            child: const Text("Refresh Ranking"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
