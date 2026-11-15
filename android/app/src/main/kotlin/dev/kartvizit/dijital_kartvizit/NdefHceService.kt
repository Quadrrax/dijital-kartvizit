package dev.kartvizit.dijital_kartvizit

import android.nfc.cardemulation.HostApduService
import android.os.Bundle

/** Lets another phone read this one as an NFC Type 4 tag. */
class NdefHceService : HostApduService() {
    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray =
        HceState.tag.process(commandApdu)

    override fun onDeactivated(reason: Int) {
        HceState.tag.reset()
    }
}
