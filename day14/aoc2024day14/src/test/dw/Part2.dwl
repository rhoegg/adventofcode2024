%dw 2.0
output application/json indent=false

import * from Geometry
import * from MySolution
var room: Dimensions = {
    width: 101,
    height: 103
}

var startRobots = parseRobots(rawInput)
---
(0 to 1000) map (t) ->
    startRobots map (r) ->
        move(r, t).position update {
            case x at .x -> x posmod room.width
            case y at .y -> y posmod room.height
        }