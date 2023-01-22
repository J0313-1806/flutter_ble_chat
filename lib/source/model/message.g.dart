// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      sent: fields[0] as bool,
      toId: fields[1] as String,
      toUsername: fields[2] as String,
      fromId: fields[3] as String,
      fromUsername: fields[4] as String,
      message: fields[5] as String,
      dateTime: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.sent)
      ..writeByte(1)
      ..write(obj.toId)
      ..writeByte(2)
      ..write(obj.toUsername)
      ..writeByte(3)
      ..write(obj.fromId)
      ..writeByte(4)
      ..write(obj.fromUsername)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
