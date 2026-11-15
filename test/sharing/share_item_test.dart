import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/sharing/share_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('availableItems lists only filled fields in enum order', () {
    expect(availableItems(const Profile(fullName: 'Ali', github: 'ali', instagram: ' ')),
        [ShareItem.contact, ShareItem.github]);
  });

  test('availableItems maps every item to its source field', () {
    const full = Profile(
      fullName: 'A',
      phone: '1',
      instagram: 'i',
      github: 'g',
      linkedin: 'l',
      x: 'x',
      website: 'w',
      address: 'a',
    );
    expect(availableItems(full), ShareItem.values);
    expect(availableItems(Profile.empty), isEmpty);
  });

  test('handles are normalized', () {
    for (final raw in ['ali', '@ali', ' ali ', 'ali/']) {
      expect(urlFor(ShareItem.instagram, Profile(instagram: raw)), 'https://instagram.com/ali');
    }
    expect(urlFor(ShareItem.github, const Profile(github: 'https://github.com/ali')),
        'https://github.com/ali');
    expect(urlFor(ShareItem.linkedin, const Profile(linkedin: 'ali')),
        'https://www.linkedin.com/in/ali');
    expect(urlFor(ShareItem.x, const Profile(x: '@ali')), 'https://x.com/ali');
  });

  test('profile links typed without scheme are not doubled', () {
    for (final raw in ['instagram.com/ali', 'www.instagram.com/ali/']) {
      expect(urlFor(ShareItem.instagram, Profile(instagram: raw)), 'https://instagram.com/ali');
    }
    expect(urlFor(ShareItem.github, const Profile(github: 'github.com/ali')), 'https://github.com/ali');
    expect(urlFor(ShareItem.linkedin, const Profile(linkedin: 'linkedin.com/in/ali')),
        'https://www.linkedin.com/in/ali');
    expect(urlFor(ShareItem.linkedin, const Profile(linkedin: 'www.linkedin.com/in/ali/')),
        'https://www.linkedin.com/in/ali');
    for (final raw in ['x.com/ali', 'twitter.com/ali']) {
      expect(urlFor(ShareItem.x, Profile(x: raw)), 'https://x.com/ali');
    }
  });

  test('website gets https when scheme missing', () {
    expect(urlFor(ShareItem.website, const Profile(website: 'ali.dev')), 'https://ali.dev');
    expect(urlFor(ShareItem.website, const Profile(website: 'http://ali.dev')), 'http://ali.dev');
  });

  test('whatsapp phone formats', () {
    for (final raw in ['0532 123 45 67', '+90 532 123 45 67', '5321234567', '0090 532 123 45 67']) {
      expect(urlFor(ShareItem.whatsapp, Profile(phone: raw)), 'https://wa.me/905321234567');
    }
  });

  test('location url encodes turkish address', () {
    expect(urlFor(ShareItem.location, const Profile(address: 'Kadıköy İstanbul')),
        'https://www.google.com/maps/search/?api=1&query=Kad%C4%B1k%C3%B6y%20%C4%B0stanbul');
  });

  test('contact has no url', () {
    expect(() => urlFor(ShareItem.contact, const Profile(fullName: 'A')), throwsArgumentError);
  });
}
