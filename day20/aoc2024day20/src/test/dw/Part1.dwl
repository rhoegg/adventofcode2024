%dw 2.0
output application/json

import * from dw::core::Arrays
import * from MySolution

var sampleRace = parseRacetrack(sampleInput)
var part1Race = parseRacetrack(rawInput)

var racetrack = part1Race
var raceInfo = race(racetrack)
// var cheats1 = (0 to raceInfo.elapsed - 1) map (cheatStep) -> do {
//     var elapsed = cheatStep
//     var cheatTime = cheat(racetrack  update {
//         case .start -> log("cheating at step $(elapsed)", raceInfo.visited[cheatStep])
//     }, cheatStep, raceInfo.visited take cheatStep, 2)
//     var bestTime = if (cheatTime > 0) cheatTime else elapsed
//     ---
//     {
//         step: cheatStep,
//         bestTime: bestTime,
//         saved: raceInfo.elapsed - bestTime
//     }
// }
// var cheats = (0 to raceInfo.elapsed - 1) map (cheatStep) -> do {
//     var elapsed = cheatStep
//     var cheatTime = fastestTime(racetrack  update {
//         case .start -> raceInfo.visited[cheatStep]
//     }, cheatStep, 2)
//     var bestTime = if (cheatTime > 0) cheatTime else elapsed
//     ---
//     {
//         step: cheatStep,
//         bestTime: bestTime,
//         saved: raceInfo.elapsed - bestTime
//     }
// }
var cheats = findCheats(racetrack, raceInfo.visited) map {
    start: $.start,
    end: $.end,
    saved: raceInfo.elapsed - $.duration
}
---
// fastestTime(racetrack  update {
//     case .start -> {x: 9, y: 7}
// }, 20, 2)
// oh! We need all the cheats, not just the fastest ones
// (cheats groupBy ($.saved) pluck (v, k) -> {
//     saved: k as Number,
//     cheats: sizeOf(v)
// }) orderBy $.saved
cheats countBy ($.saved >= 100)
