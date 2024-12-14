%dw 2.0
output application/json

import * from MySolution
var lavaIslandMap = parseMap(rawInput)
var hikingTrails = trailheads(lavaIslandMap) map (trailhead) -> {
    trailhead: trailhead,
    reachable: reachableNines(lavaIslandMap, [trailhead])
}
var scoredTrailheads = hikingTrails map (t) -> t  update {
    case r at .reachable -> sizeOf(r)
}
---
sum(scoredTrailheads map $.reachable)