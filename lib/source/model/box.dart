import 'dart:convert';

import 'package:b_le/source/model/message.dart';

BoxModel boxModelFromJson(String str) => BoxModel.fromJson(json.decode(str));

String boxModelToJson(BoxModel data) => json.encode(data.toJson());

class BoxModel {
  final String key;
  final Message message;

  BoxModel({required this.key, required this.message});

  factory BoxModel.fromJson(Map<String, dynamic> json) {
    return BoxModel(
      key: json['key'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'message': message,
    };
  }
}
