%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from Geometry

var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")
var sampleInput = readUrl("classpath://sample.txt", "text/plain")

fun parseMap(puzzleInput: String): Map = do {
    var rows = lines(puzzleInput)
    var chars = rows flatMap (line, y) ->
        (line splitBy "") map (c, x) -> {
            position: {x: x, y: y},
            char: c
        }
    var guardChar = (chars firstWith (c) -> c.char matches /[\^v<>]/)
    var obstaclesChars = chars filter (c) -> (c.char == "#")
    var start = if (guardChar == null) {position: {x: -1, y: -1}, direction: North} 
        else {
            position: guardChar.position,
            direction: guardChar.char match {
                case "^" -> North
                case "v" -> South
                case ">" -> East
                case "<" -> West
            }
        }
    ---
    {
        dimensions: {
            width: sizeOf(rows[0]),
            height: sizeOf(rows)
        },
        start: start,
        obstacles: obstaclesChars map (c) -> c.position
    }
}

@TailRec()
fun walkLabGuard1518(m: Map, g: Cursor, visited: Array<Point> = []): Array<Point> = do {
    var d = m.dimensions
    var guardForward = step(g.position, g.direction)
    var finished = outOfBounds(guardForward, d)
    var straightSteps = forwardSteps(m, g)
    var nextGuard = if (finished) g
        else if (m.obstacles contains guardForward) g update {
            case .direction -> turnRight(g.direction)
        }
        else g update {
            case .position -> straightSteps[-1]
        }
    var nextVisited = if (m.obstacles contains guardForward) visited
        else visited << g.position ++ straightSteps
    ---
    if (finished) visited << g.position
    else walkLabGuard1518(m, nextGuard, nextVisited)
}

type CheckHistory = {
    checked: Array<Point>,
    found: Array<Point>,
    previousSteps: Array<Cursor>
}
var emptyHistory = {checked: [], found: [], previousSteps: []}
// for each step
// - put an obstacle in front
// - if we have not checked this obstacle before
// - determine if it's an exit or cycle
// - it's a cycle if the path repeats a cursor
// - previous steps come with us
fun findLoops(m: Map, history: CheckHistory = emptyHistory): Array<Point> = do {
    var nextPosition = step(m.start.position, m.start.direction)
    var finished = outOfBounds(nextPosition, m.dimensions)
    ---
    if (finished) history.found
    // else if (sizeOf(history.previousSteps) > 40) history.found
    else do {
        var newObstacle = nextPosition
        var foundNewLoop = if (history.checked contains newObstacle) false
            else isLoop(m update {
                case o at .obstacles -> o << newObstacle
            }, history.previousSteps)
        var nextStart = if (m.obstacles contains nextPosition) 
                m.start update {
                    case d at .direction -> turnRight(d)
                }
            else m.start  update {
                case .position -> nextPosition
            }
        var nextMap = m update {
            case .start -> nextStart
        }
        var nextHistory = history  update {
            case c at .checked -> (c << newObstacle) distinctBy $
            case f at .found -> if (foundNewLoop) f << newObstacle else f
            case steps at .previousSteps -> steps << m.start
        }
        ---
        findLoops(nextMap, nextHistory)
    }
}

fun isLoop(m: Map, previousSteps: Array<Cursor>): Boolean = do {
    var nextPosition = step(m.start.position, m.start.direction)
    var exited = outOfBounds(nextPosition, m.dimensions)
    ---
    if (exited) false
    else if (previousSteps contains m.start) true
    else do {
        var nextStart = if (m.obstacles contains nextPosition) 
                m.start update {
                    case d at .direction -> turnRight(d)
                }
            else m.start  update {
                case .position -> nextPosition
            }
        var nextMap = m update {
            case .start -> nextStart
        }
        ---
        isLoop(nextMap, previousSteps << m.start)
    }
}