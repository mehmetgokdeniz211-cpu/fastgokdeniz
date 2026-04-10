// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedMessageAdapter extends TypeAdapter<SavedMessage> {
  @override
  final int typeId = 0;

  @override
  SavedMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMessage()
      ..id = fields[0] as int
      ..messageContent = fields[1] as String
      ..createdAt = fields[2] as DateTime
      ..category = fields[3] as String
      ..isFavorite = fields[4] as bool
      ..title = fields[5] as String?
      ..description = fields[6] as String?
      ..usageCount = fields[7] as int
      ..lastUsedAt = fields[8] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, SavedMessage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.messageContent)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isFavorite)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.usageCount)
      ..writeByte(8)
      ..write(obj.lastUsedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
