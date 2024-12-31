%dw 2.0
output application/json

import * from MySolution

var device = parseMonitoringDevice(rawInput)
---
simulate(device)