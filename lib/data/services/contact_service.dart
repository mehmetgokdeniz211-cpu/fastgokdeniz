import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactService {
  static const String recipientEmail = 'mehmetgokdeniz211@gmail.com';
  // Formspree endpoint - doğrudan email ile
  static const String formspreeEndpoint = 'https://formspree.io/mehmetgokdeniz211@gmail.com';

  static Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      print('📧 Formspree\'ye mesaj gönderiliyor...');
      print('Gönderen: $name ($email)');
      
      final response = await http.post(
        Uri.parse(formspreeEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'message': message,
        }),
      );

      print('📬 Yanıt kodu: ${response.statusCode}');
      print('📋 Yanıt: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Mesaj başarıyla gönderildi!');
        return true;
      } else {
        print('❌ Hata: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ İletişim hatası: $e');
      return false;
    }
  }
}
