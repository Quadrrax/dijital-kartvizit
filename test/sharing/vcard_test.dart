import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/sharing/share_item.dart';
import 'package:dijital_kartvizit/sharing/vcard.dart';
import 'package:flutter_test/flutter_test.dart';

const full = Profile(
  fullName: 'Ahmet Ekrem Koç',
  title: 'Mühendis',
  company: 'Koç, A.Ş.; Ltd',
  phone: '0532 123 45 67',
  email: 'a@b.c',
  address: 'Kadıköy',
  accounts: [
    Account(type: AccountType.instagram, value: 'ali'),
    Account(type: AccountType.github, value: 'ali'),
    Account(type: AccountType.instagram, value: 'ali_is'),
  ],
);

ShareItem acc(int i) => ShareItem.account(i, full.accounts[i]);

void main() {
  test('contact only', () {
    expect(
        buildVCard(full, {const ShareItem.contact()}),
        'BEGIN:VCARD\r\nVERSION:3.0\r\nN:Koç;Ahmet Ekrem;;;\r\nFN:Ahmet Ekrem Koç\r\n'
        'ORG:Koç\\, A.Ş.\\; Ltd\r\nTITLE:Mühendis\r\nTEL;TYPE=CELL:0532 123 45 67\r\n'
        'EMAIL;TYPE=INTERNET:a@b.c\r\nEND:VCARD\r\n');
  });

  test('accounts only: name kept, contact fields omitted, profile order', () {
    final v = buildVCard(full, {acc(2), acc(0)});
    expect(
        v,
        contains('FN:Ahmet Ekrem Koç\r\nURL:https://instagram.com/ali\r\n'
            'URL:https://instagram.com/ali_is\r\nEND:VCARD'));
    expect(v, isNot(contains('TEL')));
  });

  test('location adds ADR', () {
    expect(buildVCard(full, {const ShareItem.location()}), contains('ADR;TYPE=WORK:;;Kadıköy;;;;\r\n'));
  });

  test('single-word name', () {
    expect(buildVCard(const Profile(fullName: 'Ahmet'), {const ShareItem.contact()}),
        contains('N:;Ahmet;;;\r\n'));
  });

  test('empty contact fields are skipped', () {
    final v = buildVCard(const Profile(fullName: 'Ali Veli', phone: '1'), {const ShareItem.contact()});
    expect(v, isNot(contains('ORG')));
    expect(v, isNot(contains('EMAIL')));
    expect(v, contains('TEL;TYPE=CELL:1\r\n'));
  });

  test('backslash and newline are escaped', () {
    final v = buildVCard(const Profile(fullName: 'A B', title: 'a\\b\nc'), {const ShareItem.contact()});
    expect(v, contains('TITLE:a\\\\b\\nc\r\n'));
  });
}
