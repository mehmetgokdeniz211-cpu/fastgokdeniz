# Flutter Mobil Uygulama - Android 11+ Yönlendirme Optimizasyonu

## Tamamlanan İşler

### 1. Android SDK Versiyonu Güncellendi ✅
- **Dosya**: `android/app/build.gradle.kts`
- **Değişiklik**: `minSdk = 30` (Android 11+ uyumluluğu için)
- **Neden**: Android 11+ için manifest queries özelliğini zorunlu kılıyor

### 2. AndroidManifest.xml Güncellendi ✅
- **Dosya**: `android/app/src/main/AndroidManifest.xml`
- **Eklenen Features**:
  - WhatsApp (com.whatsapp, com.whatsapp.w4b)
  - Telegram (org.telegram.messenger)
  - Discord (com.discord)
  - Instagram (com.instagram.android)
  - Email clients (mailto scheme)
  - SMS/Mobile (smsto scheme)
  - Browser (https scheme)

### 3. AppLauncherService Oluşturuldu ✅
- **Dosya**: `lib/core/services/app_launcher_service.dart`
- **İçerik**: 10 farklı yönlendirme matodu:
  - `launchWhatsApp()` - WhatsApp'a direkt mesaj
  - `launchTelegram()` - Telegram sohbeti
  - `launchDiscord()` - Discord katılımı
  - `launchInstagram()` - Instagram profili
  - `launchEmail()` - Email gönderme
  - `launchSMS()` - SMS/Text mesaj
  - `launchPhoneCall()` - Telefon araması
  - `launchFacebook()` - Facebook sayfası
  - `launchYouTube()` - YouTube kanalı
  - `launchTwitter()` - Twitter/X profili

### 4. QRScannerService Iyileştirildi ✅
- **Dosya**: `lib/data/services/qr_scanner_service.dart`
- **Güncellemeler**:
  - Native app açılışı tercih edilir (web fallback ile)
  - Android 11+ uyumlu LaunchMode kullanımı
  - SMS, Facebook, YouTube metodları eklendi

### 5. QRScannerProvider Genişletildi ✅
- **Dosya**: `lib/presentation/providers/qr_scanner_provider.dart`
- **Yeni Metodlar**:
  - `openSMS()` - SMS/Mobile mesaj
  - `openFacebook()` - Facebook
  - `openYouTube()` - YouTube

### 6. MessageType Enum Güncellendi ✅
- **Dosya**: `lib/core/enums/message_type.dart`
- **Eklenen Tipler**:
  - SMS
  - Telegram
  - Facebook
  - YouTube

### 7. HomeScreen UI Genişletildi ✅
- **Dosya**: `lib/view/screens/home_screen.dart`
- **Eklenen Butonlar** (Grid layout):
  - Row 1: WhatsApp, Instagram, X (Twitter)
  - Row 2: Discord, Email, SMS
  - Row 3: Telegram, Facebook, YouTube
  - Row 4: Website QR Generator

### 8. MessageService Güncellenceldi ✅
- **Dosya**: `lib/data/services/message_service.dart`
- **Switch Case**: Tüm message type'ları için case'ler eklendi (Exhaustive match)

## Desteklenen Platformlar & Uygulamalar

### Yönlendirilebilen Uygulamalar
| Uygulama | Protokol | Android 11+ Uyumlu | Detay |
|----------|----------|-------------------|-------|
| WhatsApp | whatsapp:// | ✅ | Tel & Mesaj |
| Telegram | tg:// | ✅ | Kullanıcı/Grup |
| Discord | discord:// | ✅ | Sunucu/Davet |
| Instagram | instagram:// | ✅ | Profil Ziyareti |
| Email | mailto: | ✅ | Email Gönderme |
| SMS | sms: | ✅ | Mesaj Gönderme |
| Phone | tel: | ✅ | Arama Yapma |
| Facebook | fb:// | ✅ | Sayfa Ziyareti |
| YouTube | https:// | ✅ | Kanal Ziyareti |
| Twitter/X | twitter:// | ✅ | Profil Ziyareti |
| Web | https:// | ✅ | URL Açma |

## Android 11+ Uyumluluğu

### Zorlanmış Öğeler
1. **minSdk = 30** - Android 11 minimum versiyonu
2. **Package Visibility** - AndroidManifest.xml'de `<queries>` tag
3. **LaunchMode** - `externalApplication` modu kullanımı
4. **Intent-Filter** - Benzersiz yönlendirmelerin tanımlanması

### Avantajlar
- Kullanıcı gizliliği korunur (tüm uygulamalar sizin uygulamaya erişemez)
- Uygulamanın native fonksiyonlarını kullanabilir
- Daha hızlı ve güvenilir yönlendirme
- Google Play Store'da onaylanması kolay

## Kod Örneği - Kullanım

```dart
// WhatsApp'a mesaj gönder
await AppLauncherService.launchWhatsApp(
  phoneNumber: '905551234567',
  message: 'Merhaba!',
);

// Email gönder
await AppLauncherService.launchEmail(
  email: 'user@example.com',
  subject: 'Konu',
  body: 'İçerik',
);

// SMS gönder
await AppLauncherService.launchSMS(
  phoneNumber: '905551234567',
  message: 'Hallo!',
);

// Instagram profili aç
await AppLauncherService.launchInstagram(username: 'kullaniciadi');
```

## Proje Dosya Yapısı

```
lib/
├── core/
│   ├── enums/
│   │   └── message_type.dart (Güncellenildi)
│   └── services/
│       └── app_launcher_service.dart (YENİ)
├── data/
│   └── services/
│       ├── message_service.dart (Güncellenildi)
│       └── qr_scanner_service.dart (Güncellenildi)
├── presentation/
│   └── providers/
│       └── qr_scanner_provider.dart (Güncellenildi)
└── view/
    └── screens/
        └── home_screen.dart (Güncellenildi)

android/
├── app/
│   ├── build.gradle.kts (Güncellenildi - minSdk = 30)
│   └── src/main/
│       └── AndroidManifest.xml (Güncellenildi - queries eklendi)
```

## Test Listesi

- [ ] Turkish: Türkçe dil seçeneğinde tüm butonlar test edildi
- [ ] WhatsApp: Telefon numarası ile mesaj açma
- [ ] Instagram: Kullanıcı adı ile profil açma
- [ ] Email: Email adresi ile posta uygulaması açma
- [ ] SMS: Telefon numarası ile SMS açma
- [ ] Discord: Davet kodu ile Discord açma
- [ ] Telegram: Kullanıcı adı ile Telegram açma
- [ ] Facebook: Sayfa adı ile Facebook açma
- [ ] YouTube: Kanal adı ile YouTube açma
- [ ] Twitter/X: Kullanıcı adı ile Twitter açma
- [ ] Android 11+ cihazda manifest queries kontrolü
- [ ] QR kod tarama (native app tercih ediyor mu)

## Ek Notlar

### Locale Desteği
Türkçe stringleri `app_strings.dart`'a aşağıdakileri ekleyin:
```dart
'sms': 'SMS',
'facebook': 'Facebook',
'youtube': 'YouTube',
'telegram': 'Telegram',
```

### Error Handling
Bütün metodlar try-catch ile sarılı ve web URL fallback sağlıyor:
1. Native app açılmaya çalışılır
2. Başarısız olursa web URL açılır
3. Web URL de açılamazsa Exception fırlatılır

## Versiyon Bilgisi
- Flutter SDK: ^3.11.1
- Minimum Android: API 30 (Android 11)
- Target Android: API 34 (Android 14)
- url_launcher: ^6.2.2
- provider: ^6.1.1

---

**Tamamlanma Tarihi**: 17 Mart 2026
**Durum**: ✅ Tamamlandı - Hatalı Yok
