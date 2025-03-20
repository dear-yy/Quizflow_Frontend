import 'dart:convert';

class BattleMessageModel {
  final int battleRoomId; // ✅ 배틀룸 ID
  final String message;
  final bool isSystemMessage; // ✅ 시스템 메시지 여부
  final DateTime timestamp;
  final String? playerRole; // ✅ 플레이어 역할 (player_1, player_2)

  BattleMessageModel({
    required this.battleRoomId,
    required this.message,
    required this.isSystemMessage,
    required this.timestamp,
    this.playerRole,
  });

  /// ✅ WebSocket에서 받은 JSON을 `BattleMessageModel`로 변환
  factory BattleMessageModel.fromJson(Map<String, dynamic> json) {
    String finalMessage = "⚠️ 메시지 처리 실패";
    bool isSystemMessage = json['type'] == "system";
    String? playerRole = json['player_role']; // ✅ 플레이어 역할 추가

    try {
      finalMessage = json['message'] ?? "⚠️ 메시지 없음";

      return BattleMessageModel(
        battleRoomId: json['battle_room_id'] ?? 0,
        message: finalMessage,
        isSystemMessage: isSystemMessage,
        timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
        playerRole: playerRole, // ✅ 플레이어 역할 추가
      );
    } catch (e) {
      print("⚠️ BattleMessageModel 파싱 오류 발생: $e");

      return BattleMessageModel(
        battleRoomId: json['battle_room_id'] ?? 0,
        message: "⚠️ 메시지 처리 중 오류 발생",
        isSystemMessage: true,
        timestamp: DateTime.now(),
      );
    }
  }
}
