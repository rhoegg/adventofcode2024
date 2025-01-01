package main

import (
	"fmt"
	"log"
)

func main() {
	maze := Parse("puzzle-input.txt")
	fmt.Println(maze)
	bestPaths := maze.FindBestPaths()
	bestSpots := make(map[Point]struct{})
	for _, path := range bestPaths {
		for _, spot := range path {
			bestSpots[spot.Location] = struct{}{}
		}
	}
	log.Printf("We found %d great spots on the best paths through the maze!", len(bestSpots))
	//for _, path := range bestPaths {
	//	log.Println("Found a good path")
	//	fmt.Println(maze.PrintPath(path))
	//}
}
