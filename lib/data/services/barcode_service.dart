import '../models/product_model.dart';

class BarcodeService {
  /// Ürün adı ile ara
  Future<ProductModel?> searchByProductName(String productName) async {
    try {
      // Ürün bilgisini mocktan al
      final product = _generateProductFromName(productName);
      
      if (product != null) {
        return product;
      }
    } catch (e) {
      print('Ürün arama hatası: $e');
    }

    return _generateMockProduct(productName);
  }

  /// Ürün adından ürün oluştur
  ProductModel? _generateProductFromName(String productName) {
    if (productName.isEmpty) return null;

    final mockProducts = {
      'coca-cola 330ml': ProductModel(
        barcode: '1234567890',
        name: 'Coca-Cola 330ml',
        description: 'Gazlı İçecek - Klasik Tat',
        prices: [
          PriceInfo(store: 'A101', price: '15.50', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '17.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '15.25', currency: '₺'),
          PriceInfo(store: 'Migros', price: '18.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '14.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '15.80', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '15.90', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'fanta 330ml': ProductModel(
        barcode: '1234567891',
        name: 'Fanta Portakal 330ml',
        description: 'Gazlı Meyve İçeceği',
        prices: [
          PriceInfo(store: 'A101', price: '14.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '16.50', currency: '₺'),
          PriceInfo(store: 'BİM', price: '14.75', currency: '₺'),
          PriceInfo(store: 'Migros', price: '17.50', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '14.50', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '15.25', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '15.45', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'sprite 330ml': ProductModel(
        barcode: '1234567892',
        name: 'Sprite 330ml',
        description: 'Limonlu Gazlı İçecek',
        prices: [
          PriceInfo(store: 'A101', price: '15.50', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '17.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '15.25', currency: '₺'),
          PriceInfo(store: 'Migros', price: '18.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '14.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '15.80', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '15.90', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'çilek reçeli 380g': ProductModel(
        barcode: '5901234123457',
        name: 'Çilek Reçeli 380g',
        description: 'Doğal Meyve Reçeli',
        prices: [
          PriceInfo(store: 'A101', price: '28.50', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '31.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '27.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '34.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '26.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '29.50', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '29.90', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'nutella 400g': ProductModel(
        barcode: '7613032816406',
        name: 'Nutella Hazelnut Spread 400g',
        description: 'Fındık Kremi',
        prices: [
          PriceInfo(store: 'A101', price: '89.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '94.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '85.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '99.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '84.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '88.50', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '89.90', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'ayran 1 litre': ProductModel(
        barcode: '8691234567890',
        name: 'Ayran 1 Litre',
        description: 'Geleneksel Ayran',
        prices: [
          PriceInfo(store: 'A101', price: '10.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '12.50', currency: '₺'),
          PriceInfo(store: 'BİM', price: '10.50', currency: '₺'),
          PriceInfo(store: 'Migros', price: '13.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '10.50', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '11.50', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '11.80', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'süt 1 litre': ProductModel(
        barcode: '1234567891234',
        name: 'Süt 1 Litre Tam Yağlı',
        description: 'Tam Yağlı Süt',
        prices: [
          PriceInfo(store: 'A101', price: '22.50', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '24.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '21.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '26.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '21.50', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '23.00', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '23.50', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'çay 100 poşet': ProductModel(
        barcode: '3168930007063',
        name: 'Lipton Çay 100 Poşet',
        description: 'Siyah Çay',
        prices: [
          PriceInfo(store: 'A101', price: '18.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '21.50', currency: '₺'),
          PriceInfo(store: 'BİM', price: '17.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '23.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '18.50', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '19.75', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '20.10', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'kahve 250g': ProductModel(
        barcode: '7613032703016',
        name: 'Nescafé Gold Kahve 250g',
        description: 'Instant Kahve',
        prices: [
          PriceInfo(store: 'A101', price: '68.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '74.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '65.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '79.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '65.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '69.50', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '70.25', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'peynir 500g': ProductModel(
        barcode: '1234567893',
        name: 'Beyaz Peynir 500g',
        description: 'Taze Beyaz Peynir',
        prices: [
          PriceInfo(store: 'A101', price: '35.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '38.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '34.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '42.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '34.50', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '36.50', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '37.25', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'yumurta 30 adet': ProductModel(
        barcode: '1234567894',
        name: 'Yumurta 30 Adet',
        description: 'Tavuk Yumurtası',
        prices: [
          PriceInfo(store: 'A101', price: '79.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '89.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '75.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '99.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '77.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '82.50', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '85.00', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      'ekmek 500g': ProductModel(
        barcode: '1234567895',
        name: 'Sandal Ekmek 500g',
        description: 'Sade Ekmek',
        prices: [
          PriceInfo(store: 'A101', price: '8.99', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '9.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '8.50', currency: '₺'),
          PriceInfo(store: 'Migros', price: '11.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '8.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '9.25', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '9.50', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
    };

    // Fuzzy match ile ara
    for (var entry in mockProducts.entries) {
      if (entry.key.toLowerCase().contains(productName.toLowerCase()) ||
          productName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return null;
  }

  /// Barkod bilgisini ara (eski fonksiyon - geri uyumluluk)
  Future<ProductModel?> searchByBarcode(String barcode) async {
    return _generateMockProductByBarcode(barcode);
  }

  /// Barkod ile mock ürün oluştur
  ProductModel _generateMockProductByBarcode(String barcode) {
    final products = {
      '1234567890': ProductModel(
        barcode: barcode,
        name: 'Coca-Cola 330ml',
        description: 'Gazlı İçecek - Klasik Tat',
        prices: [
          PriceInfo(store: 'A101', price: '15.50', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '17.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '15.25', currency: '₺'),
          PriceInfo(store: 'Migros', price: '18.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '14.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '15.80', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '15.90', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
      '5901234123457': ProductModel(
        barcode: barcode,
        name: 'Çilek Reçeli 380g',
        description: 'Doğal Meyve Reçeli',
        prices: [
          PriceInfo(store: 'A101', price: '28.50', currency: '₺'),
          PriceInfo(store: 'Carrefour', price: '31.99', currency: '₺'),
          PriceInfo(store: 'BİM', price: '27.99', currency: '₺'),
          PriceInfo(store: 'Migros', price: '34.99', currency: '₺'),
          PriceInfo(store: 'Trendyol', price: '26.99', currency: '₺'),
          PriceInfo(store: 'Cimri.com', price: '29.50', currency: '₺'),
          PriceInfo(store: 'Google Shopping', price: '29.90', currency: '₺'),
        ],
        scannedAt: DateTime.now(),
      ),
    };

    return products[barcode] ??
        ProductModel(
          barcode: barcode,
          name: 'Taranmayan Ürün',
          description: 'Veritabanında bulunamadı',
          prices: [
            PriceInfo(
              store: 'Fiyat Bilgisi Yok',
              price: '---',
              currency: '₺',
            ),
          ],
          scannedAt: DateTime.now(),
        );
  }

  /// Demo amaçlı mock ürün verisi
  ProductModel _generateMockProduct(String productName) {
    return ProductModel(
      barcode: '',
      name: productName,
      description: 'Ürün bilgisi bulunamadı',
      prices: [
        PriceInfo(store: 'A101', price: '---', currency: '₺'),
        PriceInfo(store: 'Carrefour', price: '---', currency: '₺'),
        PriceInfo(store: 'BİM', price: '---', currency: '₺'),
        PriceInfo(store: 'Migros', price: '---', currency: '₺'),
        PriceInfo(store: 'Trendyol', price: '---', currency: '₺'),
        PriceInfo(store: 'Cimri.com', price: '---', currency: '₺'),
        PriceInfo(store: 'Google Shopping', price: '---', currency: '₺'),
      ],
      scannedAt: DateTime.now(),
    );
  }
}
