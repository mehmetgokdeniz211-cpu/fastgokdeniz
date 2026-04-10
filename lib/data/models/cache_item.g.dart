// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheItemAdapter extends TypeAdapter<CacheItem> {
  @override
  final int typeId = 1;

  @override
  CacheItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheItem()
      ..id = fields[0] as int
      ..key = fields[1] as String
      ..value = fields[2] as String
      ..createdAt = fields[3] as DateTime
      ..expiresAt = fields[4] as DateTime
      ..type = fields[5] as String;
  }

  @override
  void write(BinaryWriter writer, CacheItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.key)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.expiresAt)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
