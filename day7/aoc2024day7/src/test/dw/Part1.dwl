%dw 2.0
output application/json
import * from dw::core::Arrays
import * from MySolution
var challenge = parseCalibrations(rawInput)

fun possibleResults(ops: Array<Number>): Array<Number> =
    if (sizeOf(ops) < 2) ops
    else do {
        var sum = ops[0] + ops[1]
        var product = ops[0] * ops[1]
        var rest = ops drop 2
        ---
        possibleResults(sum >> rest) ++ possibleResults(product >> rest)
    }

var allPossibilities = challenge map (c) ->
    {
        testValue: c.testValue,
        possibilities: possibleResults(c.operators)
    }
var goodOnes = allPossibilities filter (p) -> p.possibilities contains p.testValue
---
sum(goodOnes map (p) -> p.testValue)