%dw 2.0

type Point = {x: Number, y: Number}
type Dimensions = {width: Number, height: Number}
type Direction = "N" | "S" | "E" | "W"
var directions: Array<Direction> = ["N", "S", "E", "W"]

fun step(p: Point, d: Direction): Point = d match {
    case "N" -> {x: p.x, y: p.y - 1}
    case "S" -> {x: p.x, y: p.y + 1}
    case "E" -> {x: p.x + 1, y: p.y}
    case "W" -> {x: p.x - 1, y: p.y}
}

fun within(p: Point, d: Dimensions): Boolean =
    p.x >= 0 and p.x < d.width and p.y >= 0 and p.y < d.height

fun toString(p: Point): String = "$(p.x),$(p.y)"