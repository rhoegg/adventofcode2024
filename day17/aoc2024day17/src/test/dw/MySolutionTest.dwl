%dw 2.0
import * from dw::test::Tests
import * from dw::test::Asserts

import * from MySolution
---
"MySolution" describedBy [
    "run" describedBy [
        "example 1" in do {
            var c: Computer = {a: 0, b: 0, c: 9, program: [2, 6], instructionPointer: 0}
            var result = run(c)
            ---
            result.computer.b must equalTo(1)
        },
        "example 2" in do {
            var c: Computer = {a: 10, b: 0, c: 0, program: [5, 0, 5, 1, 5, 4], instructionPointer: 0}
            var result = run(c)
            ---
            result.programOutput must equalTo([0, 1, 2])
        },
        "example 3" in do {
            var c: Computer = {a: 2024, b: 0, c: 0, program: [0, 1, 5, 4, 3, 0], instructionPointer: 0}
            var result = run(c)
            ---
            result.programOutput must equalTo([4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0])
        },
        "example 4" in do {
            var c: Computer = {a: 0, b: 29, c: 0, program: [1, 7], instructionPointer: 0}
            var result = run(c)
            ---
            result.computer.b must equalTo(26)
        },
        "example 5" in do {
            var c: Computer = {a: 0, b: 2024, c: 43690, program: [4, 0], instructionPointer: 0}
            var result = run(c)
            ---
            result.computer.b must equalTo(44354)
        },
        "sample" in do {
            var c: Computer = {a: 729, b: 0, c: 0, program: [0,1,5,4,3,0], instructionPointer: 0}
            var result = run(c)
            ---
            result.programOutput must equalTo([4,6,3,5,6,3,5,2,1,0])
        }
    ],
]
