import 'package:dijital_kartvizit/data/profile_store.dart';
import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/ui/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  /// Opens the edit screen on top of a host page so that popping is observable.
  Future<ProfileStore> open(WidgetTester tester, Profile initial) async {
    final store = (await tester.runAsync(() => testStore(initial)))!;
    await tester.pumpWidget(wrapTr(Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => EditProfileScreen(store: store, initial: initial),
        )),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return store;
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.enterText(f, text);
  }

  testWidgets('empty name shows required error and does not save', (tester) async {
    final store = await open(tester, Profile.empty);
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Zorunlu'), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(store.load().fullName, '');
  });

  testWidgets('saves trimmed values and pops', (tester) async {
    final store = await open(tester, Profile.empty);
    await enter(tester, 'field_fullName', '  Ali Veli ');
    await enter(tester, 'field_instagram', '@ali');
    await enter(tester, 'field_address', ' Kadıköy ');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    final saved = store.load();
    expect(saved.fullName, 'Ali Veli');
    expect(saved.instagram, '@ali');
    expect(saved.address, 'Kadıköy');
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  testWidgets('prefills initial profile', (tester) async {
    await open(tester, const Profile(fullName: 'Ali', github: 'aligit'));
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('aligit'), findsOneWidget);
  });

  testWidgets('keeps existing photo path when saving', (tester) async {
    final store = await open(tester, const Profile(fullName: 'Ali', photoPath: '/p.jpg'));
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(store.load().photoPath, '/p.jpg');
  });
}
