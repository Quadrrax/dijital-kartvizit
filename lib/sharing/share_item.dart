import '../models/profile.dart';

enum ShareKind { contact, account, location }

/// One selectable thing on a card. Accounts are identified by their position
/// in the profile, so two accounts on the same platform stay distinct.
class ShareItem {
  const ShareItem.contact()
      : kind = ShareKind.contact,
        index = -1,
        account = null;
  const ShareItem.location()
      : kind = ShareKind.location,
        index = -1,
        account = null;
  const ShareItem.account(this.index, Account this.account) : kind = ShareKind.account;

  final ShareKind kind;
  final int index;
  final Account? account;

  String get key => kind == ShareKind.account ? 'acc:$index' : kind.name;

  @override
  bool operator ==(Object other) => other is ShareItem && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Contact (needs a name), every filled account in profile order, location.
List<ShareItem> availableItems(Profile p) => [
      if (p.fullName.trim().isNotEmpty) const ShareItem.contact(),
      for (final (i, a) in p.accounts.indexed)
        if (a.value.trim().isNotEmpty) ShareItem.account(i, a),
      if (p.address.trim().isNotEmpty) const ShareItem.location(),
    ];

bool _hasScheme(String s) => s.startsWith('http://') || s.startsWith('https://');

final _hosts = {
  AccountType.instagram: RegExp(r'^(www\.)?instagram\.com/'),
  AccountType.github: RegExp(r'^(www\.)?github\.com/'),
  AccountType.linkedin: RegExp(r'^(www\.)?linkedin\.com/in/'),
  AccountType.x: RegExp(r'^(www\.)?(x|twitter)\.com/'),
};

const _bases = {
  AccountType.instagram: 'https://instagram.com/',
  AccountType.github: 'https://github.com/',
  AccountType.linkedin: 'https://www.linkedin.com/in/',
  AccountType.x: 'https://x.com/',
};

/// Bare username: no '@', no pasted host prefix, no trailing '/'.
String _handle(AccountType type, String raw) {
  var h = raw.trim();
  if (h.startsWith('@')) h = h.substring(1);
  h = h.replaceFirst(_hosts[type]!, '');
  if (h.endsWith('/')) h = h.substring(0, h.length - 1);
  return h;
}

String _whatsappDigits(String phone) {
  final d = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('00')) return d.substring(2);
  if (d.startsWith('0')) return '90${d.substring(1)}';
  if (d.length == 10 && d.startsWith('5')) return '90$d';
  return d;
}

/// The https link an account opens. Phones open these links in the platform's
/// app when it is installed, otherwise in the browser.
String urlFor(Account a) {
  final v = a.value.trim();
  switch (a.type) {
    case AccountType.whatsapp:
      return 'https://wa.me/${_whatsappDigits(v)}';
    case AccountType.website:
      return _hasScheme(v) ? v : 'https://$v';
    case AccountType.instagram:
    case AccountType.github:
    case AccountType.linkedin:
    case AccountType.x:
      return _hasScheme(v) ? v : '${_bases[a.type]}${_handle(a.type, v)}';
  }
}

String locationUrl(String address) =>
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}';

/// Short text shown under an account tile.
String accountHandle(Account a) {
  final v = a.value.trim();
  switch (a.type) {
    case AccountType.whatsapp:
      return v;
    case AccountType.website:
      var w = v.replaceFirst(RegExp(r'^https?://'), '');
      if (w.endsWith('/')) w = w.substring(0, w.length - 1);
      return w;
    case AccountType.instagram:
    case AccountType.github:
    case AccountType.linkedin:
    case AccountType.x:
      final h = _hasScheme(v) ? _handle(a.type, v.replaceFirst(RegExp(r'^https?://'), '')) : _handle(a.type, v);
      return '@$h';
  }
}
