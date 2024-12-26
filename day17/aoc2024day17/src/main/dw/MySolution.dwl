%dw 2.0
import * from Bitwise
import fail from dw::Runtime
import * from dw::core::Arrays
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")


type Program = Array<Number>
type Computer = {
    a: Number,
    b: Number,
    c: Number,
    program: Program,
    instructionPointer: Number
}
type Instruction = "adv" | "bxl" | "bst" | "jnz" | "bxc" | "out" | "bdv" | "cdv"
type ComputerState = {
    computer: Computer,
    programOutput?: Array<Number>
}

// using array index as opcode
var instructions: Array<Instruction> = ["adv", "bxl", "bst", "jnz", "bxc", "out", "bdv", "cdv"]

fun parseProgramInfo(puzzleInput: String): Computer = do {
    var parts = puzzleInput splitBy "\n\n"
    var registerLines = lines(parts[0])
    var programCodes = parts[1] substringAfter "Program: "
    fun parseRegister(registerLine: String): Number = (registerLine splitBy(": "))[1] as Number
    ---
    {
        a: parseRegister(registerLines[0]),
        b: parseRegister(registerLines[1]),
        c: parseRegister(registerLines[2]),
        program: (programCodes splitBy ",") map (text) -> text as Number,
        instructionPointer: 0
    }
}

fun run(computer: Computer): ComputerState = runState({computer: computer})

@TailRec()
fun runState(state: ComputerState): ComputerState = do {
    var computer = state.computer
    ---
    if (computer.instructionPointer >= sizeOf(computer.program)) state
    else do {
        fun combo(operand: Number): Number = if (operand < 4) operand
            else operand  match {
                case 4 -> computer.a
                case 5 -> computer.b
                case 6 -> computer.c
                else -> fail("unexpected combo operand $(operand)")
            }
        var opcode = instructions[computer.program[computer.instructionPointer]]
        var operandValue = computer.program[computer.instructionPointer + 1]
        var operand = opcode match {
            case "adv" -> combo(operandValue)
            case "bxl" -> operandValue
            case "bst" -> combo(operandValue)
            case "jnz" -> operandValue
            case "bxc" -> operandValue
            case "out" -> combo(operandValue)
            case "bdv" -> combo(operandValue)
            case "cdv" -> combo(operandValue)
        }
        // jnz
        var nextInstruction = if (opcode == "jnz" and computer.a != 0) operand
            else computer.instructionPointer + 2
        // out
        var nextOutput = if (opcode != "out") state.programOutput default []
            else (state.programOutput default []) << (operand mod 8)
        // adv, bxl, bst, bxc, bdv
        var registers = opcode match {
            case "adv" -> do {
                var a = floor(computer.a/(2 pow operand))
                ---
                {a: a, b: computer.b, c: computer.c}
            }
            case "bxl" -> do {
                var b = computer.b XOR operand
                ---
                {a: computer.a, b: b, c: computer.c}
            }
            case "bst" -> do {
                var b = operand mod 8
                ---
                {a: computer.a, b: b, c: computer.c}
            }
            case "bxc" -> do {
                var b = computer.b XOR computer.c
                ---
                {a: computer.a, b: b, c: computer.c}
            }
            case "bdv" -> do {
                var b = floor(computer.a/(2 pow operand))
                ---
                {a: computer.a, b: b, c: computer.c}
            }
            case "cdv" -> do {
                var c = floor(computer.a/(2 pow operand))
                ---
                {a: computer.a, b: computer.b, c: c}
            }
            else -> {a: computer.a, b: computer.b, c: computer.c} // some opcodes don't change registers
        }
        var nextComputer = registers ++ {
            program: computer.program,
            instructionPointer: nextInstruction
        }
        ---
        runState({ computer: nextComputer, programOutput: nextOutput })
    }
}

fun printProgram(p: Program): Array<String> = do {
    fun combo(operand: Number): String = if (operand < 4) operand as String
        else operand  match {
            case 4 -> "A"
            case 5 -> "B"
            case 6 -> "C"
            else -> "X"
        }
    var commands = (p divideBy 2) map (pair) -> do {
        var opcode = instructions[pair[0]]
        var operandValue = pair[1]
        var operand = opcode match {
            case "adv" -> combo(operandValue)
            case "bxl" -> operandValue
            case "bst" -> combo(operandValue)
            case "jnz" -> operandValue
            case "bxc" -> operandValue
            case "out" -> combo(operandValue)
            case "bdv" -> combo(operandValue)
            case "cdv" -> combo(operandValue)
        }
        ---
        "$(opcode) $(operand)"
    }
    ---
    commands
}

