%dw 2.0
import * from Geometry
import * from dw::core::Arrays
import * from dw::core::Strings

var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")
var sampleInput = readUrl("classpath://sample.txt", "text/plain")

type Antenna = {
    frequency: String,
    position: Point
}
type CityMap = {
    dimensions: Dimensions,
    antennas: Array<Antenna>
}

fun parse(puzzleInput: String): CityMap = do {
    var characterRows = lines(puzzleInput) map (line) -> (line splitBy "") 
    var antennas = characterRows flatMap (row, y) -> 
        (row map (c, x) -> {
            frequency: c,
            position: {x: x, y: y}
        }) filter (a, x) -> a.frequency matches /[A-Za-z0-9]/
    ---
    {
        dimensions: {width: sizeOf(characterRows[0]), height: sizeOf(characterRows)},
        antennas: antennas
    }
}

@TailRec()
fun pairs(remaining: Array<Point>, paired: Array<Pair<Point,Point>> = []): Array<Pair<Point,Point>> =
    if (sizeOf(remaining) < 2) paired
    else if (sizeOf(remaining) == 2) paired << {l: remaining[0], r: remaining[1]}
    else do {
        var first = remaining[0]
        var rest = remaining drop 1
        var newPairs = rest map (r) -> {l: first, r: r}
        ---
        pairs(rest, paired ++ newPairs)
    }

fun antinodes(p: Pair<Point, Point>): Array<Point> = do {
    var dx = p.l.x - p.r.x
    var dy = p.l.y - p.r.y
    ---
    [
        {x: p.l.x + dx, y: p.l.y + dy},
        {x: p.r.x - dx, y: p.r.y - dy}
    ]
}
fun findAntinodes(m: CityMap): Array<Point> = do {
    var nodeGroups = m.antennas groupBy (a) -> a.frequency
    var antennaPairs = nodeGroups pluck (antennas, frequency) ->
        {
            frequency: frequency,
            pairs: pairs(antennas map $.position)
        }
    ---
    antennaPairs flatMap (ap) -> ap.pairs flatMap (p) -> antinodes(p)
}

fun resonantAntinodes(p: Pair<Point, Point>, dim: Dimensions) = do {
    var dx = p.l.x - p.r.x
    var dy = p.l.y - p.r.y
    var m = dy/dx   
    var b = p.l.y - m * p.l.x
    var x1 = p.l.x mod dx
    var xs = (0 to dim.width / abs(dx)) map (x) -> x * abs(dx) + x1
    var allAntinodes = xs map (x) -> {x: x, y: round(m*x + b)}
    ---
    allAntinodes filter (an) -> an within dim
}

fun findResonantAntinodes(m: CityMap): Array<Point> = do {
    var nodeGroups = m.antennas groupBy (a) -> a.frequency
    var antennaPairs = nodeGroups pluck (antennas, frequency) ->
        {
            frequency: frequency,
            pairs: pairs(antennas map $.position)
        }
    ---
    antennaPairs flatMap (ap) -> ap.pairs flatMap (p) -> resonantAntinodes(p, m.dimensions)
}