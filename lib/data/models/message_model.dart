import '../../core/enums/message_type.dart';

class MessageModel {
  final MessageType type;
  final String phoneNumber;
  final String? message;

  MessageModel({
    required this.type,
    required this.phoneNumber,
    this.message,
  });
}