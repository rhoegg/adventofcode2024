%dw 2.0
// part 2 is finding the swapped circuits to make an addition circuit
// https://www.101computing.net/binary-additions-using-logic-gates/
// idea: find wrong gates deductively based on how addition circuits are constructed
import drop, firstWith from dw::core::Arrays
import mergeWith from dw::core::Objects

import * from MySolution
var brokenDevice = parseMonitoringDevice(rawInput)
// actual values censored to protect the input data!
var fixes = {
    xxx: brokenDevice.connections.yyy,
    yyy: brokenDevice.connections.xxx,
    aaa: brokenDevice.connections.bbb,
    bbb: brokenDevice.connections.aaa,
    z01: brokenDevice.connections.z02,
    z02: brokenDevice.connections.z01,
    abc: brokenDevice.connections.def,
    def: brokenDevice.connections.abc
}
var fixedDevice = brokenDevice update {
    case c at .connections -> c mergeWith fixes
}

var device = fixedDevice

var operandBits = sizeOf(device.wireValues filterObject (v, k) -> k startsWith "x")

var inputWires = (0 to operandBits - 1) map (i) -> {
    x: "x" ++ (i as String {format: "00"}),
    y: "y" ++ (i as String {format: "00"})
}

var connections = device.connections pluck (c, wire) -> {
    wire: wire as String,
    l: c.l,
    r: c.r,
    gate: c.logicName
}

fun findConnection(gate: String, wire1: String | Null, wire2: String) =
    connections firstWith (c) -> c.gate == gate and (c.l == wire1 or c.r == wire1) and (c.l == wire2 or c.r == wire2)

var inputHalfAdders = inputWires map (w) -> do {
    var xorWire = connections firstWith (c) -> c.gate == "XOR" and (c.l == w.x or c.r == w.x) and (c.l == w.y or c.r == w.y)
    var andWire = connections firstWith (c) -> c.gate == "AND" and (c.l == w.x or c.r == w.x) and (c.l == w.y or c.r == w.y)
    ---
    w ++ {
        xorWire: xorWire.wire,
        andWire: andWire.wire,
    }
}

var wrong = ["xxx", "xxx", "xxx", "xxx", "xxx", "xxx", "xxx", "xxx"]

---
// I used the chain of adders to visually track down the bad steps
inputHalfAdders reduce (adder, chain=[]) -> if (isEmpty(chain)) [adder ++ {
    sum: adder.xorWire,
    carry: adder.andWire
}] else if (chain[-1].carry == null) chain << (adder ++ { expectedCIn: connections firstWith (c) -> c.gate == "XOR" and (c.l == adder.xorWire or c.r == adder.xorWire)})
    else do {
    var cIn = chain[-1].carry
    var sum = findConnection("XOR", adder.xorWire, cIn).wire
    var intermediateCarry = findConnection("AND", adder.xorWire, cIn).wire
    var cOut = findConnection("OR", intermediateCarry, adder.andWire).wire
    ---
    chain << (adder ++ {
        cIn: cIn,
        sum: sum,
        innerCarry: intermediateCarry,
        carry: cOut
    })
}
// (wrong orderBy $) joinBy ","
