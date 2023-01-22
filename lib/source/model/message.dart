import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class Message extends HiveObject {
  @HiveField(0)
  final bool sent;

  @HiveField(1)
  final String toId;

  @HiveField(2)
  final String toUsername;

  @HiveField(3)
  final String fromId;

  @HiveField(4)
  final String fromUsername;

  @HiveField(5)
  final String message;

  @HiveField(6)
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
