import '../models/profile.dart';

/// Things the user can share. Declaration order is the order on screen and
/// in the vCard.
enum ShareItem { contact, whatsapp, instagram, github, linkedin, x, website, location }

String _source(ShareItem item, Profile p) => switch (item) {
      ShareItem.contact => p.fullName,
      ShareItem.whatsapp => p.phone,
      ShareItem.instagram => p.instagram,
      ShareItem.github => p.github,
      ShareItem.linkedin => p.linkedin,
      ShareItem.x => p.x,
      ShareItem.website => p.website,
      ShareItem.location => p.address,
    };

List<ShareItem> availableItems(Profile p) =>
    ShareItem.values.where((i) => _source(i, p).trim().isNotEmpty).toList();

bool _hasScheme(String s) => s.startsWith('http://') || s.startsWith('https://');

String _profileUrl(String base, String raw) {
  var h = raw.trim();
  if (_hasScheme(h)) return h;
  if (h.startsWith('@')) h = h.substring(1);
  if (h.endsWith('/')) h = h.substring(0, h.length - 1);
  return '$base$h';
}

String _whatsappDigits(String phone) {
  final d = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('00')) return d.substring(2);
  if (d.startsWith('0')) return '90${d.substring(1)}';
  if (d.length == 10 && d.startsWith('5')) return '90$d';
  return d;
}

/// The link a single item opens. [ShareItem.contact] has no link — it is
/// shared as a vCard.
String urlFor(ShareItem item, Profile p) {
  switch (item) {
    case ShareItem.contact:
      throw ArgumentError.value(item, 'item', 'contact is shared as a vCard, not a URL');
    case ShareItem.whatsapp:
      return 'https://wa.me/${_whatsappDigits(p.phone)}';
    case ShareItem.instagram:
      return _profileUrl('https://instagram.com/', p.instagram);
    case ShareItem.github:
      return _profileUrl('https://github.com/', p.github);
    case ShareItem.linkedin:
      return _profileUrl('https://www.linkedin.com/in/', p.linkedin);
    case ShareItem.x:
      return _profileUrl('https://x.com/', p.x);
    case ShareItem.website:
      final w = p.website.trim();
      return _hasScheme(w) ? w : 'https://$w';
    case ShareItem.location:
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(p.address.trim())}';
  }
}
