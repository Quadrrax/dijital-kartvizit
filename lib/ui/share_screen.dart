import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/app_localizations.dart';
import '../sharing/hce_channel.dart';
import '../sharing/ndef.dart';
import '../sharing/payload.dart';
import '../sharing/share_item.dart';
import 'item_visuals.dart';
import 'style.dart';

/// Shows the QR code and serves the same payload over NFC while open.
class ShareScreen extends StatefulWidget {
  const ShareScreen({
    super.key,
    required this.payload,
    required this.items,
    this.hce = const HceChannel(),
  });

  final SharePayload payload;
  final List<ShareItem> items;
  final HceChannel hce;

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  NfcStatus? _status;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    widget.hce.start(encodeNdef(widget.payload));
    _refreshStatus();
    // Coming back from the NFC settings page: NFC may be on now.
    _lifecycle = AppLifecycleListener(onResume: _refreshStatus);
  }

  Future<void> _refreshStatus() async {
    final s = await widget.hce.status();
    if (mounted) setState(() => _status = s);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    widget.hce.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GradientScaffold(
      appBar: AppBar(title: Text(l.shareTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final item in widget.items)
                    Chip(
                      avatar: Icon(itemIcon(item), size: 16, color: kIndigo),
                      label: Text(itemLabel(item, l)),
                      backgroundColor: Colors.white,
                      labelStyle: const TextStyle(color: kIndigo, fontWeight: FontWeight.w600),
                      side: BorderSide.none,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: QrImageView(
                  data: widget.payload.qrText,
                  size: 280,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                ),
              ),
              const SizedBox(height: 12),
              Text(l.scanHint, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 20),
              GlassCard(child: _nfc(l)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nfc(AppLocalizations l) {
    final status = _status;
    if (status == null) return const SizedBox(height: 24);
    final (icon, text) = switch (status) {
      NfcStatus.ready => (Icons.nfc, l.nfcReady),
      NfcStatus.disabled => (Icons.nfc, l.nfcDisabled),
      NfcStatus.unsupported => (Icons.qr_code, l.nfcUnsupported),
    };
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ],
        ),
        if (status == NfcStatus.disabled) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: widget.hce.openNfcSettings, child: Text(l.nfcOpenSettings)),
        ],
      ],
    );
  }
}
