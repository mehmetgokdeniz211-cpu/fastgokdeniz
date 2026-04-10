import '../../data/models/message_model.dart';
import '../../data/repositories/message_repository.dart';

class SendMessageUseCase {
  final MessageRepository _repository;

  SendMessageUseCase(this._repository);

  Future<void> execute(MessageModel message) async {
    await _repository.sendMessage(message);
  }
}