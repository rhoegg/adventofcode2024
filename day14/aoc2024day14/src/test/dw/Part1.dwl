%dw 2.0
output application/json

import * from Geometry
import * from MySolution
var realRoom: Dimensions = {
    width: 101,
    height: 103
}
var sampleRoom: Dimensions = {
    width: 11,
    height: 7
}
var room = realRoom
var elapsed = 100
var movedRobots = parseRobots(rawInput) map (r) -> 
    move(r, elapsed) update {
        case p at .position -> {
            x: p.x posmod room.width,
            y: p.y posmod room.height
        }
}
var sectioned = movedRobots map (r) ->
    {
        x: sgn(r.position.x - ((room.width - 1) / 2)),
        y: sgn(r.position.y - ((room.height - 1) / 2))
    }

var sectionCounts = (sectioned groupBy (p) -> s(p))
    pluck (robots, p) -> {
        position: p,
        count: sizeOf(robots)
    }
---
(sectionCounts filter (section) -> not (section.position contains "0"))
    reduce (n, p = 1) -> n.count * p