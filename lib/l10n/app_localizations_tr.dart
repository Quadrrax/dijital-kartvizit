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

  @override
  String get cardName => 'Kart adı';

  @override
  String get cardNameHint => 'ör. Kişisel, İş';

  @override
  String get defaultCardName => 'Kartım';

  @override
  String get newCard => 'Yeni kart';

  @override
  String get deleteCard => 'Kartı sil';

  @override
  String get deleteCardConfirm => 'Bu kart silinsin mi? Geri alınamaz.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get contactDetails => 'İletişim bilgileri';

  @override
  String get accounts => 'Hesaplar';

  @override
  String get addAccount => 'Hesap ekle';

  @override
  String get noAccounts =>
      'Henüz hesap yok. Aynı platformdan birden fazla ekleyebilirsin.';

  @override
  String get accountLabel => 'Etiket (isteğe bağlı, ör. İş)';

  @override
  String get valueUsername => 'Kullanıcı adı';

  @override
  String get valuePhone => 'Telefon numarası';

  @override
  String get valueUrl => 'Web adresi';

  @override
  String get removeAccount => 'Hesabı kaldır';

  @override
  String get pickToShare => 'Paylaşmak istediklerini seç';
}
