import '../models/profile.dart';
import 'share_item.dart';
import 'vcard.dart';

/// What goes into the QR code and the NFC tag.
sealed class SharePayload {
  const SharePayload();
  String get qrText;
}

final class UriPayload extends SharePayload {
  const UriPayload(this.uri);
  final String uri;
  @override
  String get qrText => uri;
}

final class VCardPayload extends SharePayload {
  const VCardPayload(this.vcard);
  final String vcard;
  @override
  String get qrText => vcard;
}

/// One link item → that link. Contact, or several items → one vCard.
SharePayload buildPayload(Profile p, Set<ShareItem> selected) {
  assert(selected.isNotEmpty, 'nothing selected');
  if (selected.length == 1 && selected.first != ShareItem.contact) {
    return UriPayload(urlFor(selected.first, p));
  }
  return VCardPayload(buildVCard(p, selected));
}
