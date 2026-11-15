import 'dart:convert';

import 'package:dijital_kartvizit/sharing/ndef.dart';
import 'package:dijital_kartvizit/sharing/payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uri record with https prefix', () {
    expect(encodeNdef(const UriPayload('https://github.com/ali')),
        [0xD1, 0x01, 15, 0x55, 0x04, ...utf8.encode('github.com/ali')]);
  });

  test('uri record prefers https://www.', () {
    final b = encodeNdef(const UriPayload('https://www.linkedin.com/in/ali'));
    expect(b[4], 0x02);
    expect(b.sublist(5), utf8.encode('linkedin.com/in/ali'));
  });

  test('uri record without known prefix keeps full text', () {
    final b = encodeNdef(const UriPayload('geo:0,0'));
    expect(b[4], 0x00);
    expect(b.sublist(5), utf8.encode('geo:0,0'));
  });

  test('turkish chars use utf8 byte length', () {
    const v = 'BEGIN:VCARD\r\nFN:Şükrü Ağaoğlu\r\nEND:VCARD\r\n';
    final b = encodeNdef(const VCardPayload(v));
    expect(b[0], 0xD2);
    expect(b[1], 10);
    expect(b[2], utf8.encode(v).length);
    expect(b[2], isNot(v.length));
    expect(b.sublist(3, 13), ascii.encode('text/vcard'));
    expect(utf8.decode(b.sublist(13)), v);
  });

  test('long vcard uses 4-byte length', () {
    final v = 'X' * 300;
    final b = encodeNdef(VCardPayload(v));
    expect(b[0], 0xC2);
    expect(b.sublist(2, 6), [0, 0, 0x01, 0x2C]);
    expect(b.length, 1 + 1 + 4 + 10 + 300);
  });
}
