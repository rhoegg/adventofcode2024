package main

type Point struct {
	X, Y int
}

type Direction Point

type Cursor struct {
	Location  Point
	Direction Direction
}

var NORTH = Direction{X: 0, Y: -1}
var SOUTH = Direction{X: 0, Y: 1}
var EAST = Direction{X: 1, Y: 0}
var WEST = Direction{X: -1, Y: 0}
var NOWHERE = Direction{X: 0, Y: 0}

type Dimensions struct {
	Width, Height int
}

func (d Direction) Left() Direction {
	if d == NORTH {
		return WEST
	}
	if d == WEST {
		return SOUTH
	}
	if d == SOUTH {
		return EAST
	}
	if d == EAST {
		return NORTH
	}
	return NOWHERE
}

func (d Direction) Right() Direction {
	if d == NORTH {
		return EAST
	}
	if d == EAST {
		return SOUTH
	}
	if d == SOUTH {
		return WEST
	}
	if d == WEST {
		return NORTH
	}
	return NOWHERE
}

func (c Cursor) Ahead() Cursor {
	return Cursor{
		Location:  Point{X: c.Location.X + c.Direction.X, Y: c.Location.Y + c.Direction.Y},
		Direction: c.Direction,
	}
}

func (c Cursor) Left() Cursor {
	return Cursor{
		Location:  c.Location,
		Direction: c.Direction.Left(),
	}
}

func (c Cursor) Right() Cursor {
	return Cursor{
		Location:  c.Location,
		Direction: c.Direction.Right(),
	}
}

func Distance(p1, p2 Point) int {
	dx := p1.X - p2.X
	dy := p1.Y - p2.Y
	d := 0
	if dx > 0 {
		d += dx
	} else {
		d -= dx
	}
	if dy > 0 {
		d += dy
	} else {
		d -= dy
	}
	return d
}

func FinalGap(path []Cursor) int {
	if len(path) < 2 {
		return 0
	}
	last := path[len(path)-1]
	prior := path[len(path)-2]
	return Distance(last.Location, prior.Location)
}
