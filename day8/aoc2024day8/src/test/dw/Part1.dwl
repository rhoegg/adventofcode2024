%dw 2.0
output application/json

import * from Geometry
import * from MySolution
var map: CityMap = parse(rawInput)

var allAntinodes = findAntinodes(map)
var uniqueAntinodes = allAntinodes distinctBy $
---
sizeOf(uniqueAntinodes filter (an) -> an within map.dimensions)
