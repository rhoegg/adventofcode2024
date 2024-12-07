%dw 2.0
output application/json
import * from Geometry
import * from MySolution
var map = parseMap(rawInput)
var walked = walkLabGuard1518(map, map.start)
---
sizeOf(walked distinctBy $)
