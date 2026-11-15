package dev.kartvizit.dijital_kartvizit

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.nfc.NfcAdapter
import android.nfc.cardemulation.CardEmulation
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val adapter: NfcAdapter? by lazy { NfcAdapter.getDefaultAdapter(this) }
    private val service by lazy { ComponentName(this, NdefHceService::class.java) }

    private val hasHce: Boolean by lazy {
        packageManager.hasSystemFeature(PackageManager.FEATURE_NFC_HOST_CARD_EMULATION)
    }

    // CardEmulation.getInstance throws on devices with NFC but without HCE.
    private val cardEmulation: CardEmulation? by lazy {
        adapter?.takeIf { hasHce }?.let { CardEmulation.getInstance(it) }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kartvizit/hce")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(status())
                    "start" -> {
                        HceState.session.start(call.arguments as ByteArray)
                        cardEmulation?.setPreferredService(this, service)
                        result.success(null)
                    }
                    "stop" -> {
                        HceState.session.stop()
                        cardEmulation?.unsetPreferredService(this)
                        result.success(null)
                    }
                    "openNfcSettings" -> {
                        startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun status(): String {
        val a = adapter
        return when {
            a == null || !hasHce -> "unsupported"
            !a.isEnabled -> "disabled"
            else -> "ready"
        }
    }

    // Share only while the app is in front: pause hides the tag, resume brings it
    // back. Android also wants the preferred service set/cleared here.
    override fun onResume() {
        super.onResume()
        HceState.session.onResume()
        if (HceState.session.isSharing) cardEmulation?.setPreferredService(this, service)
    }

    override fun onPause() {
        HceState.session.onPause()
        cardEmulation?.unsetPreferredService(this)
        super.onPause()
    }

    // The Flutter UI (and its share screen) goes away with the activity.
    override fun onDestroy() {
        HceState.session.stop()
        super.onDestroy()
    }
}
