import 'package:flutter/material.dart';
import '../../core/enums/message_type.dart';
import '../../data/models/message_model.dart';
import '../../domain/send_message_use_case.dart';

class MessageProvider with ChangeNotifier {
  final SendMessageUseCase _sendMessageUseCase;

  MessageProvider(this._sendMessageUseCase);

  MessageType _selectedType = MessageType.whatsapp;
  String _phoneNumber = '';
  String _message = '';
  String _selectedCountryCode = '+90'; // Default Turkey

  MessageType get selectedType => _selectedType;
  String get phoneNumber => _phoneNumber;
  String get message => _message;
  String get selectedCountryCode => _selectedCountryCode;

  void setSelectedType(MessageType type) {
    _selectedType = type;
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void setCountryCode(String code) {
    _selectedCountryCode = code;
    notifyListeners();
  }

  Future<void> sendMessage() async {
    final fullPhoneNumber = _selectedCountryCode + _phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final messageModel = MessageModel(
      type: _selectedType,
      phoneNumber: fullPhoneNumber,
      message: _message.isNotEmpty ? _message : null,
    );
    await _sendMessageUseCase.execute(messageModel);
  }
}