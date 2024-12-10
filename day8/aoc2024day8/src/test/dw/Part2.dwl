%dw 2.0
output application/json

import * from Geometry
import * from MySolution
var map: CityMap = parse(rawInput)
var allAntinodes = findResonantAntinodes(map)
var uniqueAntinodes = allAntinodes distinctBy $
---
sizeOf(uniqueAntinodes)
