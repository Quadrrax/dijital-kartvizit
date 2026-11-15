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

  test('loadAll is empty when nothing saved', () async {
    final store = await storeWith({});
    expect(store.loadAll(), isEmpty);
    expect(store.activeId, isNull);
  });

  test('saveAll then loadAll keeps profiles in order', () async {
    final store = await storeWith({});
    await store.saveAll(const [
      Profile(id: 'a', cardName: 'Kişisel', fullName: 'Ali'),
      Profile(id: 'b', cardName: 'İş', fullName: 'Ali Veli'),
    ]);
    expect(store.loadAll().map((p) => p.id), ['a', 'b']);
  });

  test('active id is remembered', () async {
    final store = await storeWith({});
    await store.setActiveId('b');
    expect(store.activeId, 'b');
  });

  test('old single profile is migrated with a generated id', () async {
    final store = await storeWith({
      'profile': jsonEncode({'fullName': 'Ali', 'instagram': 'ali'}),
    });
    final all = store.loadAll();
    expect(all, hasLength(1));
    expect(all.single.fullName, 'Ali');
    expect(all.single.id, isNotEmpty);
    expect(all.single.accounts.single.type, AccountType.instagram);
  });

  test('corrupt json returns empty list instead of throwing', () async {
    expect((await storeWith({'profiles': '{bozuk'})).loadAll(), isEmpty);
    expect((await storeWith({'profiles': jsonEncode({'a': 1})})).loadAll(), isEmpty);
    expect((await storeWith({'profile': '{bozuk'})).loadAll(), isEmpty);
  });

  test('newId gives distinct ids', () async {
    final store = await storeWith({});
    expect(store.newId(), isNot(store.newId()));
  });

  test('importPhoto replaces only the same profile\'s photo', () async {
    final store = await storeWith({});
    final src = File('${dir.path}/src.jpg')..writeAsBytesSync([1, 2, 3]);
    final photoDir = Directory('${dir.path}/photos')..createSync();
    final photoStore = ProfileStore(await SharedPreferences.getInstance(), photoDir);

    final a1 = await photoStore.importPhoto(src.path, 'a');
    final b1 = await photoStore.importPhoto(src.path, 'b');
    expect(File(a1).readAsBytesSync(), [1, 2, 3]);

    await Future<void>.delayed(const Duration(milliseconds: 2));
    final a2 = await photoStore.importPhoto(src.path, 'a');
    expect(File(a2).existsSync(), isTrue);
    expect(File(a1).existsSync(), isFalse);
    expect(File(b1).existsSync(), isTrue);
    expect(store, isNotNull);
  });
}
