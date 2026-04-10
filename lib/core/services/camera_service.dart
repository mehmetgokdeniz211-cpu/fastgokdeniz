import 'package:mobile_scanner/mobile_scanner.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  late MobileScannerController _controller;

  factory CameraService() {
    return _instance;
  }

  CameraService._internal();

  void initialize() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  MobileScannerController get controller => _controller;

  // Enable flashlight
  Future<void> enableFlash() async {
    await _controller.toggleTorch();
  }

  // Disable flashlight
  Future<void> disableFlash() async {
    await _controller.toggleTorch();
  }

  // Switch camera (front/back)
  Future<void> switchCamera() async {
    await _controller.switchCamera();
  }

  // Change zoom level
  Future<void> setZoom(double zoomLevel) async {
    await _controller.setZoomScale(zoomLevel);
  }

  // Dispose
  void dispose() {
    _controller.dispose();
  }
}
