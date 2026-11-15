# Dijital Kartvizit (Android APK) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Telefonda çalışan bir kartvizit APK'sı. Kullanıcı kartlarından (Rehbere ekle, Instagram, GitHub...) birini ya da birkaçını seçer ve QR kod ya da NFC (telefonlar birbirine dokundurularak) ile paylaşır.

**Architecture:** Flutter (yalnızca Android). Paylaşım mantığı saf Dart'tır ve TDD ile yazılır: profil → seçilen öğeler → `SharePayload` (URL veya vCard) → QR metni / NDEF baytları. NFC için telefon, bir NFC Forum Type 4 etiketini taklit eder (HCE). Bunu küçük bir Kotlin `HostApduService` yapar; APDU mantığı saf Kotlin sınıfındadır ve JUnit ile test edilir. Dart tarafı NDEF baytlarını `MethodChannel` ile servise verir.

**Tech Stack:** Flutter 3.47.7 / Dart 3.13.5, Kotlin, qr_flutter, shared_preferences, image_picker, path_provider, font_awesome_flutter, flutter_localizations + intl (gen-l10n), JUnit 4.

**Spec:** Bu belgedeki "Gereksinimler" bölümü (kullanıcıyla yapılan soru-cevap, 2026-11-15). Uygulamaya başlarken bu plan `docs/superpowers/plans/2026-11-15-dijital-kartvizit.md` olarak projeye kopyalanır (Task 1).

## Context

Kullanıcı, telefonunda taşıyacağı dijital bir kartvizit istiyor. Proje klasörü (`/home/ekremk/Projects/Dijital Kartvizit`) boş ve git deposu değil. Makinede Flutter 3.47.7 (`~/development/flutter`, PATH'te yok), Android SDK 36 ve JDK 21 (`~/development/jdk`) kurulu. Şu an bağlı bir Android telefon yok; NFC testi için fiziksel bir telefon gerekiyor (emülatör HCE desteklemez).

## Gereksinimler (soru-cevaptan)

- **Biçim:** Android APK. İçinde Instagram, Rehbere ekle, GitHub gibi kartlar var. Kullanıcı istediği tek kartı ya da birkaçını seçip **QR** veya **NFC** ile paylaşır.
- **İçerik:** ad soyad, unvan, şirket, telefon, e-posta, profil fotoğrafı, web sitesi, Instagram, GitHub, LinkedIn, X, WhatsApp, adres/harita.
- **Tek seçim:** URL kartı seçilirse (Instagram vb.) o link gider. "Rehbere ekle" seçilirse kişi kartı (vCard) gider.
- **Çoklu seçim:** seçilenlerin hepsini içeren **tek bir kişi kartı (vCard)** gider. Hosting ya da internet gerekmez.
- **NFC:** telefon NFC kartı gibi davranır (HCE). Kart, karşı telefona dokundurularak okutulur.
- **Veri girişi:** uygulama içinde "Profili düzenle" ekranı. Veriler telefonda saklanır, boş bırakılan alanlar kartta görünmez.
- **Stil:** renkli gradyan arka plan ve cam efektli kartlar.
- **Dil:** telefon dili Türkçeyse Türkçe, değilse İngilizce.
- **Yayın:** sunucu ya da hosting yok. Çıktı sadece APK dosyası.

## Global Constraints

- Flutter komutları: `export PATH="$HOME/development/flutter/bin:$PATH"` (flutter PATH'te değil). Gradle için `JAVA_HOME=$HOME/development/jdk`.
- Proje kökü = çalışma dizini. `flutter create --org dev.kartvizit --project-name dijital_kartvizit --platforms android .` ile oluşturulur. applicationId `dev.kartvizit.dijital_kartvizit`, Kotlin paketi `dev.kartvizit.dijital_kartvizit`, cihazda görünen ad `Kartvizit`.
- Bağımlılıklar yalnızca şunlar: `qr_flutter`, `shared_preferences`, `image_picker`, `path_provider`, `font_awesome_flutter`, `flutter_localizations` (sdk), `intl`. HCE için paket kullanılmaz, native Kotlin yazılır.
- Gradyan: `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4F46E5), Color(0xFFDB2777), Color(0xFFF59E0B)])`. Cam kart: beyaz %18 dolgu, `BackdropFilter` blur sigma 20, 1px beyaz %30 kenarlık, köşe yarıçapı 24. Metinler beyaz.
- `supportedLocales: const [Locale('en'), Locale('tr')]` (sıra önemli: eşleşme yoksa ilk dil seçilir, o da İngilizce).
- Profil fotoğrafı vCard'a, QR'a ya da NFC'ye **girmez**, sadece uygulamada görünür.
- vCard sürümü 3.0, satır sonu `\r\n`, UTF-8.
- NFC yalnızca Paylaş ekranı açıkken yayın yapar.
- Her task sonunda `flutter analyze` sorunsuz ve `flutter test` yeşil olmalı.
- Commit mesajları `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` satırıyla biter.

## Review Focus

1. **Türkçe karakterler (ş, ğ, ı, İ):** NDEF kayıt uzunluğu `String.length` ile değil UTF-8 bayt sayısıyla hesaplanmalı, isim karşı telefonda bozulmadan görünmeli. Bunu Task 4'teki `turkish chars use utf8 byte length` testi kontrol eder.
2. **255 bayttan uzun vCard (tüm alanlar dolu):** NDEF "long record" (4 baytlık uzunluk) kullanılmalı. HCE, okuyucu 59'ar bayt istediğinde dosyayı doğru parçalar halinde vermeli. Bunu Task 4'teki `long vcard uses 4-byte length` ve Task 5'teki `readNdef_inChunks_concatenatesToMessage` testleri kontrol eder.
3. **Kullanıcı adı ve telefonun farklı biçimlerde girilmesi** (`@ali`, ` ali `, `ali/`, tam URL, `0532 123 45 67`, `+90 532 123 45 67`, `5321234567`): hepsi doğru linke dönüşmeli. Bunu Task 2'deki `urlFor` testleri kontrol eder.
4. **NFC kapalıyken Paylaş ekranının açılması:** ekranda "NFC kapalı" yazısı ve ayarlar butonu görünmeli. Kullanıcı ayarlardan geri dönünce durum kendiliğinden "hazır" olmalı. Bunu Task 8'deki `refreshes nfc status on resume` testi kontrol eder.
5. **Paylaş ekranından çıkınca NFC yayınının durması**, ve uygulama kapalıyken sistem servisi tek başına başlatırsa servisin hiçbir veri vermemesi (yanlışlıkla paylaşım olmamalı). Bunu Task 8'deki `stops hce on dispose` ve Task 5'teki `selectApp_withoutMessage_returnsNotFound` testleri kontrol eder.

---

## Dosya Yapısı

```
lib/
  main.dart                      # ProfileStore.open() + runApp
  app.dart                       # KartvizitApp: MaterialApp, l10n, tema
  models/profile.dart            # Profile (değer nesnesi, JSON)
  data/profile_store.dart        # shared_preferences + fotoğraf kopyalama
  sharing/share_item.dart        # ShareItem enum, availableItems, urlFor
  sharing/vcard.dart             # buildVCard
  sharing/payload.dart           # SharePayload, buildPayload
  sharing/ndef.dart              # encodeNdef
  sharing/hce_channel.dart       # HceChannel (MethodChannel), NfcStatus
  ui/style.dart                  # kGradient, GradientScaffold, GlassCard
  ui/item_visuals.dart           # itemIcon, itemLabel
  ui/home_screen.dart
  ui/edit_profile_screen.dart
  ui/share_screen.dart
  l10n/app_en.arb, app_tr.arb    # + l10n.yaml (kökte)
android/app/src/main/kotlin/dev/kartvizit/dijital_kartvizit/
  Type4Tag.kt                    # saf APDU mantığı + HceState
  NdefHceService.kt              # HostApduService → Type4Tag
  MainActivity.kt                # MethodChannel 'kartvizit/hce'
android/app/src/main/res/xml/apduservice.xml
android/app/src/main/res/values/strings.xml
android/app/src/test/kotlin/dev/kartvizit/dijital_kartvizit/Type4TagTest.kt
test/ (lib yapısını yansıtır)
```

---

### Task 1: Proje iskeleti + Profile modeli + ProfileStore

**Files:**
- Create: Flutter projesi (`flutter create ...`, Global Constraints'e bakın), `.gitignore` (flutter create üretir), `docs/superpowers/plans/2026-11-15-dijital-kartvizit.md` (bu planın kopyası)
- Delete: `test/widget_test.dart` (şablondaki sayaç testi)
- Create: `lib/models/profile.dart`, `lib/data/profile_store.dart`
- Test: `test/models/profile_test.dart`, `test/data/profile_store_test.dart`

**Interfaces:**
- Produces:
  - `class Profile { final String fullName, title, company, phone, email, website, instagram, github, linkedin, x, address; final String? photoPath; const Profile({...hepsi '' varsayılan, photoPath null}); static const empty = Profile(); Profile copyWith({...}); Map<String, dynamic> toJson(); factory Profile.fromJson(Map<String, dynamic> json); }`. `fromJson` eksik anahtarları `''`/`null` sayar. JSON anahtarları alan adlarıyla aynıdır.
  - `class ProfileStore { ProfileStore(SharedPreferences prefs, Directory photoDir); static Future<ProfileStore> open(); Profile load(); Future<void> save(Profile p); Future<String> importPhoto(String sourcePath); }`. Profil, prefs'teki `'profile'` anahtarında JSON string olarak durur. `open()`, `SharedPreferences.getInstance()` ile `getApplicationDocumentsDirectory()` kullanır.

- [ ] **Step 1: Projeyi kur.** `git init` çalıştır, ardından `flutter create` (Global Constraints'teki komut). Sonra `flutter pub add qr_flutter shared_preferences image_picker path_provider font_awesome_flutter intl` ve `flutter pub add flutter_localizations --sdk=flutter` çalıştır. `test/widget_test.dart`'ı sil ve planı `docs/superpowers/plans/` altına kopyala.

- [ ] **Step 2: Failing testleri yaz**

```dart
// test/models/profile_test.dart
test('json roundtrip keeps every field', () {
  const p = Profile(fullName: 'Ali Veli', title: 'Dev', company: 'Acme', phone: '0532', email: 'a@b.c',
      website: 'a.dev', instagram: 'ali', github: 'ali', linkedin: 'ali', x: 'ali', address: 'Kadıköy', photoPath: '/p.jpg');
  expect(Profile.fromJson(p.toJson()).toJson(), p.toJson());
});
test('fromJson with missing keys gives empty strings', () {
  final p = Profile.fromJson({});
  expect(p.fullName, ''); expect(p.instagram, ''); expect(p.photoPath, isNull);
});

// test/data/profile_store_test.dart  (SharedPreferences.setMockInitialValues + Directory.systemTemp.createTemp)
test('load returns empty profile when nothing saved', ...);          // load().fullName == ''
test('save then load returns same profile', ...);                     // toJson eşit
test('corrupt json returns empty profile instead of throwing', ...);  // prefs {'profile': '{bozuk'} → load().fullName == ''
test('importPhoto copies file and deletes previous photo', ...);
// 1. import: dönen yol photoDir içinde, adı 'profile_' ile başlar, baytlar kaynakla aynı.
// 2. import: yeni dosya var, ilk dosya artık yok.
```

- [ ] **Step 3: Çalıştır, fail ettiğini gör.** `flutter test test/models test/data` → derleme hatası beklenir (`Profile`/`ProfileStore` tanımsız).

- [ ] **Step 4: `Profile` ve `ProfileStore`'u yaz.** `load()` içinde JSON çözme hatası (`FormatException`, `TypeError`) yakalanır ve `Profile.empty` döner. `importPhoto` hedef dosyayı `photoDir/profile_<millisecondsSinceEpoch><uzantı>` olarak adlandırır, ardından photoDir'deki diğer `profile_*` dosyalarını siler. Ad her seferinde değiştiği için Flutter'ın görsel önbelleği eski fotoğrafı göstermez.

- [ ] **Step 5: Çalıştır, geçtiğini gör.** `flutter test test/models test/data && flutter analyze` → tüm testler PASS, analyze `No issues found!`

- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat: scaffold app with profile model and local store"`

---

### Task 2: Paylaşım öğeleri ve link üretimi

**Files:**
- Create: `lib/sharing/share_item.dart`
- Test: `test/sharing/share_item_test.dart`

**Interfaces:**
- Consumes: `Profile` (Task 1)
- Produces:
  - `enum ShareItem { contact, whatsapp, instagram, github, linkedin, x, website, location }`. Enum sırası hem ekrandaki hem vCard'daki sıradır.
  - `List<ShareItem> availableItems(Profile p)`: enum sırasıyla, kaynak alanı boş olmayan (`trim()` sonrası) öğeler. Kaynaklar: contact←fullName, whatsapp←phone, instagram←instagram, github←github, linkedin←linkedin, x←x, website←website, location←address.
  - `String urlFor(ShareItem item, Profile p)`: `contact` için `ArgumentError` fırlatır.

Link kuralları:
- Kullanıcı adları (instagram/github/linkedin/x): önce `trim()`. Değer `http://` ya da `https://` ile başlıyorsa olduğu gibi döner. Yoksa baştaki `@` ve sondaki `/` atılır, sonra şablona yerleştirilir: `https://instagram.com/<h>`, `https://github.com/<h>`, `https://www.linkedin.com/in/<h>`, `https://x.com/<h>`.
- website: `trim()`. Şema yoksa başına `https://` eklenir.
- whatsapp: `https://wa.me/<d>`. `d` telefonun sadece rakamlarıdır: `00` ile başlıyorsa `00` atılır. Yoksa `0` ile başlıyorsa `90` + kalan. Yoksa 10 hane ve `5` ile başlıyorsa `90` + rakamlar. Bunların hiçbiri değilse rakamlar olduğu gibi kalır.
- location: `https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}`

- [ ] **Step 1: Failing testleri yaz**

```dart
test('availableItems lists only filled fields in enum order', () {
  expect(availableItems(const Profile(fullName: 'Ali', github: 'ali', instagram: ' ')),
      [ShareItem.contact, ShareItem.github]);
});
test('handles are normalized', () {
  for (final raw in ['ali', '@ali', ' ali ', 'ali/']) {
    expect(urlFor(ShareItem.instagram, Profile(instagram: raw)), 'https://instagram.com/ali');
  }
  expect(urlFor(ShareItem.github, const Profile(github: 'https://github.com/ali')), 'https://github.com/ali');
  expect(urlFor(ShareItem.linkedin, const Profile(linkedin: 'ali')), 'https://www.linkedin.com/in/ali');
  expect(urlFor(ShareItem.x, const Profile(x: '@ali')), 'https://x.com/ali');
});
test('website gets https when scheme missing', () {
  expect(urlFor(ShareItem.website, const Profile(website: 'ali.dev')), 'https://ali.dev');
  expect(urlFor(ShareItem.website, const Profile(website: 'http://ali.dev')), 'http://ali.dev');
});
test('whatsapp phone formats', () {
  for (final raw in ['0532 123 45 67', '+90 532 123 45 67', '5321234567', '0090 532 123 45 67']) {
    expect(urlFor(ShareItem.whatsapp, Profile(phone: raw)), 'https://wa.me/905321234567');
  }
});
test('location url encodes turkish address', () {
  expect(urlFor(ShareItem.location, const Profile(address: 'Kadıköy İstanbul')),
      'https://www.google.com/maps/search/?api=1&query=Kad%C4%B1k%C3%B6y%20%C4%B0stanbul');
});
test('contact has no url', () {
  expect(() => urlFor(ShareItem.contact, const Profile(fullName: 'A')), throwsArgumentError);
});
```

- [ ] **Step 2: Çalıştır, fail ettiğini gör.** `flutter test test/sharing/share_item_test.dart` → derleme hatası
- [ ] **Step 3: `share_item.dart`'ı yukarıdaki kurallarla yaz**
- [ ] **Step 4: Çalıştır, geçtiğini gör.** Aynı komut → PASS, ardından `flutter analyze` temiz
- [ ] **Step 5: Commit** — `feat: share items and link builders`

---

### Task 3: vCard üretimi ve payload seçimi

**Files:**
- Create: `lib/sharing/vcard.dart`, `lib/sharing/payload.dart`
- Test: `test/sharing/vcard_test.dart`, `test/sharing/payload_test.dart`

**Interfaces:**
- Consumes: `Profile`, `ShareItem`, `urlFor` (Task 1–2)
- Produces:
  - `String buildVCard(Profile p, Set<ShareItem> items)`
  - `sealed class SharePayload { String get qrText; }`, `final class UriPayload extends SharePayload { final String uri; }`, `final class VCardPayload extends SharePayload { final String vcard; }`. `qrText`, uri'yi ya da vcard'ı döner.
  - `SharePayload buildPayload(Profile p, Set<ShareItem> selected)`: `selected` boş olamaz (assert). Tek öğe seçilmişse ve o öğe `contact` değilse `UriPayload(urlFor(...))` döner. Diğer her durumda `VCardPayload(buildVCard(p, selected))` döner.

vCard satırları (sırayla, aralarında `\r\n`, en sonda `END:VCARD\r\n`):
```
BEGIN:VCARD
VERSION:3.0
N:<soyad>;<ad>;;;            ← fullName trim edilip boşluklardan bölünür: son kelime soyad, kalanlar ad. Tek kelimeyse N:;<kelime>;;;
FN:<fullName>
ORG:<company>                ← yalnızca contact seçiliyse ve alan doluysa
TITLE:<title>                ← aynı koşul
TEL;TYPE=CELL:<phone>        ← aynı koşul
EMAIL;TYPE=INTERNET:<email>  ← aynı koşul
ADR;TYPE=WORK:;;<address>;;;;  ← yalnızca location seçiliyse
URL:<urlFor(item)>           ← seçili her URL öğesi için (whatsapp, instagram, github, linkedin, x, website) enum sırasıyla
END:VCARD
```
Metin değerlerinde (N parçaları, FN, ORG, TITLE, ADR) kaçış: `\` → `\\`, `,` → `\,`, `;` → `\;`, satır sonu → `\n`. URL satırlarında kaçış yapılmaz.

- [ ] **Step 1: Failing testleri yaz**

```dart
const full = Profile(fullName: 'Ahmet Ekrem Koç', title: 'Mühendis', company: 'Koç, A.Ş.; Ltd',
    phone: '0532 123 45 67', email: 'a@b.c', instagram: 'ali', github: 'ali', address: 'Kadıköy');

test('contact only', () {
  expect(buildVCard(full, {ShareItem.contact}),
      'BEGIN:VCARD\r\nVERSION:3.0\r\nN:Koç;Ahmet Ekrem;;;\r\nFN:Ahmet Ekrem Koç\r\n'
      'ORG:Koç\\, A.Ş.\\; Ltd\r\nTITLE:Mühendis\r\nTEL;TYPE=CELL:0532 123 45 67\r\n'
      'EMAIL;TYPE=INTERNET:a@b.c\r\nEND:VCARD\r\n');
});
test('urls only: name kept, contact fields omitted, enum order', () {
  final v = buildVCard(full, {ShareItem.github, ShareItem.instagram});
  expect(v, contains('FN:Ahmet Ekrem Koç\r\nURL:https://instagram.com/ali\r\nURL:https://github.com/ali\r\nEND:VCARD'));
  expect(v, isNot(contains('TEL')));
});
test('location adds ADR', () {
  expect(buildVCard(full, {ShareItem.location}), contains('ADR;TYPE=WORK:;;Kadıköy;;;;\r\n'));
});
test('single-word name', () {
  expect(buildVCard(const Profile(fullName: 'Ahmet'), {ShareItem.contact}), contains('N:;Ahmet;;;\r\n'));
});

// payload_test.dart
test('single url item gives UriPayload', () {
  final p = buildPayload(full, {ShareItem.github});
  expect(p, isA<UriPayload>()); expect(p.qrText, 'https://github.com/ali');
});
test('contact alone gives VCardPayload', () => expect(buildPayload(full, {ShareItem.contact}), isA<VCardPayload>()));
test('multiple items give VCardPayload', () => expect(buildPayload(full, {ShareItem.github, ShareItem.instagram}), isA<VCardPayload>()));
```

- [ ] **Step 2: Çalıştır, fail ettiğini gör.** `flutter test test/sharing/vcard_test.dart test/sharing/payload_test.dart`
- [ ] **Step 3: `buildVCard`, `SharePayload` ve `buildPayload`'ı yaz**
- [ ] **Step 4: Çalıştır, geçtiğini gör.** → PASS, `flutter analyze` temiz
- [ ] **Step 5: Commit** — `feat: vcard builder and share payload`

---

### Task 4: NDEF kodlayıcı

**Files:**
- Create: `lib/sharing/ndef.dart`
- Test: `test/sharing/ndef_test.dart`

**Interfaces:**
- Consumes: `SharePayload`, `UriPayload`, `VCardPayload` (Task 3)
- Produces: `Uint8List encodeNdef(SharePayload payload)`. Tek kayıtlı bir NDEF mesajı üretir.

Kodlama:
- **Başlık baytı:** `0x80` (MB) | `0x40` (ME) | payload < 256 bayt ise `0x10` (SR) | TNF. TNF, URI için `0x01`, vCard için `0x02` (MIME). Ardından sırayla: tip uzunluğu (1 bayt), payload uzunluğu (SR ise 1 bayt, değilse 4 bayt big-endian), tip baytları, payload.
- **URI kaydı:** tip `'U'` (0x55). Payload = önek kodu + kalan metnin UTF-8 baytları. Önekler sırayla denenir (en uzun önce): `https://www.`→0x02, `http://www.`→0x01, `https://`→0x04, `http://`→0x03, `tel:`→0x05, `mailto:`→0x06, hiçbiri değilse 0x00 (metin olduğu gibi).
- **vCard kaydı:** tip `'text/vcard'` (ASCII, 10 bayt). Payload = vCard'ın UTF-8 baytları.

- [ ] **Step 1: Failing testleri yaz**

```dart
test('uri record with https prefix', () {
  expect(encodeNdef(UriPayload('https://github.com/ali')),
      [0xD1, 0x01, 15, 0x55, 0x04, ...utf8.encode('github.com/ali')]);
});
test('uri record prefers https://www.', () {
  final b = encodeNdef(UriPayload('https://www.linkedin.com/in/ali'));
  expect(b[4], 0x02); expect(b.sublist(5), utf8.encode('linkedin.com/in/ali'));
});
test('turkish chars use utf8 byte length', () {
  const v = 'BEGIN:VCARD\r\nFN:Şükrü Ağaoğlu\r\nEND:VCARD\r\n';
  final b = encodeNdef(VCardPayload(v));
  expect(b[0], 0xD2); expect(b[1], 10);
  expect(b[2], utf8.encode(v).length); expect(b[2], isNot(v.length));
  expect(b.sublist(3, 13), ascii.encode('text/vcard'));
  expect(utf8.decode(b.sublist(13)), v);
});
test('long vcard uses 4-byte length', () {
  final v = 'X' * 300;
  final b = encodeNdef(VCardPayload(v));
  expect(b[0], 0xC2); expect(b.sublist(2, 6), [0, 0, 0x01, 0x2C]);
  expect(b.length, 1 + 1 + 4 + 10 + 300);
});
```

- [ ] **Step 2: Çalıştır, fail ettiğini gör.** `flutter test test/sharing/ndef_test.dart`
- [ ] **Step 3: `encodeNdef`'i yaz**
- [ ] **Step 4: Çalıştır, geçtiğini gör.** → PASS, `flutter analyze` temiz
- [ ] **Step 5: Commit** — `feat: ndef message encoder`

---

### Task 5: Android HCE (telefonu NFC Type 4 etiketi gibi davrandırma) ve Dart köprüsü

**Files:**
- Create: `android/app/src/main/kotlin/dev/kartvizit/dijital_kartvizit/Type4Tag.kt`, `NdefHceService.kt`, `android/app/src/main/res/xml/apduservice.xml`, `android/app/src/main/res/values/strings.xml`, `lib/sharing/hce_channel.dart`
- Modify: `android/app/src/main/kotlin/dev/kartvizit/dijital_kartvizit/MainActivity.kt`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts` (`dependencies { testImplementation("junit:junit:4.13.2") }`)
- Test: `android/app/src/test/kotlin/dev/kartvizit/dijital_kartvizit/Type4TagTest.kt`, `test/sharing/hce_channel_test.dart`

**Interfaces:**
- Consumes: Task 4'ün ürettiği NDEF baytları (Dart tarafında `encodeNdef` çıktısı)
- Produces:
  - Kotlin: `class Type4Tag { @Volatile var ndefMessage: ByteArray?; fun process(apdu: ByteArray): ByteArray; fun reset() }` ve `object HceState { val tag = Type4Tag() }`
  - Dart: `enum NfcStatus { unsupported, disabled, ready }`, `class HceChannel { const HceChannel([MethodChannel channel = const MethodChannel('kartvizit/hce')]); Future<NfcStatus> status(); Future<void> start(Uint8List ndefMessage); Future<void> stop(); Future<void> openNfcSettings(); }`
  - Kanal metodları: `status` → `'unsupported' | 'disabled' | 'ready'` string döner. `start` argümanı `Uint8List` (Kotlin'de `ByteArray`). `stop` ve `openNfcSettings` argümansızdır.

APDU sabitleri (`Type4Tag`):
- `SELECT` ilk 12 baytı `00A4040007D2760000850101` ise (Le baytı olsa da olmasa da): `ndefMessage == null` ise `6A82`, değilse `9000` döner.
- `00A4000C02E103` CC dosyasını seçer, `00A4000C02E104` NDEF dosyasını seçer. İkisi de `9000` döner. Uygulama seçilmeden gelirlerse `6A82` döner.
- READ BINARY (`00 B0 P1 P2 Le`): offset = `(P1 shl 8) or P2`, Le = 0 ise 256. Dönen veri seçili dosyanın `[offset, min(offset+Le, size))` aralığı + `9000`. Dosya seçili değilse `6A82`.
- CC dosyası (15 bayt): `000F20003B00340406E1047FFF00FF`
- NDEF dosyası: 2 bayt big-endian NLEN + `ndefMessage`
- Bilinmeyen her komut `6A82` döner. `reset()` seçili uygulamayı ve dosyayı unutur.

Android tarafı:
- `NdefHceService : HostApduService`: `processCommandApdu` → `HceState.tag.process(apdu)`, `onDeactivated` → `HceState.tag.reset()`.
- `apduservice.xml`: `<host-apdu-service android:requireDeviceUnlock="false" android:description="@string/hce_description">` içinde `<aid-group android:category="other">` ve `<aid-filter android:name="D2760000850101"/>`. `strings.xml`: `hce_description` = `Kartvizit NFC`.
- Manifest: `uses-permission android.permission.NFC`, `uses-feature android.hardware.nfc.hce required=false`, `android:label="Kartvizit"`. Servis `exported=true`, `permission=android.permission.BIND_NFC_SERVICE`, intent-filter `android.nfc.cardemulation.action.HOST_APDU_SERVICE`, meta-data `android.nfc.cardemulation.host_apdu_service` → `@xml/apduservice`.
- `MainActivity` (`FlutterActivity`) kanal metodları:
  - `status`: NfcAdapter yoksa ya da `FEATURE_NFC_HOST_CARD_EMULATION` yoksa `unsupported`. `!isEnabled` ise `disabled`. Değilse `ready`.
  - `start`: `HceState.tag.ndefMessage = bytes`, ardından `CardEmulation.setPreferredService(this, ComponentName(this, NdefHceService::class.java))`.
  - `stop`: `ndefMessage = null`, `unsetPreferredService(this)`.
  - `openNfcSettings`: `Settings.ACTION_NFC_SETTINGS` açılır.
  - `onResume`: mesaj doluysa preferred service tekrar ayarlanır. `onPause`: preferred service kaldırılır (Android, bu ayarın onResume/onPause'da yapılmasını istiyor).

- [ ] **Step 1: Failing Kotlin testlerini yaz** (`hex(String): ByteArray` yardımcısıyla)
  - `selectApp_withoutMessage_returnsNotFound`: mesaj null iken `process(hex("00A4040007D276000085010100"))` → `6A82`
  - `fullReadSequence_returnsCcAndNdef`: uygulama seçimi → `9000`. CC seçimi → `9000`. `00B000000F` → CC + `9000`. NDEF seçimi → `9000`. `00B0000002` → NLEN + `9000`. `00B00002<len>` → mesaj + `9000`.
  - `readNdef_inChunks_concatenatesToMessage`: 300 baytlık mesaj, offset 2'den başlayıp 59'ar bayt okunur. Birleşen parçalar mesaja eşit olmalı.
  - `readPastEnd_clampsToFileEnd`: dosya sonunu aşan Le ile okuma yalnızca kalan baytları + `9000` döner.
  - `readBeforeSelect_returnsNotFound`, `reset_forgetsSelectedFile`: ikisi de `6A82` döner.

- [ ] **Step 2: Çalıştır, fail ettiğini gör.** `cd android && JAVA_HOME=$HOME/development/jdk ./gradlew :app:testDebugUnitTest --tests '*Type4TagTest*'` → derleme hatası (`Type4Tag` yok). `android/gradlew` yoksa önce kökte `flutter build apk --debug` çalıştır.
- [ ] **Step 3: `Type4Tag.kt`'yi yaz**
- [ ] **Step 4: Çalıştır, geçtiğini gör.** Aynı komut → `BUILD SUCCESSFUL`, 6 test PASS
- [ ] **Step 5: Dart kanal testini yaz** (`TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler`)
  - `status maps strings to NfcStatus`: mock `'disabled'` döner → `NfcStatus.disabled`
  - `start sends ndef bytes`: kaydedilen çağrı `method == 'start'` ve `arguments` verilen `Uint8List`'e eşit
  - `stop invokes stop`
- [ ] **Step 6: Çalıştır, fail ettiğini gör, sonra `hce_channel.dart`, `NdefHceService.kt`, `MainActivity.kt`, manifest ve xml dosyalarını yaz.** `flutter test test/sharing/hce_channel_test.dart` → PASS. `flutter build apk --debug` → derleme başarılı.
- [ ] **Step 7: Commit** — `feat: android hce type 4 tag service and dart channel`

---

### Task 6: Yerelleştirme, tema ve ana ekran (öğe seçimi)

**Files:**
- Create: `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`, `lib/app.dart`, `lib/ui/style.dart`, `lib/ui/item_visuals.dart`, `lib/ui/home_screen.dart`
- Modify: `lib/main.dart`, `pubspec.yaml` (`flutter: generate: true`)
- Test: `test/ui/home_screen_test.dart`, `test/helpers.dart`

**Interfaces:**
- Consumes: `ProfileStore`, `Profile`, `ShareItem`, `availableItems`, `buildPayload`
- Produces:
  - `test/helpers.dart`: `Widget wrapTr(Widget child)`. Child'ı `MaterialApp(locale: Locale('tr'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: child)` içine sarar. Ayrıca `Future<ProfileStore> testStore([Profile? p])` (mock prefs + geçici dizin). Task 7 ve 8'in widget testleri de bunları kullanır. Not: `flutter test` varsayılan olarak `en_US`'dur. `KartvizitApp` ile Türkçe metin bekleyen testlerde `tester.platformDispatcher.localesTestValue = [Locale('tr')]` ayarlanır.
  - `class KartvizitApp extends StatelessWidget { const KartvizitApp({required ProfileStore store}); }`
  - `const kGradient`, `class GradientScaffold` (Scaffold ile aynı `appBar`/`body`/`bottomNavigationBar` parametreleri, arkada gradyan), `class GlassCard({required Widget child, EdgeInsets padding})`
  - `IconData itemIcon(ShareItem)` (FontAwesome ikonları: addressCard, whatsapp, instagram, github, linkedin, xTwitter, globe, locationDot), `String itemLabel(ShareItem, AppLocalizations)`
  - `class HomeScreen extends StatefulWidget { const HomeScreen({required ProfileStore store}); }`
  - Üretilen import: `package:dijital_kartvizit/l10n/app_localizations.dart`
- `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`

ARB anahtarları (en / tr). WhatsApp, Instagram, GitHub, LinkedIn ve X marka adı olduğu için çevrilmez:
`appTitle` Business Card / Kartvizit · `editProfile` Edit profile / Profili düzenle · `emptyProfile` Add your details to create your card / Kartını oluşturmak için bilgilerini ekle · `createProfile` Create profile / Profili oluştur · `shareCount` Share ({count}) / Paylaş ({count}) (`count`: int) · `itemContact` Add to contacts / Rehbere ekle · `itemWebsite` Website / Web sitesi · `itemLocation` Location / Konum · `fieldFullName` Full name / Ad soyad · `fieldTitle` Title / Unvan · `fieldCompany` Company / Şirket · `fieldPhone` Phone / Telefon · `fieldEmail` Email / E-posta · `fieldWebsite` Website / Web sitesi · `fieldInstagram` Instagram username / Instagram kullanıcı adı · `fieldGithub` GitHub username / GitHub kullanıcı adı · `fieldLinkedin` LinkedIn username / LinkedIn kullanıcı adı · `fieldX` X username / X kullanıcı adı · `fieldAddress` Address / Adres · `requiredField` Required / Zorunlu · `save` Save / Kaydet · `changePhoto` Change photo / Fotoğrafı değiştir · `shareTitle` Share / Paylaş · `scanHint` Scan the QR code with the camera / QR kodu kamerayla okut · `nfcReady` Hold the other phone to the back of yours / Diğer telefonu telefonunun arkasına yaklaştır · `nfcDisabled` NFC is off / NFC kapalı · `nfcOpenSettings` Turn on NFC / NFC'yi aç · `nfcUnsupported` This phone can't share over NFC, use the QR code / Bu telefon NFC ile paylaşamıyor, QR kodu kullan

HomeScreen davranışı:
- Profil `fullName` boşsa: ortada `emptyProfile` metni ve `createProfile` butonu görünür (buton düzenleme ekranını açar).
- Profil doluysa:
  - Üstte GlassCard: CircleAvatar (yarıçap 48, `photoPath` varsa `FileImage`, yoksa adın baş harfleri), ad, altında "unvan · şirket" (boş olanlar atlanır).
  - Altında 2 sütunlu ızgara: `availableItems` kutucukları. Dokunmak seçimi açıp kapatır. Seçili kutucuk beyaz dolguludur ve köşesinde onay işareti vardır.
  - En altta `shareCount` metinli FilledButton: seçim boşken devre dışı. Basılınca `ShareScreen(payload: buildPayload(profile, selected), items: <seçilenler enum sırasıyla>)` açılır.
- AppBar'daki düzenle ikonu (tooltip `editProfile`) EditProfileScreen'i açar. Dönüşte profil `store.load()` ile yeniden okunur ve artık mevcut olmayan seçimler düşürülür.
- Task 7 ve 8 bitene kadar düzenleme ve paylaşım butonları `Placeholder` ekranlarına gider. Gerçek ekranlar o task'larda bağlanır.

- [ ] **Step 1: Failing widget testlerini yaz** (`KartvizitApp(store: ...)` ile; store mock prefs ve geçici dizinle kurulur)
  - `empty profile shows create prompt`: TR yerelde `'Kartını oluşturmak için bilgilerini ekle'` görünür
  - `shows only filled items`: `Profile(fullName: 'Ali Veli', instagram: 'ali')` için `'Rehbere ekle'` ve `'Instagram'` görünür, `'GitHub'` görünmez
  - `selection toggles and updates share button`: başta `'Paylaş (0)'` ve buton devre dışı. İki kutucuğa dokununca `'Paylaş (2)'`, birine tekrar dokununca `'Paylaş (1)'`
  - `english fallback for non-turkish device`: `tester.platformDispatcher.localesTestValue = [Locale('de')]` iken `'Add to contacts'` ve `'Share (0)'` görünür
- [ ] **Step 2: Çalıştır, fail ettiğini gör.** `flutter test test/ui/home_screen_test.dart`
- [ ] **Step 3: l10n dosyalarını, `app.dart`, `style.dart`, `item_visuals.dart` ve `home_screen.dart`'ı yaz, `main.dart`'ı güncelle.** Görsel ayrıntılarda frontend-design becerisine başvurulabilir. Renk ve ölçüler Global Constraints'ten sapmamalı.
- [ ] **Step 4: Çalıştır, geçtiğini gör.** `flutter test && flutter analyze` → tüm testler PASS
- [ ] **Step 5: Commit** — `feat: localized home screen with item selection`

---

### Task 7: Profili düzenleme ekranı

**Files:**
- Create: `lib/ui/edit_profile_screen.dart`
- Modify: `lib/ui/home_screen.dart` (düzenleme yer tutucusunu gerçek ekranla değiştir)
- Test: `test/ui/edit_profile_screen_test.dart`

**Interfaces:**
- Consumes: `ProfileStore.save/importPhoto`, `Profile`, `GradientScaffold`, `GlassCard`, `AppLocalizations`
- Produces: `class EditProfileScreen extends StatefulWidget { const EditProfileScreen({required ProfileStore store, required Profile initial}); }`. Kaydedince `Navigator.pop(context, savedProfile)` ile döner.

Davranış:
- `Form` içinde her alan için bir `TextFormField` var. Anahtarlar: `Key('field_fullName')`, `Key('field_title')`, … `Key('field_address')`. Klavye tipleri: telefon → `phone`, e-posta → `emailAddress`, web sitesi → `url`.
- Yalnızca `fullName` zorunlu (trim sonrası boşsa `requiredField` hatası).
- Kaydet: doğrulama geçerse tüm değerler `trim()` edilip `store.save` çağrılır, sonra pop edilir.
- Üstteki avatar ya da `changePhoto` butonu: `ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85)` → `store.importPhoto(path)` → `photoPath` güncellenir. Galeri seçimi widget testinde değil, cihazda elle test edilir.

- [ ] **Step 1: Failing testleri yaz**
  - `empty name shows required error and does not save`: Kaydet'e basılır → `'Zorunlu'` görünür, `store.load().fullName == ''`
  - `saves trimmed values and pops`: `field_fullName`'e `'  Ali Veli '`, `field_instagram`'a `'@ali'` girilir, Kaydet'e basılır → `store.load().fullName == 'Ali Veli'`, `instagram == '@ali'` (normalizasyon `urlFor`'da yapılır), ekran kapanmış olur
  - `prefills initial profile`: `initial: Profile(fullName: 'Ali')` → alanda `'Ali'` görünür
- [ ] **Step 2: Çalıştır, fail ettiğini gör.** `flutter test test/ui/edit_profile_screen_test.dart`
- [ ] **Step 3: `EditProfileScreen`'i yaz ve HomeScreen'e bağla**
- [ ] **Step 4: Çalıştır, geçtiğini gör.** `flutter test && flutter analyze`
- [ ] **Step 5: Commit** — `feat: edit profile screen with photo picker`

---

### Task 8: Paylaş ekranı (QR + NFC)

**Files:**
- Create: `lib/ui/share_screen.dart`
- Modify: `lib/ui/home_screen.dart` (paylaşım yer tutucusunu gerçek ekranla değiştir)
- Test: `test/ui/share_screen_test.dart`

**Interfaces:**
- Consumes: `SharePayload`, `encodeNdef`, `HceChannel`, `NfcStatus`, `ShareItem`, `itemLabel`, `itemIcon`
- Produces: `class ShareScreen extends StatefulWidget { const ShareScreen({required SharePayload payload, required List<ShareItem> items, HceChannel hce = const HceChannel()}); }`

Davranış:
- `initState`: `hce.start(encodeNdef(payload))` çağrılır, sonra `hce.status()` okunur. Ayrıca `AppLifecycleListener(onResume: ...)` ile uygulama öne gelince status yeniden okunur.
- `dispose`: `hce.stop()` çağrılır ve dinleyici kapatılır.
- Arayüz, yukarıdan aşağıya:
  - Seçilen öğelerin etiketleri, ikonlu Chip'ler halinde.
  - Beyaz, köşeleri yuvarlatılmış bir kutu içinde `QrImageView(data: payload.qrText, size: 280, errorCorrectionLevel: QrErrorCorrectLevel.L)`. Beyaz zemin, gradyan üstünde okunabilirlik içindir.
  - `scanHint` metni.
  - NFC durumu: `ready` ise `nfcReady`. `disabled` ise `nfcDisabled` ve `openNfcSettings`'i çağıran `nfcOpenSettings` butonu. `unsupported` ise `nfcUnsupported`.

- [ ] **Step 1: Failing testleri yaz** (kanal mock'lanır, çağrılar listeye kaydedilir)
  - `renders qr for payload`: `find.byType(QrImageView)` bulunur
  - `starts hce with encoded payload`: `'start'` çağrısının argümanı `encodeNdef(UriPayload('https://github.com/ali'))`'ye eşit
  - `shows disabled state with settings button`: status `'disabled'` → `'NFC kapalı'` ve `"NFC'yi aç"` görünür. Butona basınca `'openNfcSettings'` çağrılır.
  - `refreshes nfc status on resume`: status önce `'disabled'`, sonra `'ready'` döner. `tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive)` ve ardından `(AppLifecycleState.resumed)` → pump → `'Diğer telefonu telefonunun arkasına yaklaştır'` görünür
  - `stops hce on dispose`: ekran ağaçtan kaldırılır (`pumpWidget(SizedBox())`) → çağrı listesinde `'stop'` var
- [ ] **Step 2: Çalıştır, fail ettiğini gör.** `flutter test test/ui/share_screen_test.dart`
- [ ] **Step 3: `ShareScreen`'i yaz ve HomeScreen'e bağla**
- [ ] **Step 4: Çalıştır, geçtiğini gör.** `flutter test && flutter analyze`
- [ ] **Step 5: Commit** — `feat: share screen with qr and nfc`

---

### Task 9: APK derleme ve cihazda doğrulama

**Files:** kod değişikliği beklenmez. Cihaz testinde çıkan hatalar systematic-debugging ile ilgili task'ın dosyasında düzeltilir ve testi eklenir.

- [ ] **Step 1: Release APK'yı derle.** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk` oluşur. Flutter şablonu release'i debug anahtarıyla imzalar; elle yüklemek için yeterli.
- [ ] **Step 2: Telefona kur.** Telefonda USB hata ayıklama açık ve kabloyla bağlıyken: `~/Android/Sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk`. Alternatif: APK'yı telefona kopyalayıp dosya yöneticisinden aç.
- [ ] **Step 3: Kullanıcıyla elle test et** (bağlı telefon gerekir; şu an bağlı cihaz yok)
  1. Profil oluştur, Türkçe karakterli bir ad gir, fotoğraf seç. Uygulamayı kapatıp aç: veriler ve fotoğraf yerinde olmalı.
  2. Tek seçim, Instagram: başka bir telefonun kamerasıyla QR okutulunca instagram.com/<kullanıcı> açılmalı.
  3. Tek seçim, Rehbere ekle: QR okutulunca kişi kaydetme ekranı açılmalı ve Türkçe karakterler düzgün görünmeli.
  4. Çoklu seçim (Rehbere ekle + GitHub + WhatsApp): kişi kartında telefon, e-posta ve iki URL görünmeli.
  5. NFC, karşı telefon Android: iki telefonu sırt sırta dokundur. Tek URL'de tarayıcı açılmalı, vCard'da kişi içe aktarılmalı.
  6. NFC kapalıyken Paylaş'ı aç: "NFC kapalı" yazmalı. "NFC'yi aç" ile ayarlara git, NFC'yi aç, geri dön: durum "hazır" olmalı.
  7. Paylaş ekranından çık ve tekrar dokundur: karşı telefonda hiçbir şey açılmamalı.
  8. (iPhone varsa) NFC ile okumayı dene. Çalışmazsa sonucu not et; QR her durumda çalışmalı.
  9. Telefonun dilini İngilizce yap: arayüz İngilizceye geçmeli.

**Bilinen riskler (cihazda doğrulanacak):**
- iPhone'ların Android HCE etiketini okuyup okumaması modele ve iOS sürümüne bağlı.
- vCard NDEF kaydını (`text/vcard`) karşı Android telefonun hangi uygulamayla açacağı rehber uygulamasına bağlı. URL kayıtları her yerde çalışır.
- İki Android telefon aynı anda okuyucu modundaysa ilk dokunuşta algılama gecikebilir; telefonlar birkaç saniye temas halinde tutulmalı.

---

## Doğrulama (uçtan uca)

1. `flutter test` → Dart birim ve widget testlerinin tümü PASS.
2. `cd android && JAVA_HOME=$HOME/development/jdk ./gradlew :app:testDebugUnitTest` → Type4Tag testleri PASS.
3. `flutter analyze` → `No issues found!`
4. `flutter build apk --release` → APK oluşur.
5. Task 9'daki cihaz kontrol listesi kullanıcıyla birlikte geçilir.

## Yürütme

Önerim **Native** (task'ları bu oturumda ben yazarım, sonda tek bir bağımsız inceleme yapılır). Sebebi: 9 task da birbirinin arayüzüne zincirleme bağlı (Profile → link → vCard → NDEF → HCE → ekranlar) ve küçük. Asıl risk olan NFC davranışı ise kod incelemesiyle değil, Task 9'daki cihaz testiyle ortaya çıkar. Daha sıkı kontrol istersen **Subagent-driven** de mümkün: her task'ı ayrı bir alt ajan yazar ve ayrı bir inceleyici kontrol eder. Daha yavaş ve daha pahalıdır.
