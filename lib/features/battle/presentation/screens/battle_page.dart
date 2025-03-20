import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizflow_frontend/features/battle/presentation/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BattlePage extends StatefulWidget {
  // final int quizroomId;
  // final GetMessagesUseCase getMessagesUseCase;
  // final ConnectWebSocketUseCase connectWebSocketUseCase;

  const BattlePage({
    Key? key,
    // required this.quizroomId,
    // required this.getMessagesUseCase,
    // required this.connectWebSocketUseCase,
  }) : super(key: key);

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
