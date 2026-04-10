import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class PriceApiService {
  static const String _baseUrl = 'https://api.example.com/prices';
  static const Duration _timeout = Duration(seconds: 30);

  /// Ürün fiyatlarını API'den çek
  static Future<List<PriceInfo>> fetchPrices(String productName) async {
    try {
      final url = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {'q': productName},
      );

      final response = await http
          .get(url)
          .timeout(_timeout)
          .then((http.Response response) => response);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final results = json['results'] as List?;

        if (results != null && results.isNotEmpty) {
          return results
              .map((item) => PriceInfo.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Fiyat API hatası: $e');
      return [];
    }
  }

  /// Mağaza fiyatlarını getir
  static Future<List<PriceInfo>> fetchStoresPrices(String productId) async {
    try {
      final url = Uri.parse('$_baseUrl/stores/$productId');

      final response = await http
          .get(url)
          .timeout(_timeout)
          .then((http.Response response) => response);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final prices = json['prices'] as List?;

        if (prices != null) {
          return prices
              .map((item) => PriceInfo.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Mağaza fiyatları API hatası: $e');
      return [];
    }
  }

  /// Gerçek zamanlı fiyat güncelle
  static Future<double?> fetchRealTimePrice(
      String store, String productId) async {
    try {
      final url = Uri.parse('$_baseUrl/real-time/$store/$productId');

      final response = await http
          .get(url)
          .timeout(_timeout)
          .then((http.Response response) => response);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final price = json['price'];
        return double.tryParse(price.toString());
      }
      return null;
    } catch (e) {
      print('Gerçek zamanlı fiyat API hatası: $e');
      return null;
    }
  }

  /// Fiyat karşılaştırması yap
  static Future<Map<String, double>> comparePrice(String productName) async {
    try {
      final url = Uri.parse('$_baseUrl/compare').replace(
        queryParameters: {'product': productName},
      );

      final response = await http
          .get(url)
          .timeout(_timeout)
          .then((http.Response response) => response);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final comparison = json['comparison'] as Map<String, dynamic>?;

        if (comparison != null) {
          return comparison.map(
            (key, value) => MapEntry(key, double.tryParse(value.toString()) ?? 0.0),
          );
        }
      }
      return {};
    } catch (e) {
      print('Fiyat karşılaştırma API hatası: $e');
      return {};
    }
  }
}

/// PriceInfo extension for JSON deserialization
extension PriceInfoJson on PriceInfo {
  static PriceInfo fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      store: json['store'] as String? ?? 'Bilinmiyor',
      price: json['price']?.toString() ?? '---',
      currency: json['currency'] as String? ?? '₺',
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store': store,
      'price': price,
      'currency': currency,
      'url': url,
    };
  }
}
