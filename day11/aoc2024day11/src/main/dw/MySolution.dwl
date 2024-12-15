%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Objects
import * from dw::core::Strings

var sampleInput = [125, 17]
var myInput = (readUrl("classpath://puzzle-input.txt", "text/plain") splitBy " ") map (s) -> s as Number


fun computeBlink(stone: Number): Array<Number> =
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
fun blink(stones: Array<Number>): Array<Number> =
    stones flatMap (stone) -> computeBlink(stone)
        

fun repeatBlink(stones: Array<Number>, n = 0) =
    if (n == 0) stones
    else repeatBlink(blink(stones), n - 1)

// this has an error, overestimates [2024] after 8 blinks
fun fasterBlink(stones: Array<Number>, n, cache = {}) = if (n == 0) {stones: stones, cache: cache}
    else stones reduce (stone: Number, state = {stones: [] as Array<Number>, cache: cache}) ->
        do {
            var cacheKey = "$(stone):$(n)"
            ---
            if ( cache[cacheKey]? ) { 
                stones: state.stones ++ cache[cacheKey] as Array<Number>,
                cache: state.cache
            } else do {
                var oneBlink = computeBlink(stone)
                var result = fasterBlink(oneBlink, n - 1, state.cache)
                ---
                {
                    stones: state.stones ++ result.stones,
                    cache: result.cache ++ {(cacheKey): result.stones}
                }
            }
        }

fun countStones(stones: Array<Number>, blinks: Number, cache = {}) = if (blinks == 0) {count: sizeOf(stones), cache: cache}
    else stones reduce (stone, state = {count: 0, cache: cache}) ->
        do {
            var cacheKey = "$(stone):$(blinks)"
            ---
            if ( cache[cacheKey]? ) {
                count: state.count + cache[cacheKey] as Number,
                cache: state.cache
            } else do {
                var oneBlink = computeBlink(stone)
                var result = countStones(oneBlink, blinks - 1, state.cache)
                ---
                {
                    count: state.count + result.count,
                    cache: result.cache ++ {(cacheKey): result.count}
                }
            }
        }
    