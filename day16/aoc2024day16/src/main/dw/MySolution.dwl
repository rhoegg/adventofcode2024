%dw 2.0
import * from Geometry
import countBy, drop, indexWhere, take from dw::core::Arrays
import fail from dw::Runtime
import * from dw::core::Strings
import * from dw::ext::pq::PriorityQueue

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var sampleInput2 = readUrl("classpath://sample2.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type ReindeerMaze = {
    map: Array<String>,
    start: Cursor,
    end: Point
}

type Progress = {
    at: Cursor,
    path: Array<Cursor>,
    score: Number
}

var scores = {
    forward: 1,
    turn: 1000
}
fun parseReindeerMaze(puzzleInput: String): ReindeerMaze = do {
    var inputLines = lines(puzzleInput)
    var startY = inputLines indexWhere (line) -> line contains "S"
    var start = {x: inputLines[startY] indexOf "S", y: startY}
    var endY = inputLines indexWhere (line) -> line contains "E"
    var end = {x: inputLines[endY] indexOf "E", y: endY}
    ---
    {
        map: inputLines,
        start: { location: start, direction: "E" },
        end: end
    }
}

fun isWall(maze: ReindeerMaze, p: Point): Boolean =
    maze.map[p.y][p.x] == "#"

// use dijsktra to find lowest score to the end
var emptyQ = init( (p: Progress) -> p.score )
var deadline = now() + |PT60M|
@TailRec()
fun solveLowestScore(maze: ReindeerMaze, q: PriorityQueue<Progress>, bestScore: Number = -1, paths: Array<Array<Cursor>> = [], visited: Object = {}): {score: Number, paths: Array<Array<Cursor>>} = do {
    var progress = next(q)
    var poppedQ = deleteNext(q)
    ---
    if (progress == null) {score: bestScore, paths: paths}
    else if (now() > deadline or (bestScore > 0 and log("checking", progress.score) > bestScore)) do {
        var forLog = log("number of visited", sizeOf(visited))
        // var forLog2 = log("path followed", progress.path)
        ---
        {score: bestScore, paths: paths}
    } else do {
        var newBestScore = if (bestScore > 0) log("after finding bestScore once", bestScore)
            else if (progress.at.location == maze.end) log("finished first time", progress.score) // capture score when we reach the end
            else bestScore
        var newPaths = if (newBestScore == -1) paths
            else do {
                var forLog = log("Adding path with score $(progress.score)")
                ---
                paths << (progress.path << progress.at)
            }
        var shouldSkipThisPath = (visited[toString(progress.at)] default progress.score) < progress.score
        var nextQ = if (shouldSkipThisPath) poppedQ else do {
            var ideas: Array<Progress> = [
                // TODO: straight to next opportunity to turn instead of one step?
                {at: straight(progress.at), path: progress.path << progress.at, score: scores.forward + progress.score},
                {at: left(progress.at), path: progress.path << progress.at, score: scores.turn + progress.score},
                {at: right(progress.at), path: progress.path << progress.at, score: scores.turn + progress.score}
            ]
            var possibleIdeas = ideas filter (idea) -> not isWall(maze, idea.at.location)
            var goodIdeas = possibleIdeas filter (idea) ->
                (idea.path countBy (step) -> step.location == idea.path[-1].location) < 3
            ---
            goodIdeas reduce (idea, q1 = poppedQ) -> q1 insert idea
        }
        ---
        solveLowestScore(maze, nextQ, newBestScore, newPaths, if (shouldSkipThisPath) visited else (visited ++ {(toString(progress.at)): progress.score}))
    }
}

fun solve(maze: ReindeerMaze): {score: Number, paths: Array<Array<Cursor>>} =
    solveLowestScore(maze, emptyQ insert {at: maze.start, path: [], score: 0})

fun printMaze(maze: ReindeerMaze, path: Array<Point>): Array<String> = do {
    var drawnOn = replaceChar(maze.map, path[0], "R")
    var newMaze = maze update { case .map -> drawnOn }
    ---
    if (sizeOf(path) < 2) drawnOn
    else printMaze(newMaze, path drop 1) 
}

fun replaceChar(s: String, i: Number, replacement: String) = do {
    var chars = s splitBy ""
    var substituted = chars map (c, pos) ->
        if (pos == i) replacement
        else c
    ---
    substituted joinBy ""
}
fun replaceChar(maze: Array<String>, p: Point, c: String) = (0 to sizeOf(maze) - 1) map (y) ->
    if (y == p.y) replaceChar(maze[y], p.x, c)
    else maze[y]

fun toString(c: Cursor): String = "$(c.location.x),$(c.location.y) $(c.direction)"