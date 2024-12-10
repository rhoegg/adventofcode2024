%dw 2.0
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type IncompleteCalibration = {
    testValue: Number,
    operators: Array<Number>
}

fun parseCalibrations(puzzleInput: String): Array<IncompleteCalibration> = lines(puzzleInput) map (line) -> do {
    var parts = line splitBy ": "
    var operatorTokens = parts[1] splitBy " "
    ---
    {
        testValue: parts[0] as Number,
        operators: operatorTokens map (t) -> t as Number
    }
}