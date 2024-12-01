%dw 2.0
output application/json

import * from MySolution
var sortedLists = lists(rawInput) map (list) -> (list orderBy $)
var diffs = zip(sortedLists[0], sortedLists[1]) map (pair: Array<Number>) ->
    abs(pair[0] - pair[1])
---
sum(diffs)