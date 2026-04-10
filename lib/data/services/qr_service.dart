// QR kod oluşturma için qr_flutter kullanılıyor, ama service sadece model döndürecek
import '../models/qr_model.dart';

class QRService {
  QRModel generateQR(String url) {
    return QRModel(url: url);
  }
}