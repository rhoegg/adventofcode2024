%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type Rule = {
    left: String,
    right: String
}

type SafetyManualPlan = {
    rules: Array<Rule>,
    updates: Array<Array<String>>
}

fun parsePlan(puzzleInput: String): SafetyManualPlan = do {
    var sections = puzzleInput splitBy "\n\n"
    var rules = lines(sections[0]) map (line) -> do {
        var tokens = line splitBy "|"
        ---
        {
            left: tokens[0],
            right: tokens[1]
        }
    }
    var updates = lines(sections[1]) map (line) -> 
        line splitBy ","
    ---
    {
        rules: rules,
        updates: updates
    }
}

fun violates(update: Array<String>, rule: Rule): Boolean = do {
        var pagesAfterRight = update dropWhile (page) -> page != rule.right
        ---
        pagesAfterRight contains rule.left
    }


fun correctOrder(rules: Array<Rule>, update: Array<String>): Boolean =
    not (rules some (rule) -> update violates rule)

fun fixUpdate(u: Array<String>, rules: Array<Rule>): Array<String> = do {
    var ruleToFix = rules firstWith (rule) ->
        u violates rule
    ---
    if (ruleToFix == null) u // good we're done now
    else do {
        var withoutRightPage = u - ruleToFix.right
        var splitUpdate = withoutRightPage splitWhere (p) -> p == ruleToFix.left
        ---
        fixUpdate(splitUpdate.l ++ [ruleToFix.left, ruleToFix.right] ++ (splitUpdate.r drop 1), rules)
    }
}