type Point = {
    x: Number,
    y: Number
}

var North = "North"
var South = "South"
var East = "East"
var West = "West"
type Direction = "North" | "South" | "East" | "West"
type Dimensions = {
    width: Number,
    height: Number
}
type Cursor = {
    position: Point,
    direction: Direction
}

type Map = {
    dimensions: Dimensions,
    start: Cursor,
    obstacles: Array<Point>
}

fun step(p: Point, d: Direction): Point =
    d match {
        case "North" -> {x: p.x, y: p.y - 1}
        case "South" -> {x: p.x, y: p.y + 1}
        case "East" -> {x: p.x + 1, y: p.y}
        case "West" -> {x: p.x - 1, y: p.y}
    }

fun outOfBounds(p: Point, dim: Dimensions) =
    (p.x < 0) or
    (p.y < 0) or
    (p.x >= dim.width) or
    (p.y >= dim.height)

fun turnRight(d: Direction) =
    d match {
        case "North" -> East
        case "East" -> South
        case "South" -> West
        case "West" -> North
    }

fun forwardSteps(m: Map, guard: Cursor, steps = []): Array<Point> = do {
    var d = m.dimensions
    var guardForward = step(guard.position, guard.direction)
    ---
    if (outOfBounds(guardForward, d)) steps
    else if (m.obstacles contains guardForward) steps
    else forwardSteps(m, guard update {
        case .position -> guardForward
    }, guardForward >> steps)
}
