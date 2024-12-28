%dw 2.0
output application/json
import * from Geometry
import * from MySolution

var reindeerMaze = parseReindeerMaze(rawInput)
var solved = solve(reindeerMaze)
---
{
    score: solved.score,
    tiles: sizeOf(solved.paths flatMap $ distinctBy $.location),
    paths: solved.paths
}