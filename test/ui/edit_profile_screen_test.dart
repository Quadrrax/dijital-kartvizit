import 'package:dijital_kartvizit/data/profile_store.dart';
import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/ui/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  /// Opens the editor for [initial] on top of a host page so popping is
  /// observable. [saved] are the cards already in the store.
  Future<ProfileStore> open(WidgetTester tester, Profile initial, {List<Profile> saved = const []}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    final store = (await tester.runAsync(() => testStore(saved)))!;
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
    await tester.pumpAndSettle();
    await tester.enterText(f, text);
  }

  Future<void> addAccount(WidgetTester tester, String platform) async {
    await tester.ensureVisible(find.text('Hesap ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hesap ekle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(platform).last);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
  }

  testWidgets('empty name shows required error and does not save', (tester) async {
    final store = await open(tester, const Profile(id: 'n'));
    await save(tester);
    expect(find.text('Zorunlu'), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(store.loadAll(), isEmpty);
  });

  testWidgets('new card is added, trimmed, made active, and screen pops', (tester) async {
    final store = await open(tester, const Profile(id: 'n'), saved: const [Profile(id: 'old', fullName: 'X')]);
    await enter(tester, 'field_cardName', ' İş ');
    await enter(tester, 'field_fullName', '  Ali Veli ');
    await save(tester);
    final all = store.loadAll();
    expect(all.map((p) => p.id), ['old', 'n']);
    expect(all.last.cardName, 'İş');
    expect(all.last.fullName, 'Ali Veli');
    expect(store.activeId, 'n');
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  testWidgets('empty card name falls back to default', (tester) async {
    final store = await open(tester, const Profile(id: 'n'));
    await enter(tester, 'field_fullName', 'Ali');
    await save(tester);
    expect(store.loadAll().single.cardName, 'Kartım');
  });

  testWidgets('two accounts on the same platform are saved with labels', (tester) async {
    final store = await open(tester, const Profile(id: 'n', fullName: 'Ali'));
    await addAccount(tester, 'Instagram');
    await addAccount(tester, 'Instagram');
    await enter(tester, 'field_acc_value_0', 'ali');
    await enter(tester, 'field_acc_value_1', 'ali_is');
    await enter(tester, 'field_acc_label_1', 'İş');
    await save(tester);
    final accounts = store.loadAll().single.accounts;
    expect(accounts.map((a) => (a.type, a.value, a.label)).toList(), [
      (AccountType.instagram, 'ali', ''),
      (AccountType.instagram, 'ali_is', 'İş'),
    ]);
  });

  testWidgets('removed and empty accounts are not saved', (tester) async {
    const initial = Profile(id: 'e', fullName: 'Ali', accounts: [
      Account(type: AccountType.github, value: 'a'),
      Account(type: AccountType.x, value: 'b'),
    ]);
    final store = await open(tester, initial, saved: const [initial]);
    await tester.ensureVisible(find.byKey(const Key('acc_remove_0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('acc_remove_0')));
    await tester.pumpAndSettle();
    await addAccount(tester, 'WhatsApp'); // left empty
    await save(tester);
    expect(store.loadAll().single.accounts.map((a) => a.value), ['b']);
  });

  testWidgets('prefills initial profile', (tester) async {
    await open(tester, const Profile(id: 'e', fullName: 'Ali', accounts: [
      Account(type: AccountType.github, value: 'aligit'),
    ]));
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('aligit'), findsOneWidget);
  });

  testWidgets('deleting a card removes it and activates another', (tester) async {
    const a = Profile(id: 'a', fullName: 'A');
    const b = Profile(id: 'b', fullName: 'B');
    final store = await open(tester, a, saved: const [a, b]);
    await tester.tap(find.byTooltip('Kartı sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();
    expect(store.loadAll().map((p) => p.id), ['b']);
    expect(store.activeId, 'b');
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  testWidgets('new card has no delete button', (tester) async {
    await open(tester, const Profile(id: 'n'));
    expect(find.byTooltip('Kartı sil'), findsNothing);
  });
}
