%dw 2.0
import * from dw::core::Arrays
output application/json

import * from MySolution

var clawMachines = parseClawMachines(rawInput)
// var prizeWinningPlans = clawMachines map (m) -> (winningPlans(m) minBy (plan) -> tokens(plan))
var prizeWinningPlans = (clawMachines map (m) -> algebraicPlan(m)) 
    filter (plan) -> 
        isInteger(plan.a) and isInteger(plan.b)
        and plan.a <= 100 and plan.b <= 100
---

prizeWinningPlans sumBy (plan) -> tokens(plan)