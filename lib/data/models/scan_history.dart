import 'package:hive/hive.dart';

part 'scan_history.g.dart';

@HiveType(typeId: 3)
class ScanHistory extends HiveObject {
  @HiveField(0)
  int id = 0;
  
  @HiveField(1)
  late String qrCode;
  
  @HiveField(2)
  late String qrType; // URL, TEXT, EMAIL, PHONE, etc.
  
  @HiveField(3)
  late DateTime scannedAt;
  
  @HiveField(4)
  late bool isFavorite;
  
  @HiveField(5)
  int accessCount = 0;
  
  @HiveField(6)
  String? title;
  
  @HiveField(7)
  String? description;
  
  @HiveField(8)
  DateTime? lastAccessedAt;
}
