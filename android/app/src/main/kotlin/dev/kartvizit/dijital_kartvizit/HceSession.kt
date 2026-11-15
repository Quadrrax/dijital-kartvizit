package dev.kartvizit.dijital_kartvizit

/**
 * Decides when [tag] actually serves the message: only while Dart has a share
 * screen open ([start]..[stop]) AND the activity is in the foreground. Leaving
 * the app (Home, lock screen) pauses sharing; coming back resumes it.
 */
class HceSession(private val tag: Type4Tag) {
    private var message: ByteArray? = null
    private var resumed = false

    val isSharing: Boolean get() = message != null

    fun start(bytes: ByteArray) {
        message = bytes
        if (resumed) tag.ndefMessage = bytes
    }

    fun stop() {
        message = null
        tag.ndefMessage = null
    }

    fun onResume() {
        resumed = true
        tag.ndefMessage = message
    }

    fun onPause() {
        resumed = false
        tag.ndefMessage = null
    }
}
