%dw 2.0
import * from dw::core::Arrays
output application/json

import * from MySolution

var situation = parseSituation(rawInput)
var anticipated = anticipate(situation)

---
anticipated.warehouse.boxes sumBy (box) -> 100 * box.y + box.x