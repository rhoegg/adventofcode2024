package main

import (
	"container/heap"
	"log"
	"os"
	"strings"
)

type ReindeerMaze struct {
	Dimensions
	Walls      map[Point]struct{}
	Start, End Point
}

func Parse(filename string) ReindeerMaze {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	maze := ReindeerMaze{Walls: make(map[Point]struct{})}
	for y, line := range strings.Split(string(inputdata), "\n") {
		maze.Height = y + 1
		for x, c := range line {
			if x >= maze.Width {
				maze.Width = x + 1
			}
			if c == 'S' {
				maze.Start = Point{X: x, Y: y}
			}
			if c == 'E' {
				maze.End = Point{X: x, Y: y}
			}
			if c == '#' {
				maze.Walls[Point{X: x, Y: y}] = struct{}{}
			}
		}
	}
	return maze
}

func (m ReindeerMaze) String() string {
	s := ""
	for y := 0; y < m.Height; y++ {
		line := ""
		for x := 0; x < m.Width; x++ {
			p := Point{X: x, Y: y}
			if m.Start == p {
				line += "S"
			} else if m.End == p {
				line += "E"
			} else if _, ok := m.Walls[p]; ok {
				line += "#"
			} else {
				line += "."
			}
		}
		if y < m.Height-1 {
			line += "\n"
		}
		s += line
	}
	return s
}

func (m ReindeerMaze) PrintPath(path []Cursor) string {
	var rows [][]rune
	for y := 0; y < m.Height; y++ {
		var line []rune
		for x := 0; x < m.Width; x++ {
			p := Point{X: x, Y: y}
			if m.Start == p {
				line = append(line, 'S')
			} else if m.End == p {
				line = append(line, 'E')
			} else if _, ok := m.Walls[p]; ok {
				line = append(line, '#')
			} else {
				line = append(line, '.')
			}
		}
		rows = append(rows, line)
	}
	for _, c := range path {
		rows[c.Location.Y][c.Location.X] = 'O'
	}
	var lines []string
	for _, row := range rows {
		lines = append(lines, string(row))
	}
	return strings.Join(lines, "\n")
}

func (m ReindeerMaze) InBounds(p Point) bool {
	return p.X >= 0 && p.X < m.Width && p.Y >= 0 && p.Y < m.Height
}

func (m ReindeerMaze) FindBestPaths() [][]Cursor {
	var result [][]Cursor
	bestScore := -1
	visited := make(map[Cursor]int)
	pq := make(MazePriorityQueue, 1)
	pq[0] = &MazeNode{
		Cursor: Cursor{
			Location:  m.Start,
			Direction: EAST,
		},
	}
	heap.Init(&pq)
	for len(pq) > 0 {
		node := heap.Pop(&pq).(*MazeNode)
		if priorCursorScore, ok := visited[node.Cursor]; ok {
			if node.Score > priorCursorScore {
				// this is a worse path, discard
				continue
			}
		}
		visited[node.Cursor] = node.Score
		node.Path = append(node.Path, node.Cursor)
		if node.Cursor.Location == m.End {
			if bestScore == -1 || node.Score == bestScore {
				bestScore = node.Score
				log.Printf("Found good path with score %d", node.Score)
				result = append(result, node.Path)
			} else {
				// we're done
				break
			}
		} else {
			nextSteps := []MazeNode{
				{
					Cursor: node.Cursor.Ahead(),
					Score:  node.Score + 1,
					Path:   make([]Cursor, len(node.Path)),
				},
				{
					Cursor: node.Cursor.Left(),
					Score:  node.Score + 1000,
					Path:   make([]Cursor, len(node.Path)),
				},
				{
					Cursor: node.Cursor.Right(),
					Score:  node.Score + 1000,
					Path:   make([]Cursor, len(node.Path)),
				},
			}
			for _, nextStep := range nextSteps {
				copy(nextStep.Path, node.Path)
				gap := FinalGap(nextStep.Path)
				if gap > 1 {
					log.Printf("found gap %d", gap)
				}
				candidate := nextStep
				if _, wall := m.Walls[candidate.Cursor.Location]; !wall {
					heap.Push(&pq, &candidate)
				}
			}
		}
	}
	return result
}
