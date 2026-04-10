import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  int id = 0;
  
  @HiveField(1)
  late String userId;
  
  @HiveField(2)
  late String email;
  
  @HiveField(3)
  late String username;
  
  @HiveField(4)
  late String displayName;
  
  @HiveField(5)
  late DateTime createdAt;
  
  @HiveField(6)
  late DateTime updatedAt;
  
  @HiveField(7)
  String? bio;
  
  @HiveField(8)
  String? profileImageUrl;
  
  @HiveField(9)
  String? phoneNumber;
  
  // Statistics
  @HiveField(10)
  int totalScans = 0;
  
  @HiveField(11)
  int totalMessages = 0;
  
  @HiveField(12)
  int totalFavorites = 0;
  
  @HiveField(13)
  bool isVerified = false;
  
  @HiveField(14)
  bool notificationsEnabled = true;
}
