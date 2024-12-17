%dw 2.0
import * from dw::core::Arrays
import * from MySolution
output application/json

var situation = parseSecondSituation(rawInput)
var oneMove = moveBig(situation.warehouse, "<")
var fiveMoves = (1 to 5) reduce (i, warehouse = situation.warehouse) ->
    moveBig(warehouse, "<")
var anticipated = anticipateBig(situation)
---
{
    gps: anticipated.warehouse.boxes sumBy (box) -> 100 * box.l.y + box.l.x,
    warehouse: printBigWarehouse(anticipated.warehouse)
}

// now do anticipate