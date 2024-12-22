%dw 2.0
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type Point = {x: Number, y: Number}
type ClawMachine = {
    a: Point,
    b: Point,
    prize: Point
}

type Plan = {
    a: Number,
    b: Number
}

fun parseClawMachines(puzzleInput: String): Array<ClawMachine> = do {
    var machineInputs: Array<String> = puzzleInput splitBy "\n\n"
    ---
    machineInputs map (machineInput) -> do {
        var machineLines = lines(machineInput)
        var textA = machineLines[0] substringAfter "Button A: "
        var textB = machineLines[1] substringAfter "Button B: "
        var textPrize = machineLines[2] substringAfter "Prize: "
        var a: Point = textA splitBy ", " then (parts) -> {
            x: (parts[0] substringAfter "X+") as Number,
            y: (parts[1] substringAfter "Y+") as Number
        }
        var b: Point = textB splitBy ", " then (parts) -> {
            x: (parts[0] substringAfter "X+") as Number,
            y: (parts[1] substringAfter "Y+") as Number
        }
        var prize: Point = textPrize splitBy ", " then (parts) -> {
            x: (parts[0] substringAfter "X=") as Number,
            y: (parts[1] substringAfter "Y=") as Number
        }
        ---
        { a: a, b: b, prize: prize }
    }
}

// iterative solution
fun winningPlans(clawMachine: ClawMachine): Array<Plan> = do {
    var potentialAbyX = (1 to floor(clawMachine.prize.x/clawMachine.a.x)) filter (a) ->
        (a * clawMachine.a.x mod clawMachine.b.x) == (clawMachine.prize.x mod clawMachine.b.x)
    var potentialA = potentialAbyX filter (a) ->
        (a * clawMachine.a.y mod clawMachine.b.y) == (clawMachine.prize.y mod clawMachine.b.y)
    var winningA = potentialA filter (a) ->
        (((clawMachine.prize.x - (a * clawMachine.a.x)) mod clawMachine.b.x) == 0)
        and (((clawMachine.prize.y - (a * clawMachine.a.y)) mod clawMachine.b.y) == 0)
    var winningPlans = winningA map (a) -> {
        a: a,
        b: (clawMachine.prize.x - (a * clawMachine.a.x)) / clawMachine.b.x
    }
    ---
    winningPlans filter (plan) -> plan.a <= 100 and plan.b <= 100
}

fun tokens(plan: Plan): Number =
    3*plan.a + plan.b

fun algebraicPlan(clawMachine: ClawMachine): Plan = do {
    // x = (ce - bf) / (ae - bd)
    var a = (clawMachine.prize.x * clawMachine.b.y - clawMachine.b.x * clawMachine.prize.y)
        / (clawMachine.a.x * clawMachine.b.y - clawMachine.b.x * clawMachine.a.y)
    // y = (c - ax) / b
    var b = (clawMachine.prize.x - clawMachine.a.x * a) / clawMachine.b.x
    ---
    { a: a, b: b }
}
