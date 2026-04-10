import '../data/models/qr_model.dart';
import '../data/repositories/qr_repository.dart';

class GenerateQRUseCase {
  final QRRepository _repository;

  GenerateQRUseCase(this._repository);

  QRModel execute(String url) {
    return _repository.generateQR(url);
  }
}