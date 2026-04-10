import 'package:hive/hive.dart';

part 'saved_message.g.dart';

@HiveType(typeId: 0)
class SavedMessage extends HiveObject {
  @HiveField(0)
  int id = 0;
  
  @HiveField(1)
  late String messageContent;
  
  @HiveField(2)
  late DateTime createdAt;
  
  @HiveField(3)
  late String category;
  
  @HiveField(4)
  late bool isFavorite;
  
  @HiveField(5)
  String? title;
  
  @HiveField(6)
  String? description;
  
  @HiveField(7)
  int usageCount = 0;
  
  @HiveField(8)
  DateTime? lastUsedAt;
}
