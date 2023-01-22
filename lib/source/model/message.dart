import 'dart:convert';

import 'package:hive/hive.dart';
part 'message.g.dart';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

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

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sent: json['name'],
      toId: json['toId'],
      toUsername: json['toUsername'],
      fromId: json['fromId'],
      fromUsername: json['fromUsername'],
      message: json['message'],
      dateTime: json['dateTime'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'sent': sent,
      'toId': toId,
      'toUsername': toUsername,
      'fromId': fromId,
      'fromUsername': fromUsername,
      'message': message,
      'dateTime': dateTime,
    };
  }
}
