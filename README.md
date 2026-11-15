# Dijital Kartvizit

Telefonunu kartvizite çeviren bir Android uygulaması. Paylaşmak istediğin bilgileri (rehbere ekle, Instagram, GitHub, WhatsApp, konum...) seçersin. Karşı taraf bunları QR kodunu okutarak ya da telefonunu seninkine dokundurarak (NFC) alır. Sunucu ya da internet bağlantısı gerekmez.

**[APK'yı indir (v1.0.0)](https://github.com/Quadrrax/dijital-kartvizit/releases/tag/v1.0.0)**

## Özellikler

- **Birden fazla kart:** örneğin "Kişisel" ve "İş" kartı. Üstteki sekmelerden kartlar arasında geçiş yapılır.
- **Bir platformda birden fazla hesap:** iki Instagram hesabını ayrı ayrı ekleyip etiketleyebilirsin (ör. "İş").
- **Desteklenen bilgiler:** ad soyad, unvan, şirket, telefon, e-posta, adres/harita, profil fotoğrafı, WhatsApp, Instagram, GitHub, LinkedIn, X ve web sitesi.
- **Tek seçim:** seçilen kartın linki gönderilir. Karşı telefonda uygulama yüklüyse (Instagram, GitHub vb.) profil doğrudan o uygulamada açılır.
- **Çoklu seçim:** seçilen her şey tek bir kişi kartında (vCard) gider. Karşı taraf tek dokunuşla rehberine ekler.
- **QR kod:** her telefon kamerasıyla okunur.
- **NFC:** telefonun kendisi bir NFC kartı gibi davranır (Host Card Emulation). Yayın yalnızca Paylaş ekranı açıkken yapılır.
- **Dil:** telefonun dili Türkçeyse arayüz Türkçe, değilse İngilizce olur.
- Tüm veriler sadece telefonda saklanır.

## Kurulum

1. [Releases](https://github.com/Quadrrax/dijital-kartvizit/releases) sayfasından `kartvizit-v1.0.0.apk` dosyasını telefona indir.
2. Dosyayı aç. Telefon "bilinmeyen kaynaklardan yükleme" izni isterse ver.
3. NFC ile paylaşmak için telefonda NFC ve HCE desteği olmalı. Yoksa QR kod her zaman çalışır.

## Kaynaktan derleme

Gerekenler: Flutter 3.47+ (Dart 3.13+), Android SDK ve JDK 17 ya da üstü.

```bash
flutter pub get
flutter test                  # Dart birim ve widget testleri
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

APK'yı küçültmek için `flutter build apk --release --split-per-abi` komutuyla her işlemci mimarisi için ayrı APK üretebilirsin.

Kotlin (NFC) testleri:

```bash
cd android && ./gradlew :app:testDebugUnitTest
```

## Proje yapısı

```
lib/
  models/profile.dart        Kart ve hesap modeli
  data/profile_store.dart    Telefonda saklama (shared_preferences + fotoğraflar)
  sharing/                   Link, vCard, NDEF kodlama ve NFC köprüsü
  ui/                        Ana ekran, düzenleme ekranı, paylaş ekranı, tema
  l10n/                      Türkçe ve İngilizce metinler
android/app/src/main/kotlin/.../
  Type4Tag.kt                NFC Forum Type 4 etiket mantığı (APDU)
  HceSession.kt              Paylaşım ve uygulamanın ön planda olma durumu
  NdefHceService.kt          Android HostApduService
  MainActivity.kt            Flutter ile köprü ('kartvizit/hce' kanalı)
```

## Bilinen sınırlamalar

- iPhone'ların bu NFC yayınını okuyup okuyamaması modele ve iOS sürümüne bağlı. QR kod her durumda çalışır.
- Profil fotoğrafı QR koda ve NFC yayınına eklenmez, sadece uygulamada görünür.
