%dw 2.0
import * from dw::core::Strings
// var rawInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")
var wordSearch = lines(rawInput) //map (line) -> line splitBy ""

fun pivot(ws: Array<String>): Array<String> =
    (0 to sizeOf(ws[0])) map (i) ->
        (ws map (line) -> line[i] default "") joinBy ""

fun skewedDown(ws: Array<String>): Array<String> =
    (0 to sizeOf(wordSearch) + sizeOf(wordSearch[0]) - 2) map (i) -> do {
        var skewedDownChars: Array<String> = (0 to sizeOf(wordSearch[0]) - 1) map (j) -> do {
            var pos = i - j
            ---
            if (pos < 0 or pos >= sizeOf(wordSearch[0])) " " else wordSearch[pos][j] default ""
        } 
        ---
        skewedDownChars joinBy ""
    }
    
fun skewedUp(ws: Array<String>): Array<String> =
    (0 to sizeOf(wordSearch) + sizeOf(wordSearch[0]) - 2) map (i) -> do {
        var skewedUpChars: Array<String> = (0 to sizeOf(wordSearch[0]) - 1) map (j) -> do {
            var pos = i - (sizeOf(wordSearch[0]) - j - 1)
            ---
            if (pos < 0 or pos >= sizeOf(wordSearch[0])) " " else wordSearch[pos][j] default ""
        }
        ---
        skewedUpChars joinBy ""
    }


fun findXmases(line: String): Number = do {
    var xmasCount = sizeOf(flatten(line find /XMAS/))
    var smaxCount = sizeOf(flatten(line find /SAMX/))
    ---
    xmasCount + smaxCount
}
fun findHorizontalXMAS(ws: Array<String>): Number = do {
    var lineCounts = ws map (line) -> findXmases(line)
    ---
    sum(lineCounts)
}

fun findVerticalXMAS(ws: Array<String>): Number =
    findHorizontalXMAS(pivot(ws))

fun findDiagonalXMAS(ws: Array<String>) =
    findHorizontalXMAS(skewedDown(ws)) + findHorizontalXMAS(skewedUp(ws))

fun findMAS(ws: Array<String>) = do {
    var mases = ws map (line) -> line find /MAS/
    var sams = ws map (line) -> line find /SAM/
    ---
    (0 to sizeOf(ws)) map (i) -> flatten(mases[i]) default [] ++ flatten(sams[i]) default []
}
    