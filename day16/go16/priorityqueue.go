package main

type MazeNode struct {
	Cursor Cursor
	Score  int
	Path   []Cursor
}
type MazePriorityQueue []*MazeNode

func (pq MazePriorityQueue) Len() int { return len(pq) }
func (pq MazePriorityQueue) Less(i, j int) bool {
	return pq[i].Score < pq[j].Score
}
func (pq MazePriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
}
func (pq *MazePriorityQueue) Push(x any) {
	node := x.(*MazeNode)
	*pq = append(*pq, node)
}
func (pq *MazePriorityQueue) Pop() any {
	old := *pq
	n := len(old)
	node := old[n-1]
	old[n-1] = nil
	*pq = old[0 : n-1]
	return node
}
