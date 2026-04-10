class ProductModel {
  final String barcode;
  final String name;
  final String? description;
  final List<PriceInfo> prices;
  final String? imageUrl;
  final DateTime scannedAt;

  ProductModel({
    required this.barcode,
    required this.name,
    this.description,
    required this.prices,
    this.imageUrl,
    required this.scannedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      barcode: json['barcode'] ?? '',
      name: json['title'] ?? json['name'] ?? 'Bilinmeyen Ürün',
      description: json['description'],
      prices: (json['prices'] as List?)?.map((p) => PriceInfo.fromJson(p)).toList() ?? [],
      imageUrl: json['image'] ?? json['imageUrl'],
      scannedAt: DateTime.now(),
    );
  }

  get lowestPrice {
    if (prices.isEmpty) return null;
    return prices.fold<double?>(null, (lowest, price) {
      final priceValue = double.tryParse(price.price.toString()) ?? 0;
      if (lowest == null) return priceValue;
      return priceValue < lowest ? priceValue : lowest;
    });
  }

  get highestPrice {
    if (prices.isEmpty) return null;
    return prices.fold<double?>(null, (highest, price) {
      final priceValue = double.tryParse(price.price.toString()) ?? 0;
      if (highest == null) return priceValue;
      return priceValue > highest ? priceValue : highest;
    });
  }
}

class PriceInfo {
  final String store;
  final String price;
  final String currency;
  final String? url;

  PriceInfo({
    required this.store,
    required this.price,
    required this.currency,
    this.url,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      store: json['store'] ?? json['name'] ?? 'Bilinmeyen Mağaza',
      price: (json['price'] ?? '0').toString(),
      currency: json['currency'] ?? '₺',
      url: json['url'],
    );
  }
}
