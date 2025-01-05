%dw 2.0
import * from dw::core::Arrays
import * from Geometry
import * from MySolution

var part2Race = parseRacetrack(rawInput)
var savings = 100

var raceInfo = race(part2Race)
var fullPath = (raceInfo.visited << part2Race.end) take 3500
var potentialCheats = fullPath flatMap (start, startIndex) -> 
        (fullPath drop (startIndex + savings)) map (end, endIndex) ->
            {
                start: start,
                startIndex: startIndex,
                end: end,
                endIndex: startIndex + endIndex + savings,
            }
// var cheats = potentialCheats filter (manhattanDistance($.start, $.end) <= ($.endIndex - $.startIndex - savings))

// var cheats = usefulCheats map (cheat) -> {
//     start: cheat.start,
//     end: cheat.end,
//     saved: (cheat.endIndex - cheat.startIndex) - cheat.distance
// }
---
// (cheats countBy (cheat) -> cheat.saved >= 100) 
// 41.381 seconds without computing manhattan distance
sizeOf(potentialCheats)
// (cheats groupBy (cheat) -> cheat.endIndex - cheat.startIndex - manhattanDistance(cheat.start, cheat.end))
//     mapObject { ($$): sizeOf($) }
// 12.157 seconds
// sizeOf((0 to 9000) flatMap(i) -> ((i + 100) to 9000) map (j) -> {i: i, j: j})


