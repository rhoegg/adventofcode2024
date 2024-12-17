%dw 2.0

type Point = { x: Number, y: Number }
type Dimensions = { width: Number, height: Number }
type Direction = "<" | ">" | "^" | "v"

fun expandToInclude(d: Dimensions, p: Point) = {
    width: if (p.x > d.width - 1) p.x + 1 else d.width,
    height: if (p.y > d.height - 1) p.y + 1 else d.height
}

fun step(p: Point, d: Direction): Point =
    d match {
        case "<" -> {x: p.x - 1, y: p.y}
        case ">" -> {x: p.x + 1, y: p.y}
        case "^" -> {x: p.x, y: p.y - 1}
        case "v" -> {x: p.x, y: p.y + 1}
    }