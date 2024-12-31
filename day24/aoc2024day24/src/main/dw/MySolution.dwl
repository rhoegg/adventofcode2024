
%dw 2.0
import lines from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var sampleInput2 = readUrl("classpath://sample2.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")
type LogicGate = (l: Boolean, r: Boolean) -> Boolean
var AND: LogicGate = (l: Boolean, r: Boolean) -> l and r
var XOR: LogicGate = (l: Boolean, r: Boolean) -> l != r
var OR: LogicGate = (l: Boolean, r: Boolean) -> l or r

type Gate = {
    l: String,
    r: String,
    logicName: String,
    logic: LogicGate
}

type MonitoringDevice = {
    wireValues: Object,
    connections: Object
}
fun parseMonitoringDevice(puzzleInput: String): MonitoringDevice = do {
    var parts = puzzleInput splitBy "\n\n"
    var wireValues = {(lines(parts[0]) map (line) -> do {
        var wireParts = line splitBy ": "
        ---
        {
            (wireParts[0]): wireParts[1] == "1"
        }
    })}
    var connections = {(lines(parts[1]) map (line) -> do {
        var connParts = line splitBy " -> "
        var wire = connParts[1]
        var gateParts = connParts[0] splitBy " "
        var gate: Gate = {
            l: gateParts[0],
            r: gateParts[2],
            logicName: gateParts[1],
            logic: gateParts[1] match {
                case "AND" -> AND
                case "XOR" -> XOR
                case "OR" -> OR
            }
        }
        ---
        {(wire): gate}
    })}
    ---
    {
        wireValues: wireValues,
        connections: connections
    }
}

fun simulate(device: MonitoringDevice) = do {
    fun evaluate(g: Gate): Boolean = do {
        // var forLog = log("evaluating $(g.l) $(g.logicName) $(g.r)")
        var leftValue = if (device.wireValues[g.l]?) device.wireValues[g.l] else evaluate(device.connections[g.l])
        var rightValue = if (device.wireValues[g.r]?) device.wireValues[g.r] else evaluate(device.connections[g.r])
        ---
        g.logic(leftValue, rightValue)
    }

    var zValues = (device.connections filterObject (v, k) -> k startsWith "z") pluck (gate, wire) -> {
        wire: wire,
        value: evaluate(gate)
    }
    ---
    (zValues orderBy $.wire)[-1 to 0] 
        reduce (zValue, outputNumber = 0) ->
        (outputNumber * 2 + if (zValue.value) 1 else 0)
}
