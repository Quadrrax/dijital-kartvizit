import 'dart:convert';
import 'dart:io';

import 'package:dijital_kartvizit/data/profile_store.dart';
import 'package:dijital_kartvizit/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('kartvizit_test');
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  Future<ProfileStore> storeWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return ProfileStore(await SharedPreferences.getInstance(), dir);
  }

  test('load returns empty profile when nothing saved', () async {
    final store = await storeWith({});
    expect(store.load().fullName, '');
  });

  test('save then load returns same profile', () async {
    final store = await storeWith({});
    const p = Profile(fullName: 'Ali Veli', instagram: 'ali', photoPath: '/x.jpg');
    await store.save(p);
    expect(store.load().toJson(), p.toJson());
  });

  test('corrupt json returns empty profile instead of throwing', () async {
    final store = await storeWith({'profile': '{bozuk'});
    expect(store.load().fullName, '');
  });

  test('json of wrong shape returns empty profile instead of throwing', () async {
    final store = await storeWith({'profile': jsonEncode([1, 2])});
    expect(store.load().fullName, '');
  });

  test('importPhoto copies file and deletes previous photo', () async {
    SharedPreferences.setMockInitialValues({});
    final src = File('${dir.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);
    final photoDir = Directory('${dir.path}/photos')..createSync();
    final photoStore = ProfileStore(await SharedPreferences.getInstance(), photoDir);

    final first = await photoStore.importPhoto(src.path);
    expect(first.startsWith(photoDir.path), isTrue);
    expect(first.split('/').last.startsWith('profile_'), isTrue);
    expect(File(first).readAsBytesSync(), [1, 2, 3]);

    await Future<void>.delayed(const Duration(milliseconds: 2));
    final second = await photoStore.importPhoto(src.path);
    expect(File(second).existsSync(), isTrue);
    expect(File(first).existsSync(), isFalse);
  });
}
