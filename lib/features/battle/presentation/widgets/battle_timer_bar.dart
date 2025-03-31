import 'dart:async';
import 'package:flutter/material.dart';

class BattleTimerProgressBar extends StatefulWidget {
  final int durationSeconds; // 총 제한 시간 (초)
  final VoidCallback? onTimerEnd; // 타이머 종료 시 실행할 콜백

  const BattleTimerProgressBar({
    Key? key,
    this.durationSeconds = 900, // 기본값: 15분 (900초)
    this.onTimerEnd,
  }) : super(key: key);

  @override
  State<BattleTimerProgressBar> createState() => _BattleTimerProgressBarState();
}

class _BattleTimerProgressBarState extends State<BattleTimerProgressBar> {
  late int _remainingTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.durationSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        if (widget.onTimerEnd != null) {
          widget.onTimerEnd!(); // 제한 시간 종료 이벤트 실행
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _remainingTime / widget.durationSeconds;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        Text(
          "${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
