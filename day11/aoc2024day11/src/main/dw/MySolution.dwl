%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

var sampleInput = [125, 17]
var myInput = (readUrl("classpath://puzzle-input.txt", "text/plain") splitBy " ") map (s) -> s as Number

fun blink(stones: Array<Number>): Array<Number> =
    stones flatMap (stone) -> 
        if (stone == 0) [1]
        else do {
            var digits = stone as String
            ---
            if (isEven(sizeOf(digits))) do {
                var halves = digits substringEvery (sizeOf(digits) / 2)
                ---
                halves map (newStone) -> newStone as Number
            } else [stone * 2024]
        }

fun repeatBlink(stones: Array<Number>, n = 0) =
    if (n == 0) stones
    else repeatBlink(blink(stones), n - 1)

fun fasterBlink(stones: Array<Number>, n = 0, cache = {}) =
    stones

fun fasterBlink(stone: Number, n = 0, cache = {}) = do {
    var cacheKey = "$(stone):$(n)"
    ---
    if (cache[cacheKey]?) cache[cacheKey]
    else do {
        0
    }
}
    