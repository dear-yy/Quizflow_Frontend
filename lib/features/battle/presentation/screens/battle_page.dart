import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizflow_frontend/features/battle/data/datasources/battle_remote_data_source.dart';
import 'package:quizflow_frontend/features/battle/data/repositories/battle_repository_impl.dart';
import 'package:quizflow_frontend/features/battle/domain/repositories/battle_repository.dart';
import 'package:quizflow_frontend/features/battle/domain/usecases/start_battle_usecase.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  String battleStatus = "Battle Page"; // 초기 상태 메시지
  bool _isLoading = false;
  String? _errorMessage;

  late final StartBattleUseCase startBattleUseCase;

  @override
  void initState() {
    super.initState();
    _setupDependencies();
  }

  void _setupDependencies() {
    final httpClient = http.Client();
    final battleRemoteDataSource = BattleRemoteDataSource(client: httpClient);
    final BattleRepository battleRepository = BattleRepositoryImpl(battleRemoteDataSource);
    startBattleUseCase = StartBattleUseCase(battleRepository);
  }

  Future<void> _startBattle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await startBattleUseCase.execute();
      setState(() {
        battleStatus = result;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "배틀 시작 실패: $error";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                Center(
                  child: Text(
                    battleStatus,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startBattle, // 버튼 클릭 시 배틀 시작
                  child: const Text("Start Battle"),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
