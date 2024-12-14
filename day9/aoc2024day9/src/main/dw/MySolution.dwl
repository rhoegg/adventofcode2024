%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Strings

var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")
var sampleInput = readUrl("classpath://sample.txt", "text/plain")

type Block = {
    free: Boolean,
    id?: Number
}

var freeBlock = {free: true}
var debugBlock = {free: false, id: " "}
fun repeat<T>(n: Number, generator: () -> T): Array<T> =
    ((0 to n) map generator()) drop 1 // handle 0

fun parseDiskMap(puzzleInput: String): Array<Block> = do {
    var pairs = puzzleInput
        splitBy "" 
        map ((c) -> c as Number)
        divideBy 2
    var lengths = pairs map (pair) -> {
        fileLength: pair[0],
        freeSpaceLength: pair[1] default 0
    }

    fun toBlocks(l, id): Array<Block> =
        repeat(l.fileLength, () -> {free: false, id: id})
        ++ repeat(l.freeSpaceLength, () -> {free: true})
    ---
    (lengths flatMap (l, id) -> toBlocks(l, id)) as Array<Block>
}

var maxRuntime = |PT55M|
fun compact(diskMap: Array<Block>, knownCompact = 0, deadline = now() + maxRuntime): Array<Block> = do {
    // var forLog = log("compacting", diskMap joinBy "")
    var knownComplete = slice(diskMap, 0, knownCompact)
    var mapToCheck = slice(diskMap, knownCompact, sizeOf(diskMap))
    var parts = mapToCheck splitWhere (b) -> b.free
    var newComplete = parts[0]
    var completed = knownComplete ++ newComplete
    var expired = if (now() > deadline) do {
        var forLog = log("expired after $(maxRuntime) with $(sizeOf(completed)) done")
        ---
        true
    } else false
    var remaining = parts[1]
    ---
    if ((remaining every (b) -> b.free) or expired) diskMap
    else do {
        // first block of remaining is free, replace with last non-free
        var remainingPartsReversed = remaining[-1 to 0] splitWhere (b) -> not b.free
        var freeSpace = remainingPartsReversed[0] // these are all free so no need to reverse again
        var uncompacted = remainingPartsReversed[1][-1 to 0] // reverse again to put back in correct order
        var compacted = uncompacted[-1] >> uncompacted[1 to -2] << freeBlock // drop head and tail and append free space
        ---
        compact(completed ++ compacted ++ freeSpace, knownCompact + sizeOf(newComplete), deadline)
    }
}

fun checksum(diskMap: Array<Block>): Number = do {
    var values = diskMap map (b, i) -> {
        value: if (b.free) 0 else b.id default 0,
        index: i
    }
    ---
    values reduce (v, checksum = 0) ->
        v.value * v.index + checksum
}

fun lastFileSize(diskMap: Array<Block>, id: Number): Number =
    if (diskMap[-1].free or diskMap[-1].id != id) 0
    else 1 + lastFileSize(diskMap[0 to -2], id)

fun indexOfNextFree(diskMap: Array<Block>, index: Number, reachedNextFile = false): Number =
    if (index >= sizeOf(diskMap)) -1
    else if (not reachedNextFile) do {
        if (diskMap[index].free) indexOfNextFree(diskMap, index + 1, false)
        else indexOfNextFree(diskMap, index + 1, true)
    } else do {
        if (diskMap[index].free) index
        else indexOfNextFree(diskMap, index + 1, true)
    }

fun findIndexWhereContiguousFree(diskMap: Array<Block>, size: Number, startIndex = 0): Number =
    if (startIndex == -1 or startIndex > sizeOf(diskMap)) -1
    else if (slice(diskMap, startIndex, startIndex + size) every (b) -> b.free) startIndex
    else findIndexWhereContiguousFree(diskMap, size, indexOfNextFree(diskMap, startIndex))

fun debugMap(diskMap): String =
    (diskMap map (b) -> if (b.free) "F" else (b.id as String)[0]) joinBy ""

fun compactWholeFiles(diskMap: Array<Block>, maxFileId = 10000000, head: Array<Block> = [], tail: Array<Block> = []): Array<Block> = 
    if (isEmpty(diskMap)) head ++ tail // we're done
    else do {
        // var forLog = log(debugMap(head ++ [debugBlock] ++ diskMap ++ [debugBlock] ++ tail))
        var compactedUntilIndex = diskMap indexWhere (b) -> b.free
        var trailingFreeBlocks = (diskMap[-1 to 0]) indexWhere (b) -> not b.free
        ---
        if (compactedUntilIndex + trailingFreeBlocks == sizeOf(diskMap)) head ++ diskMap ++ tail // we're done
        else do {
            var trailingFreeIndex = sizeOf(diskMap) - trailingFreeBlocks
            var mapToCompact = slice(diskMap, compactedUntilIndex, trailingFreeIndex)
            var lastFileId = mapToCompact[-1].id as Number
            var size = lastFileSize(mapToCompact, lastFileId)
            var bestAvailableIndex = findIndexWhereContiguousFree(mapToCompact, size)
            var fileStaysPut = lastFileId > maxFileId or bestAvailableIndex == -1
            var compactedMap: Array<Block> = if (fileStaysPut) mapToCompact[0 to sizeOf(mapToCompact) - size - 1]
                else (if (bestAvailableIndex == 0) [] else mapToCompact[0 to bestAvailableIndex - 1])
                ++ repeat(size, () -> mapToCompact[-1]) as Array<Block>
                ++ slice(mapToCompact, bestAvailableIndex + size, sizeOf(mapToCompact) - size)
                ++ repeat(size, () -> freeBlock) as Array<Block>
            // var forLog = log("compacted", compactedMap)

            var newHead = head ++ slice(diskMap, 0, compactedUntilIndex)
            var newTail = (if (fileStaysPut) repeat(size, () -> mapToCompact[-1]) else [])
                ++ slice(diskMap, trailingFreeIndex, sizeOf(diskMap)) ++ tail
            ---
            if (lastFileId < 2) newHead ++ compactedMap ++ newTail
            else compactWholeFiles(compactedMap, if (lastFileId > maxFileId) maxFileId else lastFileId, newHead, newTail)
        }
    }
    