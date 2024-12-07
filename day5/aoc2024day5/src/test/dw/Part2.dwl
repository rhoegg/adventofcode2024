
%dw 2.0
output application/json

import * from MySolution
var plan = parsePlan(rawInput)
var incorrectUpdates = plan.updates filter (update) -> 
    not correctOrder(plan.rules, update)
var fixed = incorrectUpdates map (u) -> fixUpdate(u, plan.rules)
---
sum(fixed map (u) -> do {
    var middleIndex = floor(sizeOf(u) / 2)
    ---
    u[middleIndex] as Number
})