%dw 2.0

type Point = {x: Number, y: Number}
type Direction = "N" | "S" | "E" | "W"
type Cursor = {
    location: Point,
    direction: Direction
}

fun step(p: Point, d: Direction) = d match {
    case "N" -> {x: p.x, y: p.y - 1}
    case "S" -> {x: p.x, y: p.y + 1}
    case "E" -> {x: p.x + 1, y: p.y}
    case "W" -> {x: p.x - 1, y: p.y}
}

fun right(d: Direction): Direction = d match {
    case "N" -> "E"
    case "S" -> "W"
    case "E" -> "S"
    case "W" -> "N"
}

fun left(d: Direction): Direction = d match {
    case "N" -> "W"
    case "S" -> "E"
    case "E" -> "N"
    case "W" -> "S"
}

fun reverse(d: Direction): Direction = d match {
    case "N" -> "S"
    case "S" -> "N"
    case "E" -> "W"
    case "W" -> "E"
}

fun straight(c: Cursor): Cursor = c update {
    case l at .location -> step(l, c.direction)
}

fun right(c: Cursor): Cursor = c update {
    case d at .direction -> right(d)
}

fun left(c: Cursor): Cursor = c update {
    case d at .direction -> left(d)
}