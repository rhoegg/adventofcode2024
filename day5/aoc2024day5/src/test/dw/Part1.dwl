
%dw 2.0
output application/json

import * from MySolution
var plan = parsePlan(rawInput)
var correctUpdates = plan.updates filter (update) -> 
    correctOrder(plan.rules, update)
---
sum(correctUpdates map (update) -> do {
    var middleIndex = floor(sizeOf(update) / 2)
    ---
    update[middleIndex] as Number
})