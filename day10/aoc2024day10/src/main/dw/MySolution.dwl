%dw 2.0
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type Point = {
    x: Number,
    y: Number
}

type MapPoint = {
    height: Number,
    location: Point
}

type Map = Array<Array<MapPoint>>

fun parseMap(puzzleInput: String): Map = lines(puzzleInput) map (line, y) ->
    (line splitBy "") map (c, x) -> {
        height: c as Number,
        location: { x: x, y: y }
    }

fun trailheads(m: Map) = m flatMap (row) -> 
    row filter (p) -> p.height == 0

fun neighbors(m: Map, p: MapPoint): Array<MapPoint> = do {
    var l = p.location
    var north = if (l.y > 0) [m[l.y-1][l.x]] else []
    var south = if (l.y < sizeOf(m) - 1) [m[l.y+1][l.x]] else []
    var east = if (l.x < sizeOf(m[l.y]) - 1) [m[l.y][l.x+1]] else []
    var west = if (l.x > 0) [m[l.y][l.x-1]] else []
    ---
    north ++ south ++ east ++ west
}
fun reachableNines(m: Map, starts: Array<MapPoint>): Array<MapPoint> = 
    if (starts[0].height == 9) starts
    else do {
        var hikableNeighbors = starts flatMap (p) -> 
            neighbors(m, p) filter (n) -> n.height == p.height + 1
        ---
        reachableNines(m, hikableNeighbors distinctBy $)
    }

fun distinctTrails(m:Map, starts: Array<MapPoint>): Array<MapPoint> =
    if (starts[0].height == 9) starts
    else do {
        var hikableNeighbors = starts flatMap (p) -> 
            neighbors(m, p) filter (n) -> n.height == p.height + 1
        ---
        distinctTrails(m, hikableNeighbors)
    }