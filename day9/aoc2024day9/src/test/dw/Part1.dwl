%dw 2.0
output application/json

import * from MySolution
---
// checksum(log(compact(parseDiskMap(sampleInput))))
checksum(compact(parseDiskMap(rawInput)))