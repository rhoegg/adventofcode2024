%dw 2.0
import * from dw::core::Strings
import * from Geometry

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

fun parseRobots(puzzleInput: String): Array<RobotState> = lines(puzzleInput) map (line) -> do {
    var parts = line splitBy " "
    var positionCoordinates = parts[0] substringAfter "p="
    var velocityCoordinates = parts[1] substringAfter "v="
    var position = (positionCoordinates splitBy ",") map (c) -> c as Number
    var velocity = (velocityCoordinates splitBy ",") map (c) -> c as Number
    ---
    {
        position: {
            x: position[0],
            y: position[1]
        },
        velocity: {
            x: velocity[0],
            y: velocity[1]
        }
    }
}

fun posmod(i, m) = do {
    var x = i mod m
    ---
    if (x < 0) x + m
    else x
}

fun sgn(i: Number): Number =
    if (i < 0) -1
    else if (i > 0) 1
    else 0
