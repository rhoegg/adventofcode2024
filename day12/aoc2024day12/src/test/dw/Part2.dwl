%dw 2.0
output application/json
import * from dw::core::Arrays
import * from MySolution

var troubleSample = readUrl("classpath://sample6.txt", "text/plain")

var farm = parseGardenPlots(rawInput)
var regions = findRegions(farm)
var regionStats = regions map (r) -> do {
    var regionInfo = sides(farm, r)
    ---
    {region: r} ++ regionInfo
}

type FenceOrder = {
    fences: Array<Fence>,
    sides: Number
}

var fenceOrders: Array<FenceOrder> = (regionStats map (s) -> {fences: s.fences, sides: s.sides})
var orderedFences = fenceOrders flatMap (o) -> o.fences
var neededFences = (regionStats flatMap (s) -> s.neighbors) -- orderedFences

fun followFence(origin: Fence): {fences: Array<Fence>, sides: Number} = do {
    // following keeping fences on the right
    fun follow(fence: Fence = origin, fences: Array<Fence> = [], s: Number = 1): {fences: Array<Fence>, sides: Number} = do {
        if (fence == origin and not isEmpty(fences)) {fences: fences, sides: s - 1}
        else do {
            var otherSidePosition = neighbor(fence.plot.position, fence.direction)
            var nextFollowPosition = neighbor(fence.plot.position, left(fence.direction))
            var otherSidePlot = farm.plots[otherSidePosition.y][otherSidePosition.x]
            var nextFencePlot = farm.plots[nextFollowPosition.y][nextFollowPosition.x]
            
            var isOtherSideSame = otherSidePlot.plant == fence.plot.plant
            var isContinueSame = nextFencePlot.plant == fence.plot.plant

            var nextFence: Fence = if (isOtherSideSame) {plot: otherSidePlot, direction: right(fence.direction)}
                else if (isContinueSame) {plot: nextFencePlot, direction: fence.direction}
                else {plot: fence.plot, direction: left(fence.direction)}
            var newFences  = if (isOtherSideSame) []
                else [fence]
            var newSides = if (isOtherSideSame) s + 1
                else if (isContinueSame) s
                else s + 1
            ---
            follow(nextFence, fences ++ newFences, newSides)
        }
    }
    ---
    follow()
}

fun completeFenceOrders(orders: Array<FenceOrder>, needed: Array<Fence>): Array<FenceOrder> = 
    if (isEmpty(needed)) orders
    else do {
        var newOrder = followFence(needed[0])
        ---
        completeFenceOrders(orders << newOrder, needed -- newOrder.fences)
    }

var allFenceOrders = completeFenceOrders(fenceOrders, neededFences)
var regionOrderInfo = allFenceOrders map (order) -> {
    region: (regions firstWith (r) -> r.plots contains order.fences[0].plot).number,
    sides: order.sides
}
var regionSidesSummary = (regionOrderInfo groupBy $.region) mapObject (regionData, regionNum) -> { (regionNum): sum(regionData.sides) }

var regionPriceInputs = regions map (r) -> {
    area: sizeOf(r.plots),
    sides: regionSidesSummary[r.number as String] default 0
}
---
regionPriceInputs sumBy (rpi) -> rpi.area * rpi.sides
