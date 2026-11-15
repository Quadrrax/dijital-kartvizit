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

    private fun cardEmulation(): CardEmulation? = adapter?.let { CardEmulation.getInstance(it) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kartvizit/hce")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(status())
                    "start" -> {
                        HceState.tag.ndefMessage = call.arguments as ByteArray
                        cardEmulation()?.setPreferredService(this, service)
                        result.success(null)
                    }
                    "stop" -> {
                        HceState.tag.ndefMessage = null
                        cardEmulation()?.unsetPreferredService(this)
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
            a == null || !packageManager.hasSystemFeature(PackageManager.FEATURE_NFC_HOST_CARD_EMULATION) -> "unsupported"
            !a.isEnabled -> "disabled"
            else -> "ready"
        }
    }

    // Android wants the preferred service set while resumed and cleared on pause.
    override fun onResume() {
        super.onResume()
        if (HceState.tag.ndefMessage != null) cardEmulation()?.setPreferredService(this, service)
    }

    override fun onPause() {
        cardEmulation()?.unsetPreferredService(this)
        super.onPause()
    }
}
