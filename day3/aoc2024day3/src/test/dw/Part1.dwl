%dw 2.0
output application/json

import * from MySolution
---
sum(products(rawInput))