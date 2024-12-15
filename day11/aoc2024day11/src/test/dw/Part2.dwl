%dw 2.0
import * from MySolution
output application/json
var blinks = 75
---
{
    count: countStones(myInput, blinks).count,
    // fasterBlink: sizeOf(fasterBlink(sampleInput, blinks).stones),
    // // stones: fasterBlink(sampleInput, blinks).stones,
    // fasterBlinkCache: fasterBlink(sampleInput, blinks).cache mapObject(v, k) -> {(k) : sizeOf(v)},
    // countCache: countStones(sampleInput, blinks).cache
}