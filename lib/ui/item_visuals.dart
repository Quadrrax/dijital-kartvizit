import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../l10n/app_localizations.dart';
import '../sharing/share_item.dart';

IconData itemIcon(ShareItem item) => switch (item) {
      ShareItem.contact => FontAwesomeIcons.addressCard,
      ShareItem.whatsapp => FontAwesomeIcons.whatsapp,
      ShareItem.instagram => FontAwesomeIcons.instagram,
      ShareItem.github => FontAwesomeIcons.github,
      ShareItem.linkedin => FontAwesomeIcons.linkedin,
      ShareItem.x => FontAwesomeIcons.xTwitter,
      ShareItem.website => FontAwesomeIcons.globe,
      ShareItem.location => FontAwesomeIcons.locationDot,
    }
        .data;

/// Brand names stay as they are; the rest are translated.
String itemLabel(ShareItem item, AppLocalizations l) => switch (item) {
      ShareItem.contact => l.itemContact,
      ShareItem.whatsapp => 'WhatsApp',
      ShareItem.instagram => 'Instagram',
      ShareItem.github => 'GitHub',
      ShareItem.linkedin => 'LinkedIn',
      ShareItem.x => 'X',
      ShareItem.website => l.itemWebsite,
      ShareItem.location => l.itemLocation,
    };
