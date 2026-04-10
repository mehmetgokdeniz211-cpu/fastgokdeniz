import '../models/qr_model.dart';
import '../services/qr_service.dart';

class QRRepository {
  final QRService _qrService;

  QRRepository(this._qrService);

  QRModel generateQR(String url) {
    return _qrService.generateQR(url);
  }
}