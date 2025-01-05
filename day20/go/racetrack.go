package main

import (
	"os"
	"strings"
)

type Point struct {
	X, Y int
}

func (p Point) Neighbors() []Point {
	return []Point{
		{X: p.X - 1, Y: p.Y},
		{X: p.X + 1, Y: p.Y},
		{X: p.X, Y: p.Y - 1},
		{X: p.X, Y: p.Y + 1},
	}
}

type Racetrack struct {
	Start Point
	End   Point
	Walls map[Point]struct{}
}

func ParseRacetrack(filename string) Racetrack {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	racetrack := Racetrack{Walls: make(map[Point]struct{})}
	for y, line := range strings.Split(string(inputdata), "\n") {
		for x, c := range line {
			switch c {
			case 'S':
				racetrack.Start = Point{X: x, Y: y}
			case 'E':
				racetrack.End = Point{X: x, Y: y}
			case '#':
				racetrack.Walls[Point{X: x, Y: y}] = struct{}{}
			}
		}
	}
	return racetrack
}

func (r Racetrack) BoringPath() []Point {
	path := []Point{r.Start}
	visited := make(map[Point]struct{})
	visited[r.Start] = struct{}{}
	tip := r.Start
	for tip != r.End {
		for _, neighbor := range tip.Neighbors() {
			if _, isWall := r.Walls[neighbor]; isWall {
				continue
			}
			if _, isVisited := visited[neighbor]; isVisited {
				continue
			}
			tip = neighbor
			visited[tip] = struct{}{}
			path = append(path, tip)
		}
	}
	return path
}
