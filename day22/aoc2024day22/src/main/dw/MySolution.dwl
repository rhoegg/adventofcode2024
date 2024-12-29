%dw 2.0
import * from Bitwise

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

fun mix(secret: Number, n: Number): Number = secret XOR n
fun prune(n: Number): Number = n mod 16777216
// 4096^2

fun next(secret: Number): Number = do { 
    var step1 = prune(secret mix (64 * secret))
    var step2 = prune(step1 mix (floor(step1 / 32)))
    var step3 = prune(step2 mix (2048 * step2))
    ---
    step3
}

fun predictSecret(n: Number, count: Number, cache={priors: []}): Number =
    if (count == 0) n
    else predictSecret(next(n), count - 1, cache update {
        case p at .priors -> n >> p
    })