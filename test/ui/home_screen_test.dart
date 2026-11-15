import 'package:dijital_kartvizit/app.dart';
import 'package:dijital_kartvizit/data/profile_store.dart';
import 'package:dijital_kartvizit/models/profile.dart';
import 'package:dijital_kartvizit/ui/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const personal = Profile(
  id: 'p',
  cardName: 'Kişisel',
  fullName: 'Ali Veli',
  accounts: [
    Account(type: AccountType.instagram, value: 'ali'),
    Account(type: AccountType.instagram, value: 'ali_is', label: 'İş'),
  ],
);
const work = Profile(
  id: 'w',
  cardName: 'İş',
  fullName: 'Ali Veli',
  title: 'Mühendis',
  accounts: [Account(type: AccountType.github, value: 'aligit')],
);

void main() {
  Future<ProfileStore> pumpApp(WidgetTester tester, List<Profile> profiles,
      {Locale locale = const Locale('tr')}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = (await tester.runAsync(() => testStore(profiles)))!;
    await tester.pumpWidget(KartvizitApp(store: store));
    await tester.pumpAndSettle();
    return store;
  }

  ButtonStyleButton shareButton(WidgetTester tester, String label) => tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text(label), matching: find.bySubtype<ButtonStyleButton>()).first);

  testWidgets('no cards shows create prompt', (tester) async {
    await pumpApp(tester, []);
    expect(find.text('Kartını oluşturmak için bilgilerini ekle'), findsOneWidget);
    expect(find.text('Profili oluştur'), findsOneWidget);
  });

  testWidgets('two accounts on the same platform are separate tiles', (tester) async {
    await pumpApp(tester, [personal]);
    expect(find.text('Rehbere ekle'), findsOneWidget);
    expect(find.text('Instagram'), findsNWidgets(2));
    expect(find.text('@ali'), findsOneWidget);
    expect(find.text('İş · @ali_is'), findsOneWidget);
  });

  testWidgets('selection toggles and updates share button', (tester) async {
    await pumpApp(tester, [personal]);
    expect(shareButton(tester, 'Paylaş (0)').onPressed, isNull);
    await tester.tap(find.text('@ali'));
    await tester.tap(find.text('İş · @ali_is'));
    await tester.pump();
    expect(shareButton(tester, 'Paylaş (2)').onPressed, isNotNull);
    await tester.tap(find.text('@ali'));
    await tester.pump();
    expect(find.text('Paylaş (1)'), findsOneWidget);
  });

  testWidgets('switching cards shows that card and clears selection', (tester) async {
    final store = await pumpApp(tester, [personal, work]);
    await tester.tap(find.text('@ali'));
    await tester.pump();
    await tester.tap(find.text('İş').first);
    await tester.pumpAndSettle();
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Instagram'), findsNothing);
    expect(find.text('Paylaş (0)'), findsOneWidget);
    expect(store.activeId, 'w');
  });

  testWidgets('create profile flow shows the card after saving', (tester) async {
    final store = await pumpApp(tester, []);
    await tester.tap(find.text('Profili oluştur'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field_fullName')), 'Ali Veli');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Ali Veli'), findsWidgets);
    expect(find.text('Kartım'), findsOneWidget);
    expect(store.loadAll(), hasLength(1));
  });

  testWidgets('share opens share screen with the selected payload', (tester) async {
    const channel = MethodChannel('kartvizit/hce');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async => call.method == 'status' ? 'ready' : null);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await pumpApp(tester, [personal]);
    await tester.tap(find.text('İş · @ali_is'));
    await tester.pump();
    await tester.tap(find.text('Paylaş (1)'));
    await tester.pumpAndSettle();

    final share = tester.widget<ShareScreen>(find.byType(ShareScreen));
    expect(share.payload.qrText, 'https://instagram.com/ali_is');
    expect(share.items.map((i) => i.key), ['acc:1']);
  });

  testWidgets('english fallback for non-turkish device', (tester) async {
    await pumpApp(tester, [personal], locale: const Locale('de'));
    expect(find.text('Add to contacts'), findsOneWidget);
    expect(find.text('Share (0)'), findsOneWidget);
  });
}
