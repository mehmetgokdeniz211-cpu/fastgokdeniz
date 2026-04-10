// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanHistoryAdapter extends TypeAdapter<ScanHistory> {
  @override
  final int typeId = 3;

  @override
  ScanHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistory()
      ..id = fields[0] as int
      ..qrCode = fields[1] as String
      ..qrType = fields[2] as String
      ..scannedAt = fields[3] as DateTime
      ..isFavorite = fields[4] as bool
      ..accessCount = fields[5] as int
      ..title = fields[6] as String?
      ..description = fields[7] as String?
      ..lastAccessedAt = fields[8] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, ScanHistory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.qrCode)
      ..writeByte(2)
      ..write(obj.qrType)
      ..writeByte(3)
      ..write(obj.scannedAt)
      ..writeByte(4)
      ..write(obj.isFavorite)
      ..writeByte(5)
      ..write(obj.accessCount)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.lastAccessedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
