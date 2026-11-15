import 'dart:convert';
import 'dart:typed_data';

import 'payload.dart';

const _tnfWellKnown = 0x01;
const _tnfMime = 0x02;

/// URI identifier codes (NFC Forum URI RTD), longest prefix first.
const _uriPrefixes = <(String, int)>[
  ('https://www.', 0x02),
  ('http://www.', 0x01),
  ('https://', 0x04),
  ('http://', 0x03),
  ('tel:', 0x05),
  ('mailto:', 0x06),
];

/// A single-record NDEF message: a URI record for a link, a `text/vcard`
/// MIME record for a contact.
Uint8List encodeNdef(SharePayload payload) {
  switch (payload) {
    case UriPayload(:final uri):
      var code = 0x00;
      var rest = uri;
      for (final (prefix, c) in _uriPrefixes) {
        if (uri.startsWith(prefix)) {
          code = c;
          rest = uri.substring(prefix.length);
          break;
        }
      }
      return _record(_tnfWellKnown, ascii.encode('U'), [code, ...utf8.encode(rest)]);
    case VCardPayload(:final vcard):
      return _record(_tnfMime, ascii.encode('text/vcard'), utf8.encode(vcard));
  }
}

Uint8List _record(int tnf, List<int> type, List<int> body) {
  final short = body.length < 256;
  final header = 0x80 | 0x40 | (short ? 0x10 : 0) | tnf;
  final length = short
      ? [body.length]
      : [(body.length >> 24) & 0xFF, (body.length >> 16) & 0xFF, (body.length >> 8) & 0xFF, body.length & 0xFF];
  return Uint8List.fromList([header, type.length, ...length, ...type, ...body]);
}
