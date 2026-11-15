package dev.kartvizit.dijital_kartvizit

/**
 * NFC Forum Type 4 Tag emulation (read-only). Pure logic, no Android types,
 * so it can be unit tested on the JVM. [ndefMessage] null means "not sharing":
 * the tag then refuses to be selected at all.
 */
class Type4Tag {
    @Volatile
    var ndefMessage: ByteArray? = null

    private var appSelected = false
    private var selectedFile: ByteArray? = null

    fun process(apdu: ByteArray): ByteArray {
        val message = ndefMessage
        if (startsWith(apdu, SELECT_APP)) {
            appSelected = message != null
            selectedFile = null
            return if (appSelected) OK else NOT_FOUND
        }
        if (!appSelected || message == null) return NOT_FOUND
        if (apdu.contentEquals(SELECT_CC)) {
            selectedFile = CC_FILE
            return OK
        }
        if (apdu.contentEquals(SELECT_NDEF)) {
            selectedFile = byteArrayOf((message.size shr 8).toByte(), message.size.toByte()) + message
            return OK
        }
        if (apdu.size >= 5 && apdu[0] == 0x00.toByte() && apdu[1] == 0xB0.toByte()) {
            val file = selectedFile ?: return NOT_FOUND
            val offset = ((apdu[2].toInt() and 0xFF) shl 8) or (apdu[3].toInt() and 0xFF)
            val le = (apdu[4].toInt() and 0xFF).let { if (it == 0) 256 else it }
            if (offset > file.size) return NOT_FOUND
            return file.copyOfRange(offset, minOf(offset + le, file.size)) + OK
        }
        return NOT_FOUND
    }

    fun reset() {
        appSelected = false
        selectedFile = null
    }

    private fun startsWith(a: ByteArray, prefix: ByteArray): Boolean =
        a.size >= prefix.size && a.copyOfRange(0, prefix.size).contentEquals(prefix)

    private companion object {
        fun hex(s: String): ByteArray = s.chunked(2).map { it.toInt(16).toByte() }.toByteArray()

        val OK = hex("9000")
        val NOT_FOUND = hex("6A82")
        val SELECT_APP = hex("00A4040007D2760000850101")
        val SELECT_CC = hex("00A4000C02E103")
        val SELECT_NDEF = hex("00A4000C02E104")
        val CC_FILE = hex("000F20003B00340406E1047FFF00FF")
    }
}

/** Shared between MainActivity (controls the session) and NdefHceService (serves the tag). */
object HceState {
    val tag = Type4Tag()
    val session = HceSession(tag)
}
