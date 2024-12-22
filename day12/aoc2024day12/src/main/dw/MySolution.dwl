%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var sampleInput2 = readUrl("classpath://sample2.txt", "text/plain")
var sampleInput3 = readUrl("classpath://sample3.txt", "text/plain")
var sampleInput4 = readUrl("classpath://sample4.txt", "text/plain")
var sampleInput5 = readUrl("classpath://sample5.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type Point = {x: Number, y: Number}
type Dimensions = {width: Number, height: Number}
type Plot = {
    plant: String,
    position: Point
}

type Farm = {
    dimensions: Dimensions,
    plots: Array<Array<Plot>>
}

type Region = {
    number: Number,
    plant: String,
    plots: Array<Plot>
}

type Fence = {
    plot: Plot,
    direction: Direction
}

type Edge = Pair<Point, Point>
type Direction = "N" | "S" | "E" | "W"

fun left(d: Direction): Direction = d match {
    case "N" -> "W"
    case "S" -> "E"
    case "E" -> "N"
    case "W" -> "S"
}

fun right(d: Direction): Direction = d match {
    case "N" -> "E"
    case "S" -> "W"
    case "E" -> "S"
    case "W" -> "N"
}

fun reverse(d: Direction): Direction = d match {
    case "N" -> "S"
    case "S" -> "N"
    case "E" -> "W"
    case "W" -> "E"
}

fun neighbor(p: Point, d: Direction): Point = d match {
    case "N" -> {x: p.x, y: p.y - 1}
    case "S" -> {x: p.x, y: p.y + 1}
    case "E" -> {x: p.x + 1, y: p.y}
    case "W" -> {x: p.x - 1, y: p.y}
}

fun inBounds(p: Point, farm: Farm) =
    p.x >= 0 and p.x < farm.dimensions.width and p.y >= 0 and p.y <= farm.dimensions.height

// I need regions with areas and perimeters
fun parseGardenPlots(puzzleInput: String): Farm = do {
    var plots = lines(puzzleInput) map (line, y) ->
        (line splitBy "") map (c, x) -> {plant: c, position: {x: x, y: y}}
    var width = (max(plots flatMap (p) -> p.position.x) default 0) + 1
    var height = (max(plots flatMap(p) -> p.position.y) default 0) + 1
    ---
    {   
        dimensions: {width: width, height: height},
        plots: plots
    }
}

fun neighborsInRegion(farm: Farm, p: Plot): Array<Plot> = do {
    var neighborLocations: Array<Point> = [{x: p.position.x - 1, y: p.position.y}, {x: p.position.x + 1, y: p.position.y}, {x: p.position.x, y: p.position.y - 1}, {x: p.position.x, y: p.position.y + 1}]
        filter (n) -> (n.x >= 0) and (n.y >= 0) and (n.x < farm.dimensions.width) and (n.y < farm.dimensions.height)
    var neighbors = neighborLocations map (loc) -> farm.plots[loc.y][loc.x]
    ---
    neighbors filter (n) -> n.plant == p.plant
}

fun findRegions(farm: Farm, found: Array<Region> = []): Array<Region> = do {
    var mappedPlots = found flatMap (r) -> r.plots
    var nextUnmappedPlot = flatten(farm.plots) firstWith (p) -> not (mappedPlots contains p)
    ---
    if (nextUnmappedPlot == null) found
    else do {
        fun findAllNeighbors(plots: Array<Plot>, found: Array<Plot> = []): Array<Plot> = do {
            var neighbors = (plots flatMap (p) -> neighborsInRegion(farm, p)) -- found
            var neighborsToSearch = neighbors distinctBy $
            ---
            if (isEmpty(neighborsToSearch)) found ++ plots
            else findAllNeighbors(neighborsToSearch, found ++ plots)
        }
        var plotGroup = findAllNeighbors([nextUnmappedPlot])
        var nextRegion = {
            number: sizeOf(found),
            plant: plotGroup[0].plant,
            plots: plotGroup
        }
        ---
        findRegions(farm, found << nextRegion)
    }
}

fun findInternalEdges(farm: Farm, region: Region): Array<Edge> = do {
    fun normalize(e: Edge): Edge = if (e.l.x <= e.r.x and e.l.y <= e.r.y) e else {l: e.r, r: e.l}
    var foundEdges = region.plots flatMap (plot) -> do {
        var neighbors: Array<Plot> = neighborsInRegion(farm, plot)
        ---
        neighbors map (n) -> {l: plot.position, r: n.position}
    }
    ---
    foundEdges distinctBy (e) -> normalize(e)
}

fun area(region: Region): Number = sizeOf(region.plots)
@TailRec()
fun findCorner(farm: Farm, plot: Plot): Plot = do {
    var north = neighbor(plot.position, "N")
    var west = neighbor(plot.position, "W")
    var northPlot = farm.plots[north.y][north.x]
    var westPlot = farm.plots[west.y][west.x]
    
    // if there's a north neighbor in region, recurse north
    // if there's a west neighbor in region, recurse west
    // otherwise we're done
    var nextStep = if (inBounds(north, farm) and northPlot.plant == plot.plant) northPlot
        else if (inBounds(west, farm) and westPlot.plant == plot.plant) westPlot
        else null
    ---
    if (nextStep == null) plot
    else findCorner(farm, nextStep)
}


fun sides(farm: Farm, region: Region): {fences: Array<Fence>, neighbors: Array<Fence>, sides: Number} = do {
    // go northwest until I can't
    var origin = findCorner(farm, region.plots[0]).position

    // go clockwise from start, facing east
    @TailRec()
    fun countSides(p: Point = origin, d: Direction = "E", fences: Array<Fence> = [], neighbors: Array<Fence> = [], s: Number = 1): {fences: Array<Fence>, neighbors: Array<Fence>, sides: Number} = 
        // if we arrive back at origin, facing north, we are done
        if (p == origin and d == "N") {fences: fences << { plot: farm.plots[p.y][p.x], direction: left(d) }, neighbors: neighbors, sides: s}
        else do {
            // var forLog = log("$(s) ($(p.x),$(p.y) $(d))")
            var fence: Fence = { plot: farm.plots[p.y][p.x], direction: left(d) }
            var leftPosition = neighbor(p, left(d))
            var aheadPosition = neighbor(p, d)
            var leftNeighbor = if (inBounds(leftPosition, farm)) farm.plots[leftPosition.y][leftPosition.x] else null
            var isNeighborLeft = inBounds(leftPosition, farm) and leftNeighbor.plant == region.plant
            var isNeighborAhead = inBounds(aheadPosition, farm) and farm.plots[aheadPosition.y][aheadPosition.x].plant == region.plant
            // if neighbor left, turn left and start a new side
            // if no neighbor ahead, turn right and start a new side
            // else go straight continuing this side
            var nextPos = if (isNeighborLeft) leftPosition
                else if (isNeighborAhead) aheadPosition
                else p
            var nextDir = if (isNeighborLeft) left(d)
                else if (not isNeighborAhead) right(d)
                else d
            var numSides = if (isNeighborLeft) s + 1
                else if (not isNeighborAhead) s + 1
                else s
            var newNeighbors = if (isNeighborLeft) []
                else if (leftNeighbor == null) []
                else [{plot: leftNeighbor, direction: right(d)} as Fence]
            ---
            countSides(nextPos, nextDir, fences << fence, neighbors ++ newNeighbors, numSides)
        }
    ---
    countSides()
}

// new approach: for every region, count the outside sides, and keep the plots traveled with the outside neighbors (N,S,E,W)
// determine what region the neighbors belong to
// then 