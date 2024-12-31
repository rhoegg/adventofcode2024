%dw 2.0
import drop, take from dw::core::Arrays
import mergeWith from dw::core::Objects
import lines from dw::core::Strings

var sampleInput = readUrl("classpath://sample.txt", "text/plain")
var rawInput = readUrl("classpath://puzzle-input.txt", "text/plain")

fun parseLinks(puzzleInput: String): Array<Link> =
    lines(puzzleInput) map (line) -> do {
        var parts = line splitBy "-"
        ---
        {l: parts[0], r: parts[1]}
    }

type Link = Pair<String, String>
fun nodes(links: Array<Link>): Object = links reduce (link, result = {}) -> do {
    var currentNodeL = result[link.l] default []
    var currentNodeR = result[link.r] default []
    ---
    result 
        mergeWith {
            (link.l): currentNodeL << link.r,
            (link.r): currentNodeR << link.l
        }
}



type Trio = {n1: String, n2: String, n3: String}

fun findTrios(nodes: Object, nodeFilter: (String) -> Boolean) = do {
    var baseNodes = (keysOf(nodes) map ($ as String)) filter (node) -> nodeFilter(node)
    var possibleTrios: Array<Trio> = baseNodes flatMap (n1: String) -> 
        ((nodes[n1] default []) flatMap (n2) -> 
            ((nodes[n2] default []) map (n3) -> {
                n1: n1,
                n2: n2,
                n3: n3
            })) as Array<Trio>
    var trios = possibleTrios filter (trio: Object) -> ( nodes[trio.n3] contains trio.n1 )
    ---
    trios distinctBy (trio) -> toString(trio)
}

fun toString(group: Trio): String =
    (valuesOf(group) orderBy $) joinBy "-"

fun bronKerbosch(nodes: Object, r: Array<String>, p: Array<String>, x: Array<String>) = 
    if (isEmpty(p) and isEmpty(x)) [r]
    else if (isEmpty(p)) []
    else (0 to sizeOf(p) - 1) reduce (i, cliques=[]) -> do {
        cliques ++ bronKerbosch(nodes, r << p[i], 
            (p drop i) filter (n) -> nodes[p[i]] contains n,
            (p take i) filter (n) -> nodes[p[i]] contains n)
    }