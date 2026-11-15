package dev.kartvizit.dijital_kartvizit

import org.junit.Assert.assertArrayEquals
import org.junit.Test

class Type4TagTest {
    private fun hex(s: String): ByteArray =
        s.chunked(2).map { it.toInt(16).toByte() }.toByteArray()

    private val ok = hex("9000")
    private val notFound = hex("6A82")
    private val selectApp = hex("00A4040007D276000085010100")
    private val selectCc = hex("00A4000C02E103")
    private val selectNdef = hex("00A4000C02E104")
    private val cc = hex("000F20003B00340406E1047FFF00FF")

    private fun read(offset: Int, le: Int): ByteArray =
        byteArrayOf(0x00, 0xB0.toByte(), (offset shr 8).toByte(), (offset and 0xFF).toByte(), le.toByte())

    private fun tagWith(message: ByteArray?) = Type4Tag().apply { ndefMessage = message }

    @Test
    fun selectApp_withoutMessage_returnsNotFound() {
        assertArrayEquals(notFound, tagWith(null).process(selectApp))
    }

    @Test
    fun selectApp_withoutLeByte_isAccepted() {
        assertArrayEquals(ok, tagWith(hex("D1")).process(hex("00A4040007D2760000850101")))
    }

    @Test
    fun fullReadSequence_returnsCcAndNdef() {
        val message = hex("D101045504616263")
        val tag = tagWith(message)
        assertArrayEquals(ok, tag.process(selectApp))
        assertArrayEquals(ok, tag.process(selectCc))
        assertArrayEquals(cc + ok, tag.process(read(0, 15)))
        assertArrayEquals(ok, tag.process(selectNdef))
        assertArrayEquals(hex("0008") + ok, tag.process(read(0, 2)))
        assertArrayEquals(message + ok, tag.process(read(2, message.size)))
    }

    @Test
    fun readNdef_inChunks_concatenatesToMessage() {
        val message = ByteArray(300) { it.toByte() }
        val tag = tagWith(message)
        tag.process(selectApp)
        tag.process(selectNdef)
        var collected = ByteArray(0)
        var offset = 2
        while (offset < 302) {
            val r = tag.process(read(offset, 59))
            assertArrayEquals(ok, r.copyOfRange(r.size - 2, r.size))
            val data = r.copyOfRange(0, r.size - 2)
            collected += data
            offset += data.size
        }
        assertArrayEquals(message, collected)
    }

    @Test
    fun readPastEnd_clampsToFileEnd() {
        val message = hex("AABBCC")
        val tag = tagWith(message)
        tag.process(selectApp)
        tag.process(selectNdef)
        assertArrayEquals(hex("BBCC") + ok, tag.process(read(3, 59)))
    }

    @Test
    fun readBeforeSelect_returnsNotFound() {
        val tag = tagWith(hex("AA"))
        tag.process(selectApp)
        assertArrayEquals(notFound, tag.process(read(0, 2)))
    }

    @Test
    fun selectFile_beforeSelectApp_returnsNotFound() {
        assertArrayEquals(notFound, tagWith(hex("AA")).process(selectNdef))
    }

    @Test
    fun reset_forgetsSelectedFile() {
        val tag = tagWith(hex("AA"))
        tag.process(selectApp)
        tag.process(selectNdef)
        tag.reset()
        assertArrayEquals(notFound, tag.process(read(0, 2)))
    }

    @Test
    fun unknownCommand_returnsNotFound() {
        assertArrayEquals(notFound, tagWith(hex("AA")).process(hex("00CA000000")))
    }
}
