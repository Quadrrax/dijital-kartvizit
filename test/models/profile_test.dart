import 'package:dijital_kartvizit/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('json roundtrip keeps every field and accounts in order', () {
    const p = Profile(
      id: 'p1',
      cardName: 'İş',
      fullName: 'Ali Veli',
      title: 'Dev',
      company: 'Acme',
      phone: '0532',
      email: 'a@b.c',
      address: 'Kadıköy',
      photoPath: '/p.jpg',
      accounts: [
        Account(type: AccountType.instagram, value: 'ali', label: 'Kişisel'),
        Account(type: AccountType.instagram, value: 'ali_is', label: 'İş'),
        Account(type: AccountType.github, value: 'ali'),
      ],
    );
    final back = Profile.fromJson(p.toJson());
    expect(back.toJson(), p.toJson());
    expect(back.accounts[1].value, 'ali_is');
    expect(back.accounts[1].label, 'İş');
  });

  test('fromJson with missing keys gives empty values', () {
    final p = Profile.fromJson({});
    expect(p.fullName, '');
    expect(p.accounts, isEmpty);
    expect(p.photoPath, isNull);
  });

  test('old single-profile json is migrated into accounts', () {
    final p = Profile.fromJson({
      'fullName': 'Ali',
      'phone': '0532 123 45 67',
      'website': 'ali.dev',
      'instagram': 'ali',
      'github': 'ali',
      'linkedin': '',
      'x': 'alix',
    });
    expect(p.accounts.map((a) => (a.type, a.value)).toList(), [
      (AccountType.whatsapp, '0532 123 45 67'),
      (AccountType.instagram, 'ali'),
      (AccountType.github, 'ali'),
      (AccountType.x, 'alix'),
      (AccountType.website, 'ali.dev'),
    ]);
    expect(p.phone, '0532 123 45 67');
  });

  test('unknown account type in json is skipped', () {
    final p = Profile.fromJson({
      'accounts': [
        {'type': 'tiktok', 'value': 'x'},
        {'type': 'github', 'value': 'ali'},
      ],
    });
    expect(p.accounts.single.type, AccountType.github);
  });
}
