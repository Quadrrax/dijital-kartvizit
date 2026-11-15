import 'package:dijital_kartvizit/sharing/hce_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('kartvizit/hce');
  final calls = <MethodCall>[];
  String statusReply = 'ready';

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'status' ? statusReply : null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('status maps strings to NfcStatus', () async {
    for (final (reply, expected) in [
      ('disabled', NfcStatus.disabled),
      ('ready', NfcStatus.ready),
      ('unsupported', NfcStatus.unsupported),
    ]) {
      statusReply = reply;
      expect(await const HceChannel().status(), expected);
    }
  });

  test('start sends ndef bytes', () async {
    final bytes = Uint8List.fromList([0xD1, 0x01, 0x02]);
    await const HceChannel().start(bytes);
    expect(calls.single.method, 'start');
    expect(calls.single.arguments, bytes);
  });

  test('stop invokes stop', () async {
    await const HceChannel().stop();
    expect(calls.single.method, 'stop');
  });

  test('openNfcSettings invokes openNfcSettings', () async {
    await const HceChannel().openNfcSettings();
    expect(calls.single.method, 'openNfcSettings');
  });
}
