import 'package:dijital_kartvizit/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('json roundtrip keeps every field', () {
    const p = Profile(
      fullName: 'Ali Veli',
      title: 'Dev',
      company: 'Acme',
      phone: '0532',
      email: 'a@b.c',
      website: 'a.dev',
      instagram: 'ali',
      github: 'ali',
      linkedin: 'ali',
      x: 'ali',
      address: 'Kadıköy',
      photoPath: '/p.jpg',
    );
    expect(Profile.fromJson(p.toJson()).toJson(), p.toJson());
  });

  test('fromJson with missing keys gives empty strings', () {
    final p = Profile.fromJson({});
    expect(p.fullName, '');
    expect(p.instagram, '');
    expect(p.photoPath, isNull);
  });

  test('copyWith replaces only given fields', () {
    const p = Profile(fullName: 'Ali', github: 'ali');
    final q = p.copyWith(github: 'veli');
    expect(q.fullName, 'Ali');
    expect(q.github, 'veli');
  });
}
