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
  instagram: 'ali',
  github: 'ali',
  address: 'Kadıköy',
);

void main() {
  test('contact only', () {
    expect(
        buildVCard(full, {ShareItem.contact}),
        'BEGIN:VCARD\r\nVERSION:3.0\r\nN:Koç;Ahmet Ekrem;;;\r\nFN:Ahmet Ekrem Koç\r\n'
        'ORG:Koç\\, A.Ş.\\; Ltd\r\nTITLE:Mühendis\r\nTEL;TYPE=CELL:0532 123 45 67\r\n'
        'EMAIL;TYPE=INTERNET:a@b.c\r\nEND:VCARD\r\n');
  });

  test('urls only: name kept, contact fields omitted, enum order', () {
    final v = buildVCard(full, {ShareItem.github, ShareItem.instagram});
    expect(
        v,
        contains('FN:Ahmet Ekrem Koç\r\nURL:https://instagram.com/ali\r\n'
            'URL:https://github.com/ali\r\nEND:VCARD'));
    expect(v, isNot(contains('TEL')));
  });

  test('location adds ADR', () {
    expect(buildVCard(full, {ShareItem.location}), contains('ADR;TYPE=WORK:;;Kadıköy;;;;\r\n'));
  });

  test('single-word name', () {
    expect(buildVCard(const Profile(fullName: 'Ahmet'), {ShareItem.contact}),
        contains('N:;Ahmet;;;\r\n'));
  });

  test('empty contact fields are skipped', () {
    final v = buildVCard(const Profile(fullName: 'Ali Veli', phone: '1'), {ShareItem.contact});
    expect(v, isNot(contains('ORG')));
    expect(v, isNot(contains('TITLE')));
    expect(v, isNot(contains('EMAIL')));
    expect(v, contains('TEL;TYPE=CELL:1\r\n'));
  });

  test('backslash and newline are escaped', () {
    final v = buildVCard(const Profile(fullName: 'A B', title: 'a\\b\nc'), {ShareItem.contact});
    expect(v, contains('TITLE:a\\\\b\\nc\r\n'));
  });
}
