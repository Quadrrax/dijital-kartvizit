import 'package:dijital_kartvizit/sharing/ndef.dart';
import 'package:dijital_kartvizit/sharing/payload.dart';
import 'package:dijital_kartvizit/sharing/share_item.dart';
import 'package:dijital_kartvizit/ui/share_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../helpers.dart';

void main() {
  const channel = MethodChannel('kartvizit/hce');
  const payload = UriPayload('https://github.com/ali');
  final calls = <MethodCall>[];
  late List<String> statusReplies;

  setUp(() {
    calls.clear();
    statusReplies = ['ready'];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method != 'status') return null;
      return statusReplies.length > 1 ? statusReplies.removeAt(0) : statusReplies.first;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> pumpShare(WidgetTester tester) async {
    await tester.pumpWidget(wrapTr(const ShareScreen(payload: payload, items: [ShareItem.github])));
    await tester.pumpAndSettle();
  }

  testWidgets('renders qr for payload and item labels', (tester) async {
    await pumpShare(tester);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('QR kodu kamerayla okut'), findsOneWidget);
  });

  testWidgets('starts hce with encoded payload', (tester) async {
    await pumpShare(tester);
    final start = calls.where((c) => c.method == 'start').single;
    expect(start.arguments, encodeNdef(payload));
  });

  testWidgets('shows ready state', (tester) async {
    await pumpShare(tester);
    expect(find.text('Diğer telefonu telefonunun arkasına yaklaştır'), findsOneWidget);
  });

  testWidgets('shows unsupported state', (tester) async {
    statusReplies = ['unsupported'];
    await pumpShare(tester);
    expect(find.text('Bu telefon NFC ile paylaşamıyor, QR kodu kullan'), findsOneWidget);
  });

  testWidgets('shows disabled state with settings button', (tester) async {
    statusReplies = ['disabled'];
    await pumpShare(tester);
    expect(find.text('NFC kapalı'), findsOneWidget);
    await tester.tap(find.text("NFC'yi aç"));
    await tester.pump();
    expect(calls.map((c) => c.method), contains('openNfcSettings'));
  });

  testWidgets('refreshes nfc status on resume', (tester) async {
    statusReplies = ['disabled', 'ready'];
    await pumpShare(tester);
    expect(find.text('NFC kapalı'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Diğer telefonu telefonunun arkasına yaklaştır'), findsOneWidget);
  });

  testWidgets('late dispose of a previous share screen does not stop the new one', (tester) async {
    // The new screen's initState runs before the old screen's dispose, as when
    // the user re-opens Share during the back animation.
    await tester.pumpWidget(wrapTr(const ShareScreen(key: ValueKey('a'), payload: payload, items: [ShareItem.github])));
    await tester.pumpWidget(wrapTr(const ShareScreen(key: ValueKey('b'), payload: payload, items: [ShareItem.github])));
    await tester.pumpAndSettle();
    final methods = calls.map((c) => c.method).toList();
    expect(methods.where((m) => m == 'start'), hasLength(2));
    expect(methods.lastIndexOf('stop'), lessThan(methods.lastIndexOf('start')));
    await tester.pumpWidget(const SizedBox()); // close 'b' inside this test
  });

  testWidgets('stops hce on dispose', (tester) async {
    await pumpShare(tester);
    expect(calls.map((c) => c.method), isNot(contains('stop')));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(calls.map((c) => c.method), contains('stop'));
  });
}
