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
  String get fieldWebsite => 'Website';

  @override
  String get fieldInstagram => 'Instagram username';

  @override
  String get fieldGithub => 'GitHub username';

  @override
  String get fieldLinkedin => 'LinkedIn username';

  @override
  String get fieldX => 'X username';

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
}
