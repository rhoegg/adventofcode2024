%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings
var sample = readUrl("classpath://sample.txt", "text/plain")
var sample2 = readUrl("classpath://sample2.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

fun products(program: String) = do {
    var beginIndexes = program find /mul\(\d+,\d+\)/
    var multiplerStrings = beginIndexes map (i) -> 
        program[i[0] to -1] substringBefore ')' substringAfter '('
    ---
    multiplerStrings map (s) -> do {
        var factors = (s splitBy ",") map ($ as Number)
        ---
        factors[0] * factors[1]
    }
}

fun segments(program: String) = do {
    var p = "do()" ++ program
    var beginIndexes = flatten(p find /do(?:n\'t)?\(\)/) << 0
    ---
    beginIndexes zip (beginIndexes drop 1) map (bounds) ->
        p[bounds[0] to bounds[1] - 1]
}

