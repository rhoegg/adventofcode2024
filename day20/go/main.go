package main

import (
	"log"
	"maps"
	"slices"
)

func main() {
	filename := "puzzle-input.txt"
	log.Printf("starting %s", filename)
	racetrack := ParseRacetrack(filename)
	path := racetrack.BoringPath()
	log.Printf("path %d", len(path))
	cheats := Cheats(path, 100)
	log.Printf("total qualifying cheats %d\n\n", len(cheats))
	//42722598 is too high

	timeCounts := make(map[int]int)
	for _, cheat := range cheats {
		timeCounts[cheat.Savings] += 1
	}
	times := slices.Collect(maps.Keys(timeCounts))
	slices.Sort(times)
	for _, time := range times {
		log.Printf("%d: %d", time, timeCounts[time])
	}
}

type Cheat struct {
	Start   Point
	End     Point
	Savings int
}

func Cheats(path []Point, minSavings int) []Cheat {
	var cheats []Cheat
	for i, start := range path {
		for j := i + minSavings; j < len(path); j++ {
			end := path[j]
			baseTime := j - i
			cheatTime := ManhattanDistance(start, end)
			savings := baseTime - cheatTime
			if cheatTime <= 20 && savings >= minSavings {
				cheats = append(cheats, Cheat{
					Start:   start,
					End:     end,
					Savings: savings,
				})
			}
		}
	}
	return cheats
}

func ManhattanDistance(p1, p2 Point) int {
	dx := p1.X - p2.X
	if dx < 0 {
		dx *= -1
	}
	dy := p1.Y - p2.Y
	if dy < 0 {
		dy *= -1
	}
	return dx + dy
}
