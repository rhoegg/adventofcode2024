%dw 2.0
output application/json

import * from MySolution
var doSegments = segments(rawInput) filter (seg) -> ! (seg startsWith "don't()")
---
sum(doSegments flatMap (seg) -> products(seg))