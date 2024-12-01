%dw 2.0
import * from dw::core::Arrays
output application/json

import * from MySolution
var twoLists = lists(rawInput)

var firstList = twoLists[0]
var secondList = twoLists[1]
var counts = firstList map (num) -> {
    num: num as Number,
    count: secondList countBy (n2) -> n2 == num,
}
var similarities = counts map (count) -> count ++ {
    similarity: count.num * count.count
}
---
sum(similarities map $.similarity)