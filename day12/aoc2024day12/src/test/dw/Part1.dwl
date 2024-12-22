%dw 2.0
output application/json
import * from dw::core::Arrays
import * from MySolution

var farm = parseGardenPlots(sampleInput)
var regions = findRegions(farm)

var regionMeasures = regions map (r) -> do {
    var internalEdges = findInternalEdges(farm, r) 
    // perimeter is the area (number of plots) * 4 - the number of internal edges * 2
    ---
    {
        plant: r.plant,
        area: area(r),
        perimeter: area(r) * 4 - sizeOf(internalEdges) * 2
    }
}
---
regionMeasures sumBy (m) -> m.area * m.perimeter