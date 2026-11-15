import '../models/profile.dart';
import 'share_item.dart';

String _esc(String v) => v
    .replaceAll('\\', '\\\\')
    .replaceAll(',', '\\,')
    .replaceAll(';', '\\;')
    .replaceAll('\n', '\\n');

/// vCard 3.0 holding the name plus whatever [items] contribute.
String buildVCard(Profile p, Set<ShareItem> items) {
  final name = p.fullName.trim();
  final parts = name.split(RegExp(r'\s+'));
  final family = parts.length > 1 ? parts.last : '';
  final given = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' ') : name;

  final lines = <String>[
    'BEGIN:VCARD',
    'VERSION:3.0',
    'N:${_esc(family)};${_esc(given)};;;',
    'FN:${_esc(name)}',
  ];
  if (items.contains(ShareItem.contact)) {
    void add(String prefix, String value, {bool escape = true}) {
      final v = value.trim();
      if (v.isNotEmpty) lines.add('$prefix${escape ? _esc(v) : v}');
    }

    add('ORG:', p.company);
    add('TITLE:', p.title);
    add('TEL;TYPE=CELL:', p.phone, escape: false);
    add('EMAIL;TYPE=INTERNET:', p.email, escape: false);
  }
  if (items.contains(ShareItem.location)) {
    lines.add('ADR;TYPE=WORK:;;${_esc(p.address.trim())};;;;');
  }
  for (final item in ShareItem.values) {
    if (item == ShareItem.contact || item == ShareItem.location) continue;
    if (items.contains(item)) lines.add('URL:${urlFor(item, p)}');
  }
  lines.add('END:VCARD');
  return '${lines.join('\r\n')}\r\n';
}
