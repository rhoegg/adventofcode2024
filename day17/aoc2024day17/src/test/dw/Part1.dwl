%dw 2.0
output application/json

import * from MySolution

var computer = parseProgramInfo(rawInput)
---
run(computer).programOutput joinBy ","