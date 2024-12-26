%dw 2.0
output application/json

import * from dw::core::Arrays
import * from Bitwise
import * from MySolution

var computer = parseProgramInfo(rawInput)
// bst A: a mod 8 -> b
// bxl 5: b xor 5 -> b (reverses)
// cdv B: a / 2^B -> c (multiply reverses)
// bxc 3: b xor c -> b (reverses)
// bxl 6: b xor 6 -> b (reverses)
// adv 3: a / 2^3 -> a <-- this will help! we need sizeOf(program) loops
// out B
// loop

// lower limit is defined by number of loops -> number of digits in output minus 1 -> 17
var lowerLimitA = 8 pow (sizeOf(computer.program) - 1)
var proveLoops = (1 to 16) reduce (n, a = lowerLimitA) -> floor(a / 8)

var lastOutput = computer.program[-1]
fun findFirstZero(i = 0): Number = do {
    var a = lowerLimitA + i
    var c = computer  update {
        case .a -> a
    }
    var result = run(c)
    ---
    if (log(result.programOutput[-1]) == 0) i
    else if (i > 1000) log("giving up", i)
    else findFirstZero(i + 1)
}

fun viewOperation() = (0 to 15) map (a) -> do {
    var b1 = a mod 8
    var b2 = b1 XOR 5
    var c = floor(a / 2 pow b2)
    var b3 = b2 XOR c
    var b4 = b3 XOR 6
    ---
    {
        a: a,
        b1: b1,
        b2: b2,
        c: c,
        b3: b3,
        b4: b4
    }
}

fun findFirstLoop(i = 0): Number = do {
    var a = i
    var c = computer  update {
        case .a -> a
    }
    var result = run(c)
    ---
    if (log(result.programOutput) == [3, 0]) i
    else if (i > 1000) log("giving up", i)
    else findFirstLoop(i + 1)
}

fun aAfter(a, loops) = 
    (1 to loops) reduce (n, a1 = a) -> floor(a1 / 8)

fun findAValue(base: Number, digit: Number): Number | Null =
    if (digit == -1) base
    else do {
        var newDigitOptions = (0 to 7) filter (coefficient) -> do {
            var a = base + coefficient * (8 pow digit)
            var programOutput = run(computer update {case .a -> a}).programOutput
            var forLog = if (programOutput[digit] == computer.program[digit] and digit < 2) 
                log("[$(digit):$(coefficient)] $(a)", programOutput joinBy ",")
                else 0
            ---
            programOutput[digit] == computer.program[digit]
        } 
        ---
        if (isEmpty(newDigitOptions)) null
        else do {
            fun newBase(d) = base + d * (8 pow digit)
            var aValues = newDigitOptions map (newDigit) ->
                findAValue(newBase(newDigit), digit - 1)
            var goodAValues = aValues filter (a) -> a != null
            ---
            aValues[0]
        }
    }
---
findAValue(0, 15)
// run(computer update {case .a -> 105692702703616}).programOutput
// findAValue(105692702703616, 10)

// to finish, a < 8
// last b == 0 (out b)
// step back -> b == 6
// step back -> b xor c == 6
// step back -> a / 2^b xor b == 6
// step back -> a / 2^(b xor 5)
// (a mod 8 xor 5)
// ((0 to 16) map (i) -> {i: i, computer: (computer update { case .a -> i })}) map (x) ->
//     x update { case c at .computer -> run(c).programOutput }
// findFirstZero()
// findFirstLoop() -> a=24 to output 3,0 at the end
// so, 24 / 2^3 == 3 / 2^3 == 0
// run(computer update {
//     case .a -> (24 * (8 pow 14))
// })

// 136933420830472 is too high
// 105734774294936 is too low