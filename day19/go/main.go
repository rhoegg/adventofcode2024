package main

import (
	"fmt"
	"log"
	"strings"
)

func main() {
	challenge := ParseChallenge("sample.txt")
	fmt.Printf("total combinations found %d", challenge.CountCombinations())
}

func (c Challenge) CountCombinations() int {
	found := 0
	cache := make(map[string]int)
	for _, design := range c.Designs {
		checkDesigns := []string{design}
		log.Printf("***** Checking design %s", design)
		for len(checkDesigns) > 0 {
			thisDesign := checkDesigns[0]
			checkDesigns = checkDesigns[1:]
			log.Printf("** Checking suffix %s", thisDesign)
			for _, pattern := range c.Patterns {
				if thisDesign == pattern {
					log.Printf("matched pattern %s", pattern)
					found += 1

				} else if strings.HasPrefix(thisDesign, pattern) {
					suffix := strings.TrimPrefix(thisDesign, pattern)
					if count, cacheHit := cache[suffix]; cacheHit {
						log.Printf("[%d] cache hit %s-%s", count, pattern, suffix)
						found += count
					} else {
						log.Printf("checking %s", suffix)
						checkDesigns = append([]string{suffix}, checkDesigns...)
					}
				}
			}
		}
	}
	return found
}
