import 'package:flutter/services.dart';

enum NfcStatus { unsupported, disabled, ready }

/// Bridge to the Android NFC card-emulation service (see MainActivity.kt).
class HceChannel {
  const HceChannel([this._channel = const MethodChannel('kartvizit/hce')]);

  final MethodChannel _channel;

  Future<NfcStatus> status() async {
    final s = await _channel.invokeMethod<String>('status');
    return NfcStatus.values.byName(s ?? 'unsupported');
  }

  /// Starts serving [ndefMessage] to phones that tap this one.
  Future<void> start(Uint8List ndefMessage) => _channel.invokeMethod('start', ndefMessage);

  Future<void> stop() => _channel.invokeMethod('stop');

  Future<void> openNfcSettings() => _channel.invokeMethod('openNfcSettings');
}
