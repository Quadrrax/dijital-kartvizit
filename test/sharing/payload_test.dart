import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/sharing/payload.dart';
import 'package:dijital_kartvizit/sharing/share_item.dart';
import 'package:dijital_kartvizit/sharing/vcard.dart';
import 'package:flutter_test/flutter_test.dart';

const full = Profile(fullName: 'Ahmet Koç', phone: '0532', instagram: 'ali', github: 'ali');

void main() {
  test('single url item gives UriPayload', () {
    final p = buildPayload(full, {ShareItem.github});
    expect(p, isA<UriPayload>());
    expect(p.qrText, 'https://github.com/ali');
  });

  test('contact alone gives VCardPayload', () {
    final p = buildPayload(full, {ShareItem.contact});
    expect(p, isA<VCardPayload>());
    expect(p.qrText, buildVCard(full, {ShareItem.contact}));
  });

  test('multiple items give VCardPayload', () {
    final p = buildPayload(full, {ShareItem.github, ShareItem.instagram});
    expect(p, isA<VCardPayload>());
    expect(p.qrText, buildVCard(full, {ShareItem.github, ShareItem.instagram}));
  });
}
