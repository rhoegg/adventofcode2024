%dw 2.0
import * from dw::core::Arrays
import * from dw::core::Objects
import * from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

type Challenge = {
    patterns: Array<String>,
    designs: Array<String>
}

fun parseChallenge(puzzleInput: String): Challenge = do {
    var parts = puzzleInput splitBy "\n\n"
    ---
    {
        patterns: parts[0] splitBy ", ",
        designs: lines(parts[1])
    }
}

fun possible(design: String, patterns: Array<String>): Boolean =
    if (isEmpty(design)) true else do {
        var forLog = log("checking", design)
        var usefulPatterns = log("matched", patterns filter (p) -> design startsWith p)
        ---
        if (now() > deadline) do {
            var forLog = log("exceeded deadline")
            ---
            false
        } else if (isEmpty(usefulPatterns)) false
        else (usefulPatterns orderBy (-1 * sizeOf($))) some (pattern) ->
            possible(design substringAfter pattern, patterns)
    }

// make a new one that caches as it goes

fun possible2(design: String, patterns: Array<String>, count = 0, prefixes: Array<String> = [""]): Boolean =
    if (isEmpty(prefixes) or (prefixes contains design)) do {
        var forLog = log("needed iterations", count)
        ---
        prefixes contains design
    }
    else do {
        var prefixOptions = prefixes flatMap (prefix) ->
            patterns map (pattern) -> prefix ++ pattern
        var potentialSolutions = prefixOptions filter (prefix) -> design startsWith prefix
        ---
        possible2(design, patterns, count + 1, potentialSolutions)
    }

@TailRec()
fun possible3(designs: Array<String>, patterns: Array<String>, badDesignsCache = {}): {result: Boolean, cache: Object} =
    if (isEmpty(designs)) {result: false, cache: badDesignsCache}
    else if (now() > deadline) do {
        var forLog = log("deadline exceeded")
        ---
        {result: false, cache: badDesignsCache}
    }
    else do {
        var thisDesign = designs[0]
        ---
        if (thisDesign == "") {result: true, cache: badDesignsCache}
        else do {
            var remainingDesigns = (designs drop 1)
            var knownImpossible = badDesignsCache[thisDesign]?
            var usefulPatterns = if (knownImpossible) [] 
                else patterns filter (p) -> thisDesign startsWith p
            var newDesigns = (usefulPatterns map (p) -> thisDesign substringAfter p)
            var cacheCheck = newDesigns partition (d) -> badDesignsCache[d]?
            var knownBadDesigns = cacheCheck.success
            var potentialDesigns = cacheCheck.failure
            var nextCache = (if (isEmpty(potentialDesigns)) badDesignsCache mergeWith {(thisDesign): false} 
                else badDesignsCache) mergeWith {(knownBadDesigns map (d) -> {(thisDesign ++ d): false})}
            var nextDesigns = if (isEmpty(potentialDesigns)) remainingDesigns
                else (remainingDesigns ++ potentialDesigns) orderBy sizeOf($)
            ---
            possible3(nextDesigns, patterns, nextCache)
        }
    }

var deadline = now() + |PT40M|
fun countCombos(design: String, patterns: Array<String>, state = {prefixStack: [""], combos: 0, suffixCache: null}): Number = do {
    var cache = state.suffixCache default {( patterns map (p) -> {(p): 1} )}
    ---
    if (isEmpty(state.prefixStack)) state.combos
    else if (now() > deadline) do {
        var forLog = log('deadline exceeded')
        ---
        state.combos
    }
    else do {
        var prefix: String = state.prefixStack[0]
        var remainingPrefixes = state.prefixStack drop 1
        var usefulPatterns = patterns filter (p) -> (design startsWith (prefix ++ p))
        var remainingDesign = design substringAfter prefix
        var possibles = usefulPatterns map (p) -> {
            pattern: p,
            suffix: remainingDesign substringAfter p
        }
        var cacheCheck = possibles partition (possible) -> cache[possible.suffix]?
        var forLog = if (! isEmpty(cacheCheck.success)) log("cache hit", cacheCheck.success) else []
        // add count from cached suffixes
        var countFromCache = cacheCheck.success sumBy (possible) -> cache[possible.suffix]
        // put the rest of the prefixes on the stack
        var newPrefixes = possibles map (possible) -> (prefix ++ possible.pattern)
        var newStack = newPrefixes ++ remainingPrefixes
        // put suffixes we learned from cache hits in the cache
        var newCache = cache mergeWith {( 
            cacheCheck.success map (patternInfo) -> do {
                var comboPattern = patternInfo.pattern ++ patternInfo.suffix
                var oldCount = cache[comboPattern] default 0
                ---
                {(comboPattern): oldCount + 1}
            }
        )}
        ---
        countCombos(design, patterns, {prefixStack: newStack, combos: state.combos + countFromCache, cache: newCache})
    }
}

fun countTowelCombos(patterns: Array<String>, design: String, cache = {}): {combinations: Number, cache: Object} =
    countCombos2(patterns, [{
        design: design,
        combinations: 0,
        suffixes: [design]
    }], {combinations: 0, cache: cache})

type TowelDesign = {
    design: String,
    combinations: Number,
    // one per matching pattern, with the pattern removed
    suffixes: Array<String>
}

@TailRec()
fun countCombos2(patterns: Array<String>, designStack: Array<TowelDesign>, state: {combinations: Number, cache: Object}): {combinations: Number, cache: Object} =
    if (isEmpty(designStack)) state
    else do {
        var thisDesignInfo = designStack[0]
        var poppedStack = designStack drop 1
        var nextStack = if (isEmpty(thisDesignInfo.suffixes)) do { // this is the moment where a design is fully counted
            if (isEmpty(poppedStack)) [] // last one
            else do {
                var parentDesignInfo = poppedStack[0]
                var doublePoppedStack = poppedStack drop 1
                var updatedDesignInfo = parentDesignInfo update {
                    case c at .combinations -> c + thisDesignInfo.combinations
                }
                ---
                updatedDesignInfo >> doublePoppedStack
            }
        } else do {
                var firstDesign = thisDesignInfo.suffixes[0]
                var nextDesignInfo = thisDesignInfo update {
                    case s at .suffixes -> s drop 1
                }
                
                var suffixDesignInfo: TowelDesign = if (state.cache[firstDesign]?) {
                    design: firstDesign,
                    combinations: state.cache[firstDesign],
                    suffixes: []
                } else do {
                    var usefulPatterns = if (isEmpty(firstDesign)) [] 
                        // this will include the case when the design is one of the patterns
                        else patterns filter (pattern) -> firstDesign startsWith pattern
                    ---
                    {
                        design: firstDesign,
                        combinations: if (isEmpty(firstDesign)) 1 else 0,
                        suffixes: usefulPatterns map (pattern) -> firstDesign substringAfter pattern
                    }
                }
                ---
                suffixDesignInfo >> (nextDesignInfo >> poppedStack)
            }
        var nextState = if (isEmpty(thisDesignInfo.suffixes)) {
            combinations: thisDesignInfo.combinations,
            cache: state.cache ++ {(thisDesignInfo.design): thisDesignInfo.combinations}
        } else state // only incrementing combinations when we finish something
        ---
        countCombos2(patterns, nextStack, nextState)
    }