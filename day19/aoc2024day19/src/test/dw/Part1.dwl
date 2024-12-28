%dw 2.0
output application/json

import * from dw::core::Arrays
import * from MySolution
import * from dw::util::Timer

var sampleChallenge = parseChallenge(sampleInput)
var challenge = parseChallenge(rawInput)

var results = challenge.designs map (design) -> {
    design: design,
    possible: possible3([design], challenge.patterns).result
}
// var patterns2 = challenge.patterns ++ (challenge.patterns flatMap (p) -> challenge.patterns map (p2) -> p ++ p2)
---
    // array: duration(() -> patterns3 contains "brrrgbg"),
    // object: duration(() -> patternsObject3["brrrgbg"] default false)
    // LEARNED: object test is faster than array contains
{
    part1: results countBy (result) -> result.possible
}


