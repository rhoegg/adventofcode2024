%dw 2.0
import * from dw::core::Strings
import * from dw::ext::pq::PriorityQueue
import * from Geometry

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type MemorySpace = {
    corrupted: Array<Point>,
    dimensions: Dimensions
}

type Node = {
    location: Point,
    cost: Number
}

fun parseListOfBytes(puzzleInput: String): Array<Point> = lines(puzzleInput) map (line) -> do {
    var byteData = line splitBy ","
    ---
    {
        x: byteData[0] as Number,
        y: byteData[1] as Number
    }
}

fun shortestEscape(memorySpace: MemorySpace): Number = do {
    var destination: Point = {
        x: memorySpace.dimensions.width - 1,
        y: memorySpace.dimensions.height - 1 
    }
    var emptyQ = init((node: Node) -> node.cost)
    var origin: Node = {
        location: {x: 0, y: 0},
        cost: 0
    }
    var q = emptyQ insert origin
    ---
    shortestPath(memorySpace, destination, q)
}

@TailRec()
fun shortestPath(memorySpace: MemorySpace, destination: Point, q: PriorityQueue<Node>, visited: Array<Point> = []): Number =
    if (next(q) == null) -1 else do {
        var currentProgress = next(q)
        ---
        if (currentProgress.location == destination) currentProgress.cost as Number
        else do {
            var poppedQ = deleteNext(q)
            var p = currentProgress.location as Point
            var alreadyBeenHere = (visited contains p)
            var nextQ = if (alreadyBeenHere) poppedQ else do {
                // var forLog = log("checking", toString(p))
                var aimSouthEastDirections: Array<Direction> = ["S", "E", "N", "W"]
                var allOptions = aimSouthEastDirections map (d) -> step(p, d)
                var choices = allOptions filter (nextP) ->
                    (nextP within memorySpace.dimensions) 
                    and
                    (not (visited contains nextP)) 
                    and
                    (not (memorySpace.corrupted contains nextP))
                ---
                choices reduce (choice, q1=poppedQ) -> do {
                    var choiceNode: Node = {location: choice, cost: currentProgress.cost + 1}
                    ---
                    q1 insert choiceNode
                }
            }
            ---
            shortestPath(memorySpace, destination, nextQ, if (alreadyBeenHere) visited else visited << p)
        }
    }