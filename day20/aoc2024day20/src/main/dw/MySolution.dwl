%dw 2.0
import * from Geometry
import fail from dw::Runtime
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::ext::pq::PriorityQueue

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type RaceTrack = {
    dimensions: Dimensions,
    walls: Array<Array<Point>>,
    track: Array<Point>,
    start: Point,
    end: Point
}

type Cheat = {
    start: Point,
    end: Point,
    duration: Number
}

fun parseRacetrack(puzzleInput: String): RaceTrack = do {
    var inputLines = lines(puzzleInput)
    var charPoints = inputLines flatMap (line, y) ->
        (line splitBy "") map (c, x) -> {
            char: c,
            point: {x: x, y: y}
        }
    var dimensions = {
        width: sizeOf(inputLines[0]),
        height: sizeOf(inputLines)
    }
    var start: Point = (charPoints firstWith (cp) -> cp.char == "S").point default {x: -1, y: -1}
    var end: Point = (charPoints firstWith (cp) -> cp.char == "E").point default {x: -1, y: -1}
    var walls: Array<Array<Point>> = inputLines map (line, y) -> do {
        var pointInfo = (line splitBy "") map (c, x) -> {char: c, x: x, y: y}
        ---
        (pointInfo filter $.char == "#") map {x: $.x, y: $.y}
    }
    var trackPoints: Array<Point> = (charPoints filter (cp) -> cp.char == ".") 
        map (cp) -> cp.point
    ---
    {
        dimensions: dimensions,
        walls: walls,
        track: trackPoints << start << end,
        start: start,
        end: end
    }
}

// this was slow
fun followTrack(start: Point, end: Point, trackPoints: Array<Point>, track: Array<Point> = []): Array<Point> =
    if (isEmpty(trackPoints)) track
    else if (start == end) track << end
    else do {
        var remainingTrack = trackPoints - start
        var nextPoint = (directions map (d) -> step(start, d))
            firstWith (p) -> remainingTrack contains p
        ---
        if (nextPoint == null) fail("fell off the track at $(toString(start))")
        else followTrack(nextPoint, end, remainingTrack, track << start)
    }

fun raceTime(racetrack: RaceTrack, elapsed = 0, visited: Array<Point> = []): Number = race(racetrack, elapsed, visited).elapsed
fun race(racetrack: RaceTrack, elapsed: Number = 0, visited: Array<Point> = []): { elapsed: Number, visited: Array<Point> } = 
    if (racetrack.start == racetrack.end) { elapsed: elapsed, visited: visited }
    else do {
        var options = directions map (d) -> step(racetrack.start, d)
        var nextValidStep = options firstWith (p) -> 
            inBounds(p, racetrack.dimensions) 
            and (not (isWall(racetrack, p)))
            and (not (visited contains p))
        
        ---
        if (nextValidStep == null) {elapsed: -1, visited: visited } // dead end
        else race(racetrack update { case .start -> nextValidStep }, elapsed + 1, visited << racetrack.start)
    }

fun cheat(racetrack: RaceTrack, elapsed: Number, visited: Array<Point>, duration: Number): Number =
    if (duration == 0) raceTime(racetrack, elapsed, visited)
    else if (duration == 1 and (isWall(racetrack, racetrack.start))) log("cheat eliminated at $(toString(racetrack.start))", -1)
    else do {
        // ignore walls, try all 4 directions, stay in bounds, avoid visited
        var options = directions map (d) -> step(racetrack.start, d)
        var validSteps = options filter (p) ->
            inBounds(p, racetrack.dimensions)
            // no need to check outer walls since cheat is at most 2; I think 4 would make this worth checking
            and (not isOuterWall(p, racetrack.dimensions))
            and (not (visited contains p))
        var forLog = log("trying cheats at step $(elapsed), duration $(duration)", sizeOf(validSteps))
        var bestTimes = validSteps map (nextStep) -> cheat( // recurse
            racetrack update {case .start -> nextStep}, elapsed + 1, visited << racetrack.start, duration - 1)
        var bestValidTime = min(bestTimes filter $ >= 0)
        ---
        bestValidTime default -1 // -1 indicates invalid path
    }

fun isOuterWall(p: Point, d: Dimensions): Boolean =
    p.x == 0 or p.y == 0 or (p.x == d.width - 1) or (p.y == d.height - 1)

fun isWall(racetrack: RaceTrack, p: Point): Boolean =
    racetrack.walls[p.y] contains p

type Node = {
    start: Point,
    cheats: Number,
    visited: Array<Point>,
    elapsed: Number
}
fun fastestTime(racetrack: RaceTrack, elapsed: Number, cheats: Number): Number = do {
    var emptyQ = init( (node: Node) -> node.elapsed )
    var q = emptyQ insert {
        start: racetrack.start,
        cheats: cheats,
        visited: [],
        elapsed: elapsed
    }
    ---
    fastestTimeToEnd(racetrack, q)
}

@TailRec()
fun fastestTimeToEnd(racetrack: RaceTrack, q: PriorityQueue<Node>): Number = do {
    var thisNode = next(q)
    ---
    if (thisNode == null) -1
    else if (thisNode.start == racetrack.end) do {
        var forLog = log("fastest path", thisNode.visited)
        ---
        thisNode.elapsed
    }
    else do {
        var poppedQ = deleteNext(q)
        var options = directions map (d) -> step(thisNode.start, d)
        var validSteps = if (thisNode.cheats > 1) options filter (p) ->
                (inBounds(p, racetrack.dimensions))
                and (not (thisNode.visited contains p))
            else options filter (p) ->
                (inBounds(p, racetrack.dimensions))
                and (not (thisNode.visited contains p))
                and (not isWall(racetrack, p))
        // var forLog = log("testing $(thisNode.elapsed) at $(toString(thisNode.start)), next steps", validSteps)
        var nextQ = validSteps reduce (step, q = poppedQ) -> (q insert {
            start: step,
            cheats: if (thisNode.cheats > 0) thisNode.cheats - 1 else thisNode.cheats,
            visited: thisNode.visited << thisNode.start,
            elapsed: thisNode.elapsed + 1
        })
        ---
        fastestTimeToEnd(racetrack, nextQ)
    }
}

type CheatNode = {
    location: Point,
    elapsed: Number,
    cheatStart?: Point,
    cheatEnd?: Point,
    visited: Array<Point>
}
fun findCheats(racetrack: RaceTrack, fairPath: Array<Point>): Array<Cheat> = do {
    var emptyQ = init( (node: CheatNode) -> node.elapsed )
    var q = emptyQ insert {
        location: racetrack.start,
        elapsed: 0,
        visited: []
    }
    ---
    cheats(racetrack, fairPath, [], [], q)
}

var deadline = now() + |PT3M|
@TailRec()
fun cheats(racetrack: RaceTrack, fairPath: Array<Point>, cheated: Array<Point>, goodCheats: Array<Cheat>, q: PriorityQueue<CheatNode>): Array<Cheat> = do {
    var thisNode = next(q)
    ---
    if (thisNode == null) goodCheats
    else if (thisNode.location == racetrack.end and thisNode.cheatStart == null) do {
        // this is the end of the no-cheating path
        goodCheats
    }
    else if (now() > deadline) log("deadline exceeded checking $(thisNode.elapsed)", goodCheats)
    else do {
        var poppedQ = deleteNext(q)
        var options = directions map (d) -> step(thisNode.location, d)
        var finished = (thisNode.location == racetrack.end)
        var cheatingThisTime = (not finished) 
            and (not thisNode.cheatStart?) 
            and (not (cheated contains thisNode.location))
            and (thisNode.elapsed < (sizeOf(fairPath) - 101))
        // var forLog = if (cheatingThisTime) log("cheating after $(thisNode.elapsed)", thisNode) else null
        var cheatSteps = if (cheatingThisTime) options filter (p) ->
                inBounds(p, racetrack.dimensions)
                // only try cheating that goes through walls
                and (isWall(racetrack, p))
                // don't try cheating the same spot twice
                and (not (cheated contains p))
                // if the cheat duration is longer, better include outer walls
                and (not isOuterWall(p, racetrack.dimensions))
                // if the cheat duration is longer, might need a separate visited for cheating
                and (not (thisNode.visited contains p))
            else []
        // if already cheated, we can use remaining fairPath time
        var legitSteps = if (not (thisNode.cheatEnd?)) options filter (p) ->
                inBounds(p, racetrack.dimensions)
                and (not finished)
                and (not isWall(racetrack, p))
                and (not (thisNode.visited contains p))
            else []
        
        var cheatNodes: Array<CheatNode> = cheatSteps map (p) -> do {
            var forLog = log("trying cheat at $(toString(thisNode.location))", toString(p))
            ---
            {
                location: p,
                elapsed: thisNode.elapsed + 1,
                cheatStart: p,
                visited: thisNode.visited << p
            } as CheatNode
        }
        var legitNodes = legitSteps map (p) -> {
            location: p,
            elapsed: thisNode.elapsed + 1,
            (cheatStart: thisNode.cheatStart) if thisNode.cheatStart?,
            (cheatEnd: thisNode.cheatEnd default p) if thisNode.cheatStart?,
            visited: thisNode.visited << p
        } as CheatNode
        var nextQ = (cheatNodes ++ legitNodes) reduce (node, q = poppedQ) -> do {
            (q insert node)
        }
        var nextCheated = cheated ++ cheatSteps
        var nextGoodCheats = if (finished) (goodCheats << {
            start: thisNode.cheatStart,
            end: thisNode.cheatEnd default thisNode.location,
            duration: thisNode.elapsed
        }) else if (thisNode.cheatEnd?) (goodCheats << {
            start: thisNode.cheatStart,
            end: thisNode.cheatEnd,
            duration: thisNode.elapsed + do {
                var fairPathPosition = fairPath indexOf thisNode.location
                ---
                sizeOf(fairPath) - fairPathPosition
            }
        })
        else goodCheats
        ---
        cheats(racetrack, fairPath, nextCheated, nextGoodCheats, nextQ)
    }
}
