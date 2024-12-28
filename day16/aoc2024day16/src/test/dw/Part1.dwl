%dw 2.0
output application/json
import * from Geometry
import * from MySolution

var reindeerMaze = parseReindeerMaze(rawInput)
// var wrongPath = readUrl("classpath://wrong-path-3.json", "application/json") map $ as Cursor
---

solve(reindeerMaze)
// printMaze(reindeerMaze, wrongPath map (c) -> c.location)