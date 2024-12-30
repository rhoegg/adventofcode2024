%dw 2.0
output application/json
    // all nodes beginning with T
    // whose neighbors of neighbors are neighbors with me

import * from MySolution
var sampleNodes = nodes(parseLinks(sampleInput))
var realNodes = nodes(parseLinks(rawInput))
---
sizeOf(findTrios(realNodes, (node) -> node startsWith "t"))