import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/sharing/share_item.dart';
import 'package:flutter_test/flutter_test.dart';

String url(AccountType t, String v) => urlFor(Account(type: t, value: v));

void main() {
  test('availableItems: contact, non-empty accounts in order, then location', () {
    const p = Profile(fullName: 'Ali', address: 'Kadıköy', accounts: [
      Account(type: AccountType.instagram, value: 'ali'),
      Account(type: AccountType.github, value: ' '),
      Account(type: AccountType.instagram, value: 'ali_is'),
    ]);
    final items = availableItems(p);
    expect(items.map((i) => i.key), ['contact', 'acc:0', 'acc:2', 'location']);
    expect(items[2].account!.value, 'ali_is');
  });

  test('availableItems is empty without a name', () {
    expect(availableItems(const Profile(address: 'x')).map((i) => i.key), ['location']);
    expect(availableItems(Profile.empty), isEmpty);
  });

  test('items with the same key are equal', () {
    const a = Account(type: AccountType.github, value: 'a');
    expect(const ShareItem.account(1, a), const ShareItem.account(1, a));
    expect(<ShareItem>{const ShareItem.contact()}.contains(const ShareItem.contact()), isTrue);
  });

  test('handles are normalized', () {
    for (final raw in ['ali', '@ali', ' ali ', 'ali/']) {
      expect(url(AccountType.instagram, raw), 'https://instagram.com/ali');
    }
    expect(url(AccountType.github, 'https://github.com/ali'), 'https://github.com/ali');
    expect(url(AccountType.linkedin, 'ali'), 'https://www.linkedin.com/in/ali');
    expect(url(AccountType.x, '@ali'), 'https://x.com/ali');
  });

  test('profile links typed without scheme are not doubled', () {
    for (final raw in ['instagram.com/ali', 'www.instagram.com/ali/']) {
      expect(url(AccountType.instagram, raw), 'https://instagram.com/ali');
    }
    expect(url(AccountType.github, 'github.com/ali'), 'https://github.com/ali');
    expect(url(AccountType.linkedin, 'linkedin.com/in/ali'), 'https://www.linkedin.com/in/ali');
    expect(url(AccountType.linkedin, 'www.linkedin.com/in/ali/'), 'https://www.linkedin.com/in/ali');
    for (final raw in ['x.com/ali', 'twitter.com/ali']) {
      expect(url(AccountType.x, raw), 'https://x.com/ali');
    }
  });

  test('website gets https when scheme missing', () {
    expect(url(AccountType.website, 'ali.dev'), 'https://ali.dev');
    expect(url(AccountType.website, 'http://ali.dev'), 'http://ali.dev');
  });

  test('whatsapp phone formats', () {
    for (final raw in ['0532 123 45 67', '+90 532 123 45 67', '5321234567', '0090 532 123 45 67']) {
      expect(url(AccountType.whatsapp, raw), 'https://wa.me/905321234567');
    }
  });

  test('location url encodes turkish address', () {
    expect(locationUrl('Kadıköy İstanbul'),
        'https://www.google.com/maps/search/?api=1&query=Kad%C4%B1k%C3%B6y%20%C4%B0stanbul');
  });

  test('accountHandle shows a short readable form', () {
    expect(accountHandle(const Account(type: AccountType.instagram, value: 'instagram.com/ali')), '@ali');
    expect(accountHandle(const Account(type: AccountType.website, value: 'https://ali.dev/')), 'ali.dev');
    expect(accountHandle(const Account(type: AccountType.whatsapp, value: '0532 123 45 67')), '0532 123 45 67');
  });
}
