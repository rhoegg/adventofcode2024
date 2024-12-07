%dw 2.0
output application/json

fun recurse(i: Number, j: Number): Array<Number> = recurse(i, [])

// @TailRec()
fun recurse(i: Number, visited = []): Array<Number> = do {
    if (i < 0) visited
    else recurse(i - 1, i >> visited)
}
---
recurse(1400)