%dw 2.0
import * from Geometry
import * from dw::core::Arrays
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var sampleInput2 = readUrl("classpath://sample2.txt", "text/plain")
var sampleInput3 = readUrl("classpath://sample3.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type BigBox = Pair<Point, Point>
type WarehouseState = {
    dimensions: Dimensions,
    walls: Array<Point>,
    boxes: Array<Point>,
    robot: Point
}

type Situation = {
    warehouse: WarehouseState,
    moves: String // directions
}

type BigWarehouseState = {
    dimensions: Dimensions,
    walls: Array<Point>,
    boxes: Array<BigBox>,
    robot: Point
}

type SecondSituation = {
    warehouse: BigWarehouseState,
    moves: String // directions
}

fun parseMapRow(text: String, y: Number) = 
    (text splitBy "") map (c, x) -> {
        c: c,
        location: { x: x, y: y }
    }
fun parseSituation(puzzleInput: String): Situation = do {
    var parts = puzzleInput splitBy "\n\n"
    var mapData = lines(parts[0]) flatMap(line, y) -> parseMapRow(line, y)
    var warehouse: WarehouseState = mapData reduce (datapoint, state = {dimensions: {width: 0, height: 0}, walls: [], boxes: [], robot: {x: -1, y: -1}}) ->
        if (datapoint.c == "@") state update { case .robot -> datapoint.location }
        else if (datapoint.c == "#") state update {
            case d at .dimensions -> d expandToInclude datapoint.location
            case w at .walls -> w << datapoint.location 
        }
        else if (datapoint.c == "O") state update { case b at .boxes -> b << datapoint.location }
        else state // ignoring .
    ---
    {
        warehouse: warehouse,
        moves: parts[1] splitBy "\n" joinBy ""
    }
}

fun parseSecondSituation(puzzleInput: String): SecondSituation = do {
    var parts = puzzleInput splitBy "\n\n"
    var mapData = lines(parts[0]) flatMap (line, y) -> parseMapRow(line, y)
    var warehouse: BigWarehouseState = mapData reduce (datapoint, state = {dimensions: {width: 0, height: 0}, walls: [], boxes: [] as Array<BigBox>, robot: {x: -1, y: -1}}) -> do {
        var left = datapoint.location update { case x at .x -> x * 2 }
        var right = datapoint.location update { case x at .x -> x * 2 + 1 }
        ---
        if (datapoint.c == "@") state update { case .robot -> left }
        else if (datapoint.c == "#") state update {
            case d at .dimensions -> d expandToInclude right
            case w at .walls -> w << left << right
        }
        else if (datapoint.c == "O") state update { case b at .boxes -> b << {l: left, r: right}}
        else state // ignoring . again
    }
    ---
    {
        warehouse: warehouse,
        moves: parts[1] splitBy "\n" joinBy ""
    }
}

fun printWarehouse(warehouse: WarehouseState) = do {
    var printLines = (0 to warehouse.dimensions.height - 1) map (y) -> do {
        var chars = (0 to warehouse.dimensions.width - 1) map (x) -> do {
            var p: Point = {x: x, y: y}
            ---
            if (warehouse.robot == p) "@"
            else if (warehouse.walls contains p) "#"
            else if (warehouse.boxes contains p) "O"
            else "."
        }
        ---
        chars joinBy ""
    }
    ---
    printLines //joinBy "\n"
}

fun printBigWarehouse(warehouse: BigWarehouseState) = do {
    var printLines = (0 to warehouse.dimensions.height - 1) map (y) -> do {
        var chars = (0 to warehouse.dimensions.width - 1) map (x) -> do {
            var p: Point = {x: x, y: y}
            ---
            if (warehouse.robot == p) "@"
            else if (warehouse.walls contains p) "#"
            else if (warehouse.boxes map $.l contains p) "["
            else if (warehouse.boxes map $.r contains p) "]"
            else "."
        }
        ---
        chars joinBy ""
    }
    ---
    printLines // joinBy "\n"
}

fun anticipate(s: Situation): Situation = if (isEmpty(s.moves)) s
    else do {
        var nextWarehouse = move(s.warehouse, s.moves[0])
        ---
        anticipate({warehouse: nextWarehouse, moves: s.moves[1 to -1] default ""})
    }

fun anticipateBig(s: SecondSituation): SecondSituation = if (isEmpty(s.moves)) s
    else do {
        var nextWarehouse = moveBig(s.warehouse, s.moves[0])
        ---
        anticipateBig({warehouse: nextWarehouse, moves: s.moves[1 to -1] default ""})
    }

fun move(warehouse: WarehouseState, dir: Direction): WarehouseState = do {
    var targetPoint = step(warehouse.robot, dir)
    ---
    if (warehouse.walls contains targetPoint) warehouse
    else if (warehouse.boxes contains targetPoint) do {
        var boxes = moveBoxes(warehouse, dir)
        ---
        warehouse update {
            case .boxes -> boxes
            case r at .robot -> if (boxes == warehouse.boxes) r else targetPoint
        }
    }
    else warehouse update {
        case .robot -> targetPoint
    }
}

fun moveBig(warehouse: BigWarehouseState, dir: Direction): BigWarehouseState = do {
    var targetPoint = step(warehouse.robot, dir)
    ---
    if (warehouse.walls contains targetPoint) warehouse
    else if (warehouse.boxes some (b) -> b intersects targetPoint) do {
        var pushed = moveBigBoxes(warehouse, dir)
        ---
        warehouse update {
            case .boxes -> pushed
            case r at .robot -> if (pushed == warehouse.boxes) r else targetPoint
        }
    }
    else warehouse update {
        case .robot -> targetPoint
    }
}

fun moveBoxes(warehouse: WarehouseState, dir: Direction): Array<Point> = do {
    var nextStep = step(warehouse.robot, dir)
    var boxTarget = nextEmpty(warehouse, warehouse.robot, dir)
    ---
    if (boxTarget == null) warehouse.boxes
    else (warehouse.boxes - nextStep) << boxTarget
}

fun moveBigBoxes(warehouse: BigWarehouseState, dir: Direction): Array<BigBox> = do {
    var nextStep = step(warehouse.robot, dir)
    fun pushBigBoxes(forcePoints: Array<Point>, remaining: Array<BigBox>, moved: Array<BigBox> = []): {forcePoints: Array<Point>, remaining: Array<BigBox>, moved: Array<BigBox>} = do {
        var checkBoxes = remaining partition (b) -> forcePoints some (p) -> b intersects p
        var pushedBoxes = checkBoxes.success
        var untouchedBoxes = checkBoxes.failure
        ---
        if (isEmpty(pushedBoxes)) {forcePoints: [], remaining: remaining, moved: moved}
        else do {
            var movedBoxes = pushedBoxes map (b) -> move(b, dir)
            ---
            // if any hit a wall, forget the whole maneuver and all the boxes stay where they started
            if (movedBoxes some (b) -> (warehouse.walls contains b.l) or (warehouse.walls contains b.r))
                {forcePoints: [], remaining: warehouse.boxes, moved: []}
            else do {
                var nextForcePoints = dir match {
                    case "<" -> movedBoxes map (b) -> b.l
                    case ">" -> movedBoxes map (b) -> b.r
                    else -> movedBoxes flatMap (b) -> [b.l, b.r] as Array<Point>
                }
                ---
                pushBigBoxes(nextForcePoints, untouchedBoxes, moved ++ movedBoxes)
            }
        }
    }

    var boxesAfterPush = pushBigBoxes([nextStep], warehouse.boxes)
    ---
    if (isEmpty(boxesAfterPush.moved)) warehouse.boxes
    else boxesAfterPush.moved ++ boxesAfterPush.remaining
}

fun nextEmpty(warehouse: WarehouseState, p: Point, d: Direction): Point | Null = do {
    var nextStep = step(p, d)
    ---
    if (warehouse.walls contains nextStep) null
    else if (warehouse.boxes contains nextStep) nextEmpty(warehouse, nextStep, d)
    else nextStep
}

fun intersects(b: BigBox, p: Point): Boolean =
    b.l == p or b.r == p

fun move(b: BigBox, d: Direction): BigBox =
    {l: step(b.l, d), r: step(b.r, d)}