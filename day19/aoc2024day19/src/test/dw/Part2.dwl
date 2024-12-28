%dw 2.0
output application/json

import * from dw::core::Arrays
import * from MySolution

var sampleChallenge = parseChallenge(sampleInput)
var challenge = parseChallenge(rawInput)

var trySample = sampleChallenge.designs map (design) -> {
    design: design,
    combos: countCombos(design, sampleChallenge.patterns)
}
---
(challenge.designs take 3) map (design) -> {
    design: design,
    combos: countCombos(design, challenge.patterns)
}