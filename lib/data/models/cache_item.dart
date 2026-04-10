import 'package:hive/hive.dart';

part 'cache_item.g.dart';

@HiveType(typeId: 1)
class CacheItem extends HiveObject {
  @HiveField(0)
  int id = 0;
  
  @HiveField(1)
  late String key;
  
  @HiveField(2)
  late String value;
  
  @HiveField(3)
  late DateTime createdAt;
  
  @HiveField(4)
  late DateTime expiresAt;
  
  @HiveField(5)
  late String type; // json, text, image, etc.
  
  bool isExpired() {
    return DateTime.now().isAfter(expiresAt);
  }
}
