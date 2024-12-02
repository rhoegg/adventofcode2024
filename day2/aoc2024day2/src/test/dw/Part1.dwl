%dw 2.0
import * from dw::core::Arrays
output application/json

import * from MySolution
---
reports countBy (r) -> safe(r)