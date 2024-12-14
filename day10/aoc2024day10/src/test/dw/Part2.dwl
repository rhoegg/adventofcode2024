%dw 2.0
output application/json

import * from MySolution
var lavaIslandMap = parseMap(rawInput)
var hikingTrails = trailheads(lavaIslandMap) map (trailhead) ->
    sizeOf(distinctTrails(lavaIslandMap, [trailhead]))
---
sum(hikingTrails)