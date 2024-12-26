%dw 2.0
import * from dw::core::Arrays
import * from MySolution
output application/json


var sampleChallenge = {
    corrupted: parseListOfBytes(sampleInput),
    dimensions: {width: 7, height: 7}
}
var challenge = {
    corrupted: parseListOfBytes(rawInput),
    dimensions: {width: 71, height: 71}
}

fun findFirstBlocker(memorySpace: MemorySpace, bytesFallen: Number = 1) =
    if (bytesFallen > sizeOf(memorySpace.corrupted)) null
    else do {
        var interimMemorySpace = memorySpace update {
            case c at .corrupted -> c take bytesFallen
        }
        var distanceToExit = shortestEscape(interimMemorySpace)
        var latestByte = memorySpace.corrupted[bytesFallen - 1]
        ---
        if (distanceToExit == -1) do {
            var forLog = log("found after $(bytesFallen)")
            ---
            latestByte
        }
        else findFirstBlocker(memorySpace, bytesFallen + 1)
    }
---

findFirstBlocker(challenge, 3000) // binary search starting at the end