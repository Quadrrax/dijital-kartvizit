import 'package:dijital_kartvizit/app.dart';
import 'package:dijital_kartvizit/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, Profile p, {Locale locale = const Locale('tr')}) async {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final store = await tester.runAsync(() => testStore(p));
    await tester.pumpWidget(KartvizitApp(store: store!));
    await tester.pumpAndSettle();
  }

  FilledButton shareButton(WidgetTester tester, String label) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, label));

  testWidgets('empty profile shows create prompt', (tester) async {
    await pumpApp(tester, Profile.empty);
    expect(find.text('Kartını oluşturmak için bilgilerini ekle'), findsOneWidget);
    expect(find.text('Profili oluştur'), findsOneWidget);
  });

  testWidgets('shows only filled items', (tester) async {
    await pumpApp(tester, const Profile(fullName: 'Ali Veli', instagram: 'ali'));
    expect(find.text('Ali Veli'), findsOneWidget);
    expect(find.text('Rehbere ekle'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('GitHub'), findsNothing);
  });

  testWidgets('selection toggles and updates share button', (tester) async {
    await pumpApp(tester, const Profile(fullName: 'Ali Veli', instagram: 'ali'));
    expect(shareButton(tester, 'Paylaş (0)').onPressed, isNull);

    await tester.tap(find.text('Rehbere ekle'));
    await tester.tap(find.text('Instagram'));
    await tester.pump();
    expect(shareButton(tester, 'Paylaş (2)').onPressed, isNotNull);

    await tester.tap(find.text('Instagram'));
    await tester.pump();
    expect(find.text('Paylaş (1)'), findsOneWidget);
  });

  testWidgets('create profile flow shows the card after saving', (tester) async {
    await pumpApp(tester, Profile.empty);
    await tester.tap(find.text('Profili oluştur'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field_fullName')), 'Ali Veli');
    await tester.enterText(find.byKey(const Key('field_github')), 'ali');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('Ali Veli'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
  });

  testWidgets('english fallback for non-turkish device', (tester) async {
    await pumpApp(tester, const Profile(fullName: 'Ali Veli'), locale: const Locale('de'));
    expect(find.text('Add to contacts'), findsOneWidget);
    expect(find.text('Share (0)'), findsOneWidget);
  });
}
