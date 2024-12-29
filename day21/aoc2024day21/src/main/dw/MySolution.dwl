%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
import * from dw::ext::pq::PriorityQueue

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type Code = String
type Direction = "<" | ">" | "^" | "v"
var directions: Array<Direction> = ["<", ">", "^", "v"]
var directionalButtons = ["<", ">", "^", "v", "A"]

type Keypad = {
    position: String
}

fun parseCodes(puzzleInput: String): Array<Code> = lines(puzzleInput)

/* +---+---+---+
 * | 7 | 8 | 9 |
 * +---+---+---+
 * | 4 | 5 | 6 |
 * +---+---+---+
 * | 1 | 2 | 3 |
 * +---+---+---+
 *     | 0 | A |
 *     +---+---+
 */
var numericLayout = [
    ["7", "8", "9"],
    ["4", "5", "6"],
    ["1", "2", "3"],
    [null, "0", "A"]
]

/*
 *     +---+---+
 *     | ^ | A |
 * +---+---+---+
 * | < | v | > |
 * +---+---+---+
 */
var directionalLayout = [
    [null, "^", "A"],
    ["<", "v", ">"]
]

var numericNeighbors = {(
    flatten(numericLayout) map (key) -> do {
        var keyValue = key default "null"
        ---
        {
            (keyValue): do {
                var rowIndex = numericLayout indexWhere (row) -> row contains key
                var keyIndex = numericLayout[rowIndex] indexOf keyValue
                var options = directions filter (d) ->
                    (d == "^" and ("0A123456" contains keyValue))
                    or (d == "v" and ("23456789" contains keyValue))
                    or (d == "<" and ("258A369" contains keyValue))
                    or (d == ">" and ("1470258" contains keyValue))
                ---
                {( 
                    options map (dir) -> { 
                        (dir): dir match {
                            case "^" -> numericLayout[rowIndex - 1][keyIndex]
                            case "v" -> numericLayout[rowIndex + 1][keyIndex]
                            case "<" -> numericLayout[rowIndex][keyIndex - 1]
                            case ">" -> numericLayout[rowIndex][keyIndex + 1]
                        }
                    }
                )}
            }
        }
    }
)} - "null"

var directionalNeighbors = {
    "<": {
        ">": "v"
    },
    "v": {
        "<": "<",
        "^": "^",
        ">": ">"
    },
    ">": {
        "<": "v",
        "^": "A"
    },
    "^": {
        "v": "v",
        ">": "A"
    },
    "A": {
        "<": "^",
        "v": ">"
    }
}

// human buttons to operate first robot
fun myButtonPresses(from: String, to: String): String =
    if (from == to) "A"
    else from match {
        case "<" -> to match {
            case "v" -> ">"
            case ">" -> ">>"
            case "^" -> ">^"
            case "A" -> ">>^"
        }
        case "v" -> to match {
            case "<" -> "<"
            case ">" -> ">"
            case "^" -> "^"
            case "A" -> ">^"
        }
        case ">" -> to match {
            case "<" -> "<<"
            case "v" -> "<"
            case "^" -> "<^"
            case "A" -> "^"
        }
        case "^" -> to match {
            case "<" -> "v<"
            case "v" -> "v"
            case ">" -> "v>"
            case "A" -> ">"
         }
         case "A" -> to match {
            case "<" -> "<v<"
            case "v" -> "<v"
            case ">" -> "v"
            case "^" -> "^"
         }
    } ++ "A"

// represents a D2 button press
type ButtonPressingNode = {
    position: {
        numeric: String,
        directional1: String,
        directional2: String
    },
    activated: {
        numeric: String,
        directional1: String,
        directional2: String // just for printing
    },
    visited: {
        numeric: String,
        directional1: String,
        directional2: String
    },
    buttonPresses: String
}
 var beginningNode = {
        position: {
            numeric: "A",
            directional1: "A",
            directional2: "A"
        },
        activated: {
            numeric: "",
            directional1: "",
            directional2: ""
        },
        visited: {
            numeric: "",
            directional1: "",
            directional2: ""
        },
        buttonPresses: ""
    }
// cost of final Robot moving left =
// cost of last directional robot moving from A to < , activating it, moving from < back to A, and activating it

fun shortestNumericPath(target: String) = do {
    var emptyQ = init( (node: ButtonPressingNode) -> do {
        // adapt A* by adding an heuristic cost to the direct cost
        var directCost = sizeOf(node.buttonPresses)
        var numericProgress = sizeOf(node.activated.numeric)
        var nextNumericNeeded = if (numericProgress == 4) "" else target[numericProgress]
        var wrongNumberPenalty = if (node.position.numeric == nextNumericNeeded) 0 else 1
        var numericProgressPenalty = (2 pow (4 - numericProgress)) - 1
        ---
        directCost + wrongNumberPenalty + numericProgressPenalty
    } )
    var q = emptyQ insert beginningNode
    ---
    findShortestNumericPath(target, q)
}


var deadline = now() + |PT5M|
fun findShortestNumericPath(target: String, q: PriorityQueue<ButtonPressingNode>, progress = 0): ButtonPressingNode | Null = do {
    var node = next(q)
    ---
    if (node == null) null
    else if (node.activated.numeric == target) node
    else if (now() > deadline) node
    else do {
        var poppedQ = deleteNext(q)
        var thisNodeProgress = sizeOf(node.activated.numeric)

        // search the directional2 space - only valid d1 neighbors are possible next steps
        // filter next steps with d1 activate when numeric is not good number, or with revisit numeric in recent path
        var chosen = if (thisNodeProgress < (progress - 1)) [] else // skip hopeless losers
            possibilities(node) filter (idea) -> desirableNumericStep(target, idea)
        var nextQ = chosen reduce (node, q = poppedQ) -> q insert node
        ---
        findShortestNumericPath(target, nextQ, if (thisNodeProgress > progress) thisNodeProgress else progress)
    }
}


/**
* When d2 A is pressed
* ----
*/
fun activate(node: ButtonPressingNode): ButtonPressingNode = 
    do {
        // d1 position remains the same
        // d1 value applies to numeric
        // d1 and d2 activated get extended
        // if d1 is A, numeric activated gets extended
        var d1Value = node.position.directional1
        var numericValue = node.position.numeric
        var newNumericPosition = if (d1Value == "A") numericValue
            else numericNeighbors[numericValue][d1Value]
        ---
        {
            position: {
                numeric: newNumericPosition as String,
                directional1: d1Value,
                directional2: "A"
            },
            activated: {
                numeric: if (d1Value == "A") node.activated.numeric ++ numericValue else node.activated.numeric,
                directional1: node.activated.directional1 ++ d1Value,
                directional2: node.activated.directional2 ++ "A"
            },
            visited: {
                numeric: if (d1Value == "A") "" else node.visited.numeric ++ numericValue,
                directional1: "",
                directional2: ""
            },
            buttonPresses: node.buttonPresses ++ myButtonPresses(node.position.directional2, "A")
        }
    }

fun canActivateD2(node: ButtonPressingNode): Boolean = do {
    // check numeric direction would be fine
    var finalBot = node.position.numeric
    var d1 = node.position.directional1
    ---
    d1 == "A" or numericNeighbors[finalBot][d1]?
}

// filter next steps with d1 activate when numeric is not good number, or with revisit numeric in recent path
fun desirableNumericStep(target: String, node: ButtonPressingNode): Boolean =
    if (node.position.directional2 != "A") true
    else if (not (target startsWith node.activated.numeric)) false
    else if (["^<v", "^>v", "v<^", "v>^"] some (badIdea) -> node.activated.directional1 contains badIdea) false
    else true
    // if (node.position.directional1 == "A") do {
    //     var progress = sizeOf(node.activated.numeric)
    //     var desired = target[progress]
    //     var forLog = log("numeric filter 1", node.activated.numeric)
    //     ---
    //     node.position.numeric == desired
    // } else do {
    //     var recentRoute = if (isEmpty(node.activated.numeric)) node.visited.numeric
    //         else node.visited.numeric substringAfterLast (node.activated.numeric[-1])
    //     var forLog = log("numeric filter 2", node.activated.numeric)
    //     ---
    //     not (recentRoute contains node.position.numeric)
    // }

fun possibilities(node: ButtonPressingNode): Array<ButtonPressingNode> = do {
    var ideas = keysOf(directionalNeighbors[node.position.directional1]) map (button) -> do {
        var targetD2 = button as String
        ---
        node update {
            case .position.directional2 -> targetD2
            case p at .position.directional1 -> directionalNeighbors[p][targetD2] as String
            case b at .buttonPresses -> b ++ myButtonPresses(node.position.directional2, targetD2)
            case a at .activated.directional2 -> a ++ targetD2
            case v at .visited.directional1 -> v ++ node.position.directional1
            case v at .visited.directional2 -> v ++ node.position.directional2
        }
    }
    var possibilities = ideas ++ if (canActivateD2(node)) [activate(node)] else []
    ---
    possibilities filter (idea) -> allowable(idea)
}

fun allowable(node: ButtonPressingNode): Boolean = do {
    // var badIdeas = ["<>", "><", "^v", "v^"] // could ban other long paths here
    var d2Value = node.position.directional2
    var d2Activated = node.activated.directional2
    var d1Value = node.position.directional1
    var d1Activated = node.activated.directional1
    
    ---
    // (not (badIdeas some (badIdea) -> d2Activated contains badIdea))
    // (not (node.visited.directional2 contains d2Value))
    (not (node.visited.directional1 contains d1Value))
    and (not (node.visited.numeric contains node.position.numeric))

}

fun buttonsNeeded(target: String): String = do {
    var b = (target splitBy "") reduce (c, state = {position: "A", buttons: ""}) ->
    { 
        position: c, 
        buttons: state.buttons ++ myButtonPresses(state.position, c) 
    }    
    ---
    b.buttons
}
    