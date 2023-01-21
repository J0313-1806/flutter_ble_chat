class Message {
  final bool sent;
  final String toId;
  final String toUsername;
  final String fromId;
  final String fromUsername;
  final String message;
  final DateTime dateTime;

  Message(
      {required this.sent,
      required this.toId,
      required this.toUsername,
      required this.fromId,
      required this.fromUsername,
      required this.message,
      required this.dateTime});
}
