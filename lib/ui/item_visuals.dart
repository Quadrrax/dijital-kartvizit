import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../l10n/app_localizations.dart';
import '../models/profile.dart';
import '../sharing/share_item.dart';

IconData accountIcon(AccountType type) => switch (type) {
      AccountType.whatsapp => FontAwesomeIcons.whatsapp,
      AccountType.instagram => FontAwesomeIcons.instagram,
      AccountType.github => FontAwesomeIcons.github,
      AccountType.linkedin => FontAwesomeIcons.linkedin,
      AccountType.x => FontAwesomeIcons.xTwitter,
      AccountType.website => FontAwesomeIcons.globe,
    }
        .data;

/// Brand names stay as they are; "Website" is translated.
String accountTypeName(AccountType type, AppLocalizations l) => switch (type) {
      AccountType.whatsapp => 'WhatsApp',
      AccountType.instagram => 'Instagram',
      AccountType.github => 'GitHub',
      AccountType.linkedin => 'LinkedIn',
      AccountType.x => 'X',
      AccountType.website => l.itemWebsite,
    };

IconData itemIcon(ShareItem item) => switch (item.kind) {
      ShareKind.contact => FontAwesomeIcons.addressCard.data,
      ShareKind.location => FontAwesomeIcons.locationDot.data,
      ShareKind.account => accountIcon(item.account!.type),
    };

/// Main line of a tile: "Rehbere ekle", "Konum" or the platform name.
String itemTitle(ShareItem item, AppLocalizations l) => switch (item.kind) {
      ShareKind.contact => l.itemContact,
      ShareKind.location => l.itemLocation,
      ShareKind.account => accountTypeName(item.account!.type, l),
    };

/// Second line of a tile: the account's label and handle, or contact info.
String itemSubtitle(ShareItem item, Profile p) {
  switch (item.kind) {
    case ShareKind.contact:
      return [p.phone, p.email].map((s) => s.trim()).firstWhere((s) => s.isNotEmpty, orElse: () => p.fullName);
    case ShareKind.location:
      return p.address.trim();
    case ShareKind.account:
      final a = item.account!;
      final handle = accountHandle(a);
      return a.label.trim().isEmpty ? handle : '${a.label.trim()} · $handle';
  }
}

/// One-line name used on chips: title plus the account label if any.
String itemLabel(ShareItem item, AppLocalizations l) {
  final title = itemTitle(item, l);
  final label = item.account?.label.trim() ?? '';
  return label.isEmpty ? title : '$title · $label';
}
