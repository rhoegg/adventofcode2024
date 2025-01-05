type Point = {x: Number, y: Number}
type Direction = "N" | "S" | "E" | "W"
var directions: Array<Direction> = ["N", "S", "E", "W"]
type Dimensions = { width: Number, height: Number}

fun step(p: Point, d: Direction): Point = d match {
    case "N" -> {x: p.x, y: p.y - 1}
    case "S" -> {x: p.x, y: p.y + 1}
    case "E" -> {x: p.x + 1, y: p.y}
    case "W" -> {x: p.x - 1, y: p.y}
}

fun inBounds(p: Point, d: Dimensions): Boolean =
    p.x >= 0 and p.x < d.width and p.y >= 0 and p.y < d.height

fun toString(p: Point): String = "$(p.x),$(p.y)"

fun manhattanDistance(p1: Point, p2: Point): Number = 
    abs(p1.x - p2.x) + abs(p1.y - p2.y)