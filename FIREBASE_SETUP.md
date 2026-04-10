# Firebase Kurulum Rehberi

## Android Setup

### 1. Firebase Project Oluştur
1. https://console.firebase.google.com adresine git
2. "Create a new project" tıkla
3. Proje ismini gir: `FastGokdeniz`
4. Google Analytics seçeneğini kapat

### 2. Android App Ekle
1. Project Settings > Add App > Android seç
2. Package name: `com.example.mobilapptry` (Android Studio'da Package Name'i kontrol et)
3. SHA-1 grayfingerprint al:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
4. SHA-1'i Firebase Console'ye yapıştır
5. `google-services.json` indir
6. `android/app/` klasörüne kopyala

### 3. Android Manifest Güncelle
`android/app/build.gradle.kts` dosyasını aç:

```kotlin
plugins {
    // ... diğer plugins
    id("com.google.gms.google-services") version "4.3.15"
}

dependencies {
    // ... diğer dependencies
}
```

`android/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
}
```

### 4. Firebase Services Etkinleştir

#### Authentication
1. Firebase Console > Authentication
2. Sign-in method > Email/Password etkinleştir
3. Anonymous etkinleştir (opsiyonel)

#### Cloud Messaging
1. Firebase Console > Cloud Messaging
2. API etkinleştir

#### Firestore (opsiyonel)
1. Firebase Console > Firestore Database
2. Başlat > Production modunda başlat

---

## iOS Setup

### 1. iOS App Ekle
1. Firebase Console > Add App > iOS seç
2. Bundle ID: `com.example.mobilapptry` (Xcode'da kontrol et)
3. `GoogleService-Info.plist` indir
4. Xcode'da `ios/Runner` klasörüne drag-drop yap
5. "Copy items if needed" seç

### 2. Kurulum Tamamla
Xcode'da otomatik olarak konfigüre olur.

---

## Dart/Flutter Setup

### 1. pubspec.yaml Güncelleme
Zaten yapıldı (firebase_* packages eklenmiş)

### 2. Flutter Upgrade
```bash
flutter upgrade
flutter pub get
```

### 3. iOS Pods Güncelle (Mac)
```bash
cd ios
pod install --repo-update
cd ..
```

### 4. Android Gradle Sync
Android Studio: File > Sync Now

---

## Test Etme

### Android Test
```bash
flutter run -v
```

### iOS Test (Mac)
```bash
flutter run -f lib/main.dart
```

### Firebase Bağlantısını Test Et

1. `main.dart` açın
2. FirebaseAuth'u test edin:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase init test
  try {
    await Firebase.initializeApp();
    print('Firebase initialized');
  } catch (e) {
    print('Firebase error: $e');
  }
  
  await setupDependencies();
  runApp(const MyApp());
}
```

### Notification Test
1. Firebase Console > Cloud Messaging
2. Send test message
3. Notification gelmeldi

---

## Sorun Çözme

### "google-services.json not found"
- Dosya `android/app/` klasöründe olmalı
- Android Studio'yu yeniden başlat

### "Plugin 'com.google.gms.google-services' not found"
- `android/build.gradle.kts` kontrol et
- `buildscript` bölümüne `google-services` plugini ekle

### iOS Pod Hatası
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..
```

### SHA-1 Fingerprint Hatası
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (production)
keytool -list -v -keystore ~/key.jks -alias key
```

---

## Güvenlik Notları

⚠️ **ASLA** `google-services.json` veya API key'lerini GitHub'a commit etmeyin!

### .gitignore Güncellemesi
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
.env
.env.local
```

---

## Üretim Hazırlığı

1. Release keystore oluştur
2. SHA-1 fingerprint'i Firebase'e ekle
3. Production Firebase rules ayarla
4. Email verification etkinleştir
5. Password reset policy kur

---

## Kaynaklar
- [Firebase Documentation](https://firebase.flutter.dev/)
- [Android Setup](https://firebase.google.com/docs/android/setup)
- [iOS Setup](https://firebase.google.com/docs/ios/setup)
