%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

var rawInput = lines(readUrl("classpath://puzzle-input.txt", "text/plain"))
//var rawInput = lines(readUrl("classpath://sample.txt", "text/plain"))
var reports = rawInput map (line) -> (line splitBy " ") map ($ as Number)

type Report = Array<Number>
fun safe(report: Report): Boolean = do {
    var steps = report zip report[1 to -1]
    var stepSizes = steps map (step) -> step[1] - step[0]
    var increasingSafe = stepSizes every (stepSize) ->
        stepSize >= 1 and stepSize <= 3
    var decreasingSafe = stepSizes every (stepSize) ->
        stepSize <= -1 and stepSize >= -3
    ---
    increasingSafe or decreasingSafe
}

fun safeWithDampener(report: Report): Boolean = 
    (0 to sizeOf(report)) some (badLevelIndex) -> do {
        var left = report take badLevelIndex
        var right = report drop badLevelIndex + 1
        var dampenedReport = left ++ right
        ---
        safe(dampenedReport)
    }