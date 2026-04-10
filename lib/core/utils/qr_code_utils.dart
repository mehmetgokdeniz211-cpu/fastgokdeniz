class QRCodeUtils {
  static String detectQRType(String code) {
    if (code.startsWith('http://') || code.startsWith('https://')) {
      return 'URL';
    } else if (code.contains('@')) {
      if (code.startsWith('mailto:')) {
        return 'EMAIL';
      }
      return 'EMAIL';
    } else if (code.startsWith('+') || RegExp(r'^\d{10,}$').hasMatch(code)) {
      return 'PHONE';
    } else if (code.startsWith('WIFI:')) {
      return 'WIFI';
    } else if (code.startsWith('BEGIN:VCARD')) {
      return 'VCARD';
    } else if (code.startsWith('BEGIN:VEVENT')) {
      return 'EVENT';
    }
    return 'TEXT';
  }

  static String extractValueFromQR(String code, String type) {
    switch (type) {
      case 'EMAIL':
        return code.replaceAll('mailto:', '');
      case 'PHONE':
        return code.replaceAll('+', '');
      case 'WIFI':
        // Parse WIFI:T:WPA;S:SSID;P:PASSWORD;;
        final ssidMatch = RegExp(r'S:([^;]+)').firstMatch(code);
        return ssidMatch?.group(1) ?? code;
      default:
        return code;
    }
  }

  static bool isValidQRCode(String code) {
    return code.isNotEmpty && code.length < 2953; // Max QR code capacity
  }

  static String sanitizeQRCode(String code) {
    return code.trim();
  }
}
