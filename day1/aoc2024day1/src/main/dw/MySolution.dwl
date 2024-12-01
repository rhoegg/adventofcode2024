%dw 2.0
import * from dw::core::Strings

var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")
var sampleInput = readUrl("classpath://sample.txt", "text/plain")

fun lists(puzzleInput) = do {
    var parsedLines = lines(puzzleInput) map (line) -> do {
        var words = line splitBy /\s+/
        ---
        words map (word) -> word as Number
    }
        
    ---
    unzip(parsedLines)
}

