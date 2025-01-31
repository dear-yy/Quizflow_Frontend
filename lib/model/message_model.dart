class MessageModel {
  final int id;
  final bool isMine;
  final String message;
  final int? point;
  final DateTime date;

  MessageModel({
    required  this.id,
    required this.isMine,
    required this.message,
    required this.date,
    this.point,
  });
}
