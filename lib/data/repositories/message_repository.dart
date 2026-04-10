import '../models/message_model.dart';
import '../services/message_service.dart';

class MessageRepository {
  final MessageService _messageService;

  MessageRepository(this._messageService);

  Future<void> sendMessage(MessageModel message) async {
    await _messageService.sendMessage(message);
  }
}