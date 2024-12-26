%dw 2.0
import * from dw::core::Arrays
output application/json

import * from MySolution

var sampleChallenge = {
    corrupted: parseListOfBytes(sampleInput) take 12,
    dimensions: {width: 7, height: 7}
}
var challenge = {
    corrupted: parseListOfBytes(rawInput) take 1024,
    dimensions: {width: 71, height: 71}
}
---
// shortestEscape(sampleChallenge)
shortestEscape(challenge)