%dw 2.0
output application/json
// Bron-Kerbosch to find maximal cliques

import * from MySolution
var sampleNodes = nodes(parseLinks(sampleInput))
var realNodes = nodes(parseLinks(rawInput))
// var cliques = bronKerbosch(sampleNodes, [], keysOf(sampleNodes) map ($ as String), [])
var cliques = bronKerbosch(realNodes, [], keysOf(realNodes) map ($ as String), [])
var largestClique = (cliques orderBy sizeOf($))[-1]
---
(largestClique orderBy $) joinBy ","