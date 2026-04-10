# FastGokdeniz - Geliştirilmiş Özellikler Rehberi

## Yeni Özellikler

### 1. **Kullanıcı Profili & Kimlik Doğrulama** 🔐
- Firebase Authentication ile email/şifre sistemi
- Anonim giriş seçeneği
- Profil yönetimi (ad, biyografi, resim)
- İstatistikler takibi (taramalar, mesajlar, favoriler)

**Nasıl kullanılır:**
```dart
final authProvider = context.read<AuthenticationProvider>();
await authProvider.login('email@example.com', 'password');
```

### 2. **Veritabanı & Yerel Depolama** 💾
- **Isar** ile offline veritabanı
- Tüm verileri cihazda saklama
- Hızlı sorgu ve filtreleme

**Modeller:**
- `ScanHistory` - Tarama geçmişi
- `UserProfile` - Kullanıcı bilgileri
- `SavedMessage` - Kaydedilmiş mesajlar
- `CacheItem` - İnternet verisi önbelleği

### 3. **Gelişmiş Arama & Filtreleme** 🔍
- Metinsel arama
- QR tipi filtreleme (URL, EMAIL, PHONE, WIFI, etc.)
- Tarih aralığı filtresi
- Sıralama seçenekleri (en yeni, en eski, en çok erişilen)
- Öneriler sistemi (autocomplete)
- Trending öğeler
- Sık erişilen öğeler

**Kullanım:**
```dart
final searchService = SearchFilterService();
final results = await searchService.advancedSearch(
  query: 'instagram',
  qrType: 'URL',
  favoritesOnly: true,
);
```

### 4. **Favoriler Sistemi** ⭐
- Önemli taramaları kaydetme
- Hızlı erişim
- Favoriler ekranı

### 5. **Bildirimler** 🔔
- Push notifications (Firebase Cloud Messaging)
- Yerel bildirimler
- Zamanlanmış bildirimler
- On/off toggle

**Ayarlar:**
- Ayarlar > Enable Notifications

### 6. **Caching Sistemi** ⚡
- Otomatik HTTP caching
- Görsel caching
- Süre sonunda otomatik silme
- JSON verisi caching

```dart
final cachingService = context.read<CachingService>();
final data = await cachingService.cachedGet(url);
```

### 7. **Paylaşım Seçenekleri** 📤
- QR kodları paylaş
- Metni paylaş
- Dosyaları paylaş
- Verileri dış playlayıcıya aktar

### 8. **Export & Import** 📊
- Tüm verileri JSON olarak dışa aktar
- CSV formatında tarama geçmişi
- İthal etme (yedekten geri yükle)
- Veri yedeklemesi

**Ayarlar:**
- Ayarlar > Export Data
- Ayarlar > Import Data

### 9. **Kamera Kontrolleri** 📸
- Flaş açıp kapatma
- Ön/arka kamera değişimi
- Zoom kontrolü
- Çok hızlı QR taraması

### 10. **Kullanıcı İstatistikleri** 📈
- Toplam taramalar
- Toplam mesajlar
- Toplam favoriler
- En çok kullanılan tip

---

## Kurulum

### Step 1: Dependencies Yükle
```bash
flutter pub get
```

### Step 2: Firebase Ayarla
1. [Firebase Console](https://console.firebase.google.com) açın
2. Yeni proje oluşturun
3. Android uygulaması ekleyin
4. `google-services.json` indirin: `android/app/` klasörüne kopyalayın
5. iOS uygulaması ekleyin (opsiyonel)
6. `GoogleService-Info.plist` indirin: `ios/Runner/` klasörüne kopyalayın

### Step 3: Isar Modelleri Generate Et
```bash
flutter pub run build_runner build
```

### Step 4: Uygulamayı Çalıştır
```bash
flutter run
```

---

## Dosya Yapısı

```
lib/
├── core/
│   ├── services/          # Tüm hizmetler
│   │   ├── authentication_service.dart
│   │   ├── notification_service.dart
│   │   ├── caching_service.dart
│   │   ├── search_filter_service.dart
│   │   ├── sharing_service.dart
│   │   ├── camera_service.dart
│   │   └── export_import_service.dart
│   └── utils/
│       ├── datetime_utils.dart
│       ├── validation_utils.dart
│       └── qr_code_utils.dart
├── data/
│   ├── models/            # Veritabanı modelleri
│   │   ├── scan_history.dart
│   │   ├── user_profile.dart
│   │   ├── saved_message.dart
│   │   └── cache_item.dart
│   └── services/
│       └── database_service.dart
├── presentation/
│   └── providers/         # State management
│       ├── authentication_provider.dart
│       ├── user_profile_provider.dart
│       └── scan_history_provider.dart
└── view/screens/          # UI Screens
    ├── login_screen.dart
    ├── profile_detail_screen.dart
    ├── favorites_screen.dart
    ├── advanced_search_screen.dart
    └── settings_advanced_screen.dart
```

---

## Kullanıcı Akışları

### Akış 1: İlk Kez Giriş
1. Splash Screen
2. Login/Signup
3. Profil Oluşturma
4. Home Screen

### Akış 2: QR Tarama
1. Home Screen > Kamera
2. QR Scan
3. Otomatik Veritabanına Kaydetme
4. Favoriye Ekle / Paylaş

### Akış 3: Arama & Filtreleme
1. Home Screen > Search Icon
2. Advanced Search
3. Filtrele (Tarih, Tip, Metin)
4. Sonuçlar Göster

### Akış 4: Veri Yönetimi
1. Settings > Settings Advanced
2. Export / Import / Clear All

---

## API Örnekleri

### Kimlik Doğrulama
```dart
final authService = context.read<AuthenticationService>();
await authService.loginWithEmail('user@example.com', 'password');
await authService.logout();
```

### Veritabanı İşlemleri
```dart
final db = getIt<DatabaseService>();
await db.addScanHistory(scanHistory);
final history = await db.getScanHistory(limit: 50);
await db.toggleFavorite(id, true);
```

### Bildirimler
```dart
final notificationService = getIt<NotificationService>();
await notificationService.showNotification(
  id: 1,
  title: 'New QR Code',
  body: 'You scanned a new code',
);
```

### Paylaşım
```dart
final sharingService = getIt<SharingService>();
await sharingService.shareText(
  text: 'Check out this cool QR code!',
);
```

### Export/Import
```dart
final exportService = ExportImportService();
final jsonData = await exportService.exportAllData();
await exportService.importData(jsonData);
```

---

## Yapılandırma

### Notification Settings
- `core/services/notification_service.dart` dosyasında notification kanallarını özelleştirebilirsiniz

### Database Settings
- `data/services/database_service.dart` dosyasında query limitlerini değiştirebilirsiniz

### Cache Duration
- `core/services/caching_service.dart` dosyasında varsayılan cache süresi (7 gün)

---

## Sorun Çözme

### Firebase bağlantısı başarısız
- `google-services.json` dosyasının doğru yolda olduğunu kontrol edin
- Firebase Console'de projeyi kontrol edin

### Veritabanı hataları
```bash
flutter pub run build_runner build
```

### Notification izinleri
- Android: AndroidManifest.xml'de POST_NOTIFICATIONS izni kontrol edin
- iOS: Info.plist'de notification izinleri kontrol edin

---

## Gelecek Özellikler
- 👥 Sosyal paylaşım (takip et, favorite, comment)
- 🗺️ Konum tabanlı QR'lar
- 🤖 AI-powered suggestions
- 📱 Widget desteği
- 🌐 Cloud sync

---

## Lisans
MIT License

## İletişim
Hata bildirimi veya önerileri için: support@fastgokdeniz.com
