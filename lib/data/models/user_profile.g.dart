// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile()
      ..id = fields[0] as int
      ..userId = fields[1] as String
      ..email = fields[2] as String
      ..username = fields[3] as String
      ..displayName = fields[4] as String
      ..createdAt = fields[5] as DateTime
      ..updatedAt = fields[6] as DateTime
      ..bio = fields[7] as String?
      ..profileImageUrl = fields[8] as String?
      ..phoneNumber = fields[9] as String?
      ..totalScans = fields[10] as int
      ..totalMessages = fields[11] as int
      ..totalFavorites = fields[12] as int
      ..isVerified = fields[13] as bool
      ..notificationsEnabled = fields[14] as bool;
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.displayName)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.bio)
      ..writeByte(8)
      ..write(obj.profileImageUrl)
      ..writeByte(9)
      ..write(obj.phoneNumber)
      ..writeByte(10)
      ..write(obj.totalScans)
      ..writeByte(11)
      ..write(obj.totalMessages)
      ..writeByte(12)
      ..write(obj.totalFavorites)
      ..writeByte(13)
      ..write(obj.isVerified)
      ..writeByte(14)
      ..write(obj.notificationsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
