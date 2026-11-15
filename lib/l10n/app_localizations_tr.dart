// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kartvizit';

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String get emptyProfile => 'Kartını oluşturmak için bilgilerini ekle';

  @override
  String get createProfile => 'Profili oluştur';

  @override
  String shareCount(int count) {
    return 'Paylaş ($count)';
  }

  @override
  String get itemContact => 'Rehbere ekle';

  @override
  String get itemWebsite => 'Web sitesi';

  @override
  String get itemLocation => 'Konum';

  @override
  String get fieldFullName => 'Ad soyad';

  @override
  String get fieldTitle => 'Unvan';

  @override
  String get fieldCompany => 'Şirket';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get fieldEmail => 'E-posta';

  @override
  String get fieldWebsite => 'Web sitesi';

  @override
  String get fieldInstagram => 'Instagram kullanıcı adı';

  @override
  String get fieldGithub => 'GitHub kullanıcı adı';

  @override
  String get fieldLinkedin => 'LinkedIn kullanıcı adı';

  @override
  String get fieldX => 'X kullanıcı adı';

  @override
  String get fieldAddress => 'Adres';

  @override
  String get requiredField => 'Zorunlu';

  @override
  String get save => 'Kaydet';

  @override
  String get changePhoto => 'Fotoğrafı değiştir';

  @override
  String get shareTitle => 'Paylaş';

  @override
  String get scanHint => 'QR kodu kamerayla okut';

  @override
  String get nfcReady => 'Diğer telefonu telefonunun arkasına yaklaştır';

  @override
  String get nfcDisabled => 'NFC kapalı';

  @override
  String get nfcOpenSettings => 'NFC\'yi aç';

  @override
  String get nfcUnsupported =>
      'Bu telefon NFC ile paylaşamıyor, QR kodu kullan';
}
