import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/sharing/payload.dart';
import 'package:dijital_kartvizit/sharing/share_item.dart';
import 'package:dijital_kartvizit/sharing/vcard.dart';
import 'package:flutter_test/flutter_test.dart';

const full = Profile(fullName: 'Ahmet Koç', address: 'Kadıköy', accounts: [
  Account(type: AccountType.instagram, value: 'ali'),
  Account(type: AccountType.github, value: 'ali'),
]);

void main() {
  final insta = ShareItem.account(0, full.accounts[0]);
  final github = ShareItem.account(1, full.accounts[1]);

  test('single account gives UriPayload', () {
    final p = buildPayload(full, {github});
    expect(p, isA<UriPayload>());
    expect(p.qrText, 'https://github.com/ali');
  });

  test('single location gives maps link', () {
    expect(buildPayload(full, {const ShareItem.location()}).qrText,
        'https://www.google.com/maps/search/?api=1&query=Kad%C4%B1k%C3%B6y');
  });

  test('contact alone gives VCardPayload', () {
    final p = buildPayload(full, {const ShareItem.contact()});
    expect(p, isA<VCardPayload>());
    expect(p.qrText, buildVCard(full, {const ShareItem.contact()}));
  });

  test('multiple items give VCardPayload', () {
    final p = buildPayload(full, {github, insta});
    expect(p, isA<VCardPayload>());
    expect(p.qrText, buildVCard(full, {github, insta}));
  });
}
