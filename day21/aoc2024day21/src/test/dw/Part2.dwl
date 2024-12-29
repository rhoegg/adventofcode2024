%dw 2.0
import * from MySolution

//sample 154115708116294

// 82050061710, 72242026390, 81251039228, 80786362258, 77985628636
var codes = parseCodes(sampleInput)
var solution = codes map (code) -> do {
  var shortest = shortestNumericPath(code).buttonPresses as String
  var numeric = code[0 to 2]
  ---
  {
    code: code,
    numeric: numeric as Number,
    buttonPresses: shortest,
    length: sizeOf(shortest)
  } 
}

// this will get way too big
fun additionalRobots(targetButtons: String, count: Number) =
    if (count < 2) targetButtons
    else (1 to count) reduce (i, buttons = targetButtons) ->
        buttonsNeeded(buttons)
---
// solution map (item) -> {
//     code: item.code,
//     numeric: item.numeric,
//     oldButtons: item.buttonPresses,
//     newButtons: buttonsNeeded(item.buttonPresses),
//     buttons23: additionalRobots(item.buttonPresses, 23)
// }
sizeOf(additionalRobots())