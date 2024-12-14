%dw 2.0
output application/json

import * from MySolution
---
checksum(compactWholeFiles(parseDiskMap(rawInput)))