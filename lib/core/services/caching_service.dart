import 'package:dio/dio.dart';
import '../../data/services/database_service.dart';
import 'dart:convert';

class CachingService {
  static final CachingService _instance = CachingService._internal();
  late Dio _dio;
  final DatabaseService _db = DatabaseService();
  final Duration _defaultCacheDuration = const Duration(days: 7);

  factory CachingService() {
    return _instance;
  }

  CachingService._internal();

  void initialize() {
    _dio = Dio();
  }

  // Cache GET request
  Future<dynamic> cachedGet(
    String url, {
    Duration? cacheDuration,
    Map<String, dynamic>? queryParameters,
  }) async {
    final cacheKey = '$url?${jsonEncode(queryParameters)}';
    
    // Check cache first
    final cachedData = await _db.getCacheItem(cacheKey);
    if (cachedData != null) {
      try {
        return jsonDecode(cachedData);
      } catch (e) {
        return cachedData;
      }
    }

    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
      );

      // Store in cache
      await _db.setCacheItem(
        cacheKey,
        jsonEncode(response.data),
        expiryDays: (cacheDuration?.inDays) ?? _defaultCacheDuration.inDays,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Cache image
  Future<String> cacheImage(String imageUrl) async {
    final cacheKey = 'image_$imageUrl';
    
    final cached = await _db.getCacheItem(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final base64 = base64Encode(response.data!);
      await _db.setCacheItem(cacheKey, base64);
      return base64;
    } catch (e) {
      rethrow;
    }
  }

  // Clear old cache
  Future<void> clearOldCache() async {
    await _db.clearExpiredCache();
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    // Implement full cache clear
  }
}
