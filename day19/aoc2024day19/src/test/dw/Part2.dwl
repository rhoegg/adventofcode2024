%dw 2.0
output application/json

import * from dw::core::Arrays
import mergeWith from dw::core::Objects
import * from MySolution

var sampleChallenge = parseChallenge(sampleInput)
var challenge = parseChallenge(rawInput)

var trySample = sampleChallenge.designs reduce (design, state = {results: [], cache: {}}) -> do {
    var thisResult = countTowelCombos(sampleChallenge.patterns, design, state.cache)
    ---
    {
        results: state.results << {
            design: design,
            combos: thisResult.combinations
        },
        cache: state.cache mergeWith thisResult.cache
    }
}
var part2 = (challenge.designs) reduce (design, state = {results: [], cache: {}}) -> do {
    var thisResult = countTowelCombos(challenge.patterns, design)
    ---
    {
        results: state.results << {
            design: design,
            combos: thisResult.combinations
        },
        cache: thisResult.cache
    }
}
---
// countTowelCombos(sampleChallenge.patterns, sampleChallenge.designs[1])
sum(part2.results.combos)
// sizeOf(challenge.designs)
