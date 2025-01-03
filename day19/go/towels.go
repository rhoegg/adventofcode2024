package main

import (
	"os"
	"strings"
)

type Challenge struct {
	Patterns []string
	Designs  []string
}

func ParseChallenge(filename string) Challenge {
	inputdata, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	parts := strings.Split(string(inputdata), "\n\n")
	return Challenge{
		Patterns: strings.Split(parts[0], ", "),
		Designs:  strings.Split(parts[1], "\n"),
	}
}

func (c Challenge) String() string {
	return "patterns: " + strings.Join(c.Patterns, ", ") + "\n" + "designs:\n" + strings.Join(c.Designs, "\n")
}
