%dw 2.0
import * from dw::core::Arrays
output application/json

import * from MySolution

var adjustment = 10000000000000

var clawMachines = parseClawMachines(rawInput)
var correctedClawMachines = clawMachines map (m) -> m  update {
    case prize at .prize -> {
        x: adjustment + prize.x,
        y: adjustment + prize.y
    }
}

var prizeWinningPlans = (correctedClawMachines map (m) -> algebraicPlan(m)) 
    filter (plan) -> isInteger(plan.a) and isInteger(plan.b)
---
prizeWinningPlans sumBy (plan) -> tokens(plan)