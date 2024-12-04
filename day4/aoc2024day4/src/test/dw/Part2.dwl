%dw 2.0
output application/json

import * from MySolution
var skewedDownCandidates = 
    findMAS(skewedDown(wordSearch)) flatMap (found, i) ->
        found map (startIndex) -> do {
            var aIndex = startIndex + 1
            ---
            {
                x: aIndex,
                y: i - aIndex
            }
        }
var skewedUpCandidates =
    findMAS(skewedUp(wordSearch)) flatMap (found, i) ->
        found map (startIndex) -> do {
            var aIndex = startIndex + 1
            ---
            {
                x: aIndex,
                y: i - (sizeOf(wordSearch[0]) - aIndex) + 1
            }
        }
---
sizeOf(
    skewedDownCandidates filter (c) ->
        skewedUpCandidates contains c
)