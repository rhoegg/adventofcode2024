%dw 2.0
output application/json

import * from dw::core::Arrays
import * from dw::ext::pq::PriorityQueue
import * from MySolution
/* +---+---+---+
 * | 7 | 8 | 9 |
 * +---+---+---+
 * | 4 | 5 | 6 |
 * +---+---+---+
 * | 1 | 2 | 3 |
 * +---+---+---+
 *     | 0 | A |
 *     +---+---+
 *    ROBOT
 *
 *     +---+---+
 *     | ^ | A |
 * +---+---+---+
 * | < | v | > |
 * +---+---+---+
 *    ROBOT
 *
 *     +---+---+
 *     | ^ | A |
 * +---+---+---+
 * | < | v | > |
 * +---+---+---+
 *    ROBOT
 *
 *     +---+---+
 *     | ^ | A |
 * +---+---+---+
 * | < | v | > |
 * +---+---+---+
 *     ME
 */

var codes = parseCodes(rawInput)
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
// 79156 is too low - 45s timeout!
---
solution sumBy (item) -> (item.length * item.numeric)


