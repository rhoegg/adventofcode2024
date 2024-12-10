type Point = {
    x: Number,
    y: Number
}

type Dimensions = {
    width: Number,
    height: Number
}

fun within(p: Point, d: Dimensions): Boolean =
    (p.x >= 0) and (p.x < d.width)
    and
    (p.y >= 0) and (p.y < d.height)