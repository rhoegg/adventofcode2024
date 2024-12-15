%dw 2.0
output application/json

import * from MySolution

---
sizeOf(repeatBlink(myInput, 30))