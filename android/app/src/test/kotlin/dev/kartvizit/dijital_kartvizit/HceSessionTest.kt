package dev.kartvizit.dijital_kartvizit

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class HceSessionTest {
    private val msg = byteArrayOf(1, 2, 3)

    private fun resumedSession(): Pair<Type4Tag, HceSession> {
        val tag = Type4Tag()
        return tag to HceSession(tag).apply { onResume() }
    }

    @Test
    fun start_whileResumed_servesMessage() {
        val (tag, s) = resumedSession()
        s.start(msg)
        assertArrayEquals(msg, tag.ndefMessage)
        assertTrue(s.isSharing)
    }

    @Test
    fun pause_stopsServing_resumeRestores() {
        val (tag, s) = resumedSession()
        s.start(msg)
        s.onPause()
        assertNull(tag.ndefMessage)
        s.onResume()
        assertArrayEquals(msg, tag.ndefMessage)
    }

    @Test
    fun stop_clearsMessageForGood() {
        val (tag, s) = resumedSession()
        s.start(msg)
        s.stop()
        s.onPause()
        s.onResume()
        assertNull(tag.ndefMessage)
        assertFalse(s.isSharing)
    }

    @Test
    fun start_whilePaused_servesOnlyAfterResume() {
        val tag = Type4Tag()
        val s = HceSession(tag)
        s.start(msg)
        assertNull(tag.ndefMessage)
        s.onResume()
        assertArrayEquals(msg, tag.ndefMessage)
    }
}
