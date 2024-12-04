%dw 2.0
output application/json

import * from MySolution
---
findHorizontalXMAS(wordSearch)
+ findVerticalXMAS(wordSearch)
+ findDiagonalXMAS(wordSearch)
        