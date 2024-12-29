%dw 2.0
import dw::core::Numbers
import dw::core::Strings

// adapted from mjones2219 post here: https://help.mulesoft.com/s/question/0D52T00004vZ0xYSAS/does-dataweave-2-support-bitwise-operators
 
fun AND(lo: Number, ro: Number): Number = do {
    var binary = getBinary(lo, ro)
    ---
    Numbers::fromBinary(binary.l map ($ as Number * binary.r[$$] as Number) reduce ($$++$))
}
 
fun OR(lo: Number, ro: Number): Number = do {
    var binary = getBinary(lo, ro)
    ---
    Numbers::fromBinary((binary.l map (if ($ == "1" or binary.r[$$] == "1") "1" else "0") reduce ($$++$)) default "")
}
 
fun XOR(lo: Number, ro: Number): Number = do {
    var binary = getBinary(lo, ro)
    ---
    Numbers::fromBinary((binary.l map (if ($ == binary.r[$$]) "0" else "1") reduce ($$++$)) default "")
}
 
fun getBinary(lo: Number, ro: Number): Pair<Array<String>, Array<String>> = do {
    var loB = Numbers::toBinary(lo)
    var roB = Numbers::toBinary(ro)
    var size = max([sizeOf(loB), sizeOf(roB)]) default 0
    ---
    { 
        l: Strings::leftPad(loB, size, '0') splitBy '',
        r: Strings::leftPad(roB, size, '0') splitBy ''
    }
}