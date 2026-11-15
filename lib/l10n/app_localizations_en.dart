// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Business Card';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get emptyProfile => 'Add your details to create your card';

  @override
  String get createProfile => 'Create profile';

  @override
  String shareCount(int count) {
    return 'Share ($count)';
  }

  @override
  String get itemContact => 'Add to contacts';

  @override
  String get itemWebsite => 'Website';

  @override
  String get itemLocation => 'Location';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldCompany => 'Company';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldAddress => 'Address';

  @override
  String get requiredField => 'Required';

  @override
  String get save => 'Save';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get shareTitle => 'Share';

  @override
  String get scanHint => 'Scan the QR code with the camera';

  @override
  String get nfcReady => 'Hold the other phone to the back of yours';

  @override
  String get nfcDisabled => 'NFC is off';

  @override
  String get nfcOpenSettings => 'Turn on NFC';

  @override
  String get nfcUnsupported =>
      'This phone can\'t share over NFC, use the QR code';

  @override
  String get cardName => 'Card name';

  @override
  String get cardNameHint => 'e.g. Personal, Work';

  @override
  String get defaultCardName => 'My card';

  @override
  String get newCard => 'New card';

  @override
  String get deleteCard => 'Delete card';

  @override
  String get deleteCardConfirm => 'Delete this card? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get contactDetails => 'Contact details';

  @override
  String get accounts => 'Accounts';

  @override
  String get addAccount => 'Add account';

  @override
  String get noAccounts =>
      'No accounts yet. You can add several on the same platform.';

  @override
  String get accountLabel => 'Label (optional, e.g. Work)';

  @override
  String get valueUsername => 'Username';

  @override
  String get valuePhone => 'Phone number';

  @override
  String get valueUrl => 'Web address';

  @override
  String get removeAccount => 'Remove account';

  @override
  String get pickToShare => 'Choose what to share';
}
