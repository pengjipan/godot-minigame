package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"
)

const (
	mapWidth  = 10
	mapHeight = 10

	cellEmpty  = '.'
	cellWall   = '#'
	cellPlayer = '@'
	cellExit   = 'E'
	cellEnemy  = 'X'
	cellGold   = 'G'
)

type Position struct {
	x, y int
}

type GameState struct {
	grid   [mapHeight][mapWidth]rune
	player Position
	exit   Position
	hp     int
	gold   int
	moves  int
	won    bool
	lost   bool
}

func newGame(seed int64) *GameState {
	rng := rand.New(rand.NewSource(seed))
	g := &GameState{hp: 10}

	// Fill with empty cells
	for y := 0; y < mapHeight; y++ {
		for x := 0; x < mapWidth; x++ {
			g.grid[y][x] = cellEmpty
		}
	}

	// Add border walls
	for x := 0; x < mapWidth; x++ {
		g.grid[0][x] = cellWall
		g.grid[mapHeight-1][x] = cellWall
	}
	for y := 0; y < mapHeight; y++ {
		g.grid[y][0] = cellWall
		g.grid[y][mapWidth-1] = cellWall
	}

	// Add some interior walls
	wallCount := 10
	for i := 0; i < wallCount; i++ {
		x := rng.Intn(mapWidth-2) + 1
		y := rng.Intn(mapHeight-2) + 1
		g.grid[y][x] = cellWall
	}

	// Place player at top-left interior
	g.player = Position{1, 1}
	g.grid[1][1] = cellPlayer

	// Place exit at bottom-right interior
	g.exit = Position{mapWidth - 2, mapHeight - 2}
	g.grid[mapHeight-2][mapWidth-2] = cellExit

	// Ensure player and exit cells are clear of walls
	g.grid[g.player.y][g.player.x] = cellPlayer
	g.grid[g.exit.y][g.exit.x] = cellExit

	// Place enemies
	for i := 0; i < 5; i++ {
		for {
			x := rng.Intn(mapWidth-2) + 1
			y := rng.Intn(mapHeight-2) + 1
			if g.grid[y][x] == cellEmpty {
				g.grid[y][x] = cellEnemy
				break
			}
		}
	}

	// Place gold
	for i := 0; i < 4; i++ {
		for {
			x := rng.Intn(mapWidth-2) + 1
			y := rng.Intn(mapHeight-2) + 1
			if g.grid[y][x] == cellEmpty {
				g.grid[y][x] = cellGold
				break
			}
		}
	}

	return g
}

func (g *GameState) render() {
	fmt.Println("\033[H\033[2J") // clear screen
	fmt.Println("=== GO DUNGEON MINIGAME ===")
	fmt.Printf("HP: %d  Gold: %d  Moves: %d\n\n", g.hp, g.gold, g.moves)
	for y := 0; y < mapHeight; y++ {
		for x := 0; x < mapWidth; x++ {
			ch := g.grid[y][x]
			switch ch {
			case cellPlayer:
				fmt.Print("\033[93m@\033[0m")
			case cellWall:
				fmt.Print("\033[90m#\033[0m")
			case cellExit:
				fmt.Print("\033[92mE\033[0m")
			case cellEnemy:
				fmt.Print("\033[91mX\033[0m")
			case cellGold:
				fmt.Print("\033[33mG\033[0m")
			default:
				fmt.Print(string(ch))
			}
		}
		fmt.Println()
	}
	fmt.Println()
	fmt.Println("Controls: w=up  s=down  a=left  d=right  q=quit")
	fmt.Println("Reach E to win. Avoid X (costs 3 HP). Collect G for gold.")
}

func (g *GameState) move(dx, dy int) {
	nx := g.player.x + dx
	ny := g.player.y + dy

	if nx < 0 || nx >= mapWidth || ny < 0 || ny >= mapHeight {
		return
	}
	target := g.grid[ny][nx]
	if target == cellWall {
		return
	}

	// Clear old position
	g.grid[g.player.y][g.player.x] = cellEmpty
	g.player.x = nx
	g.player.y = ny
	g.moves++

	switch target {
	case cellEnemy:
		g.hp -= 3
		fmt.Println("\033[91m  Ouch! An enemy hit you for 3 HP.\033[0m")
		if g.hp <= 0 {
			g.lost = true
		}
	case cellGold:
		g.gold++
		fmt.Println("\033[33m  You picked up gold!\033[0m")
	case cellExit:
		g.won = true
	}

	g.grid[g.player.y][g.player.x] = cellPlayer
}

func readLine(reader *bufio.Reader) string {
	line, _ := reader.ReadString('\n')
	return strings.TrimSpace(line)
}

func main() {
	seed := time.Now().UnixNano()
	g := newGame(seed)
	reader := bufio.NewReader(os.Stdin)

	for !g.won && !g.lost {
		g.render()
		fmt.Print("Move: ")
		input := readLine(reader)
		switch input {
		case "w":
			g.move(0, -1)
		case "s":
			g.move(0, 1)
		case "a":
			g.move(-1, 0)
		case "d":
			g.move(1, 0)
		case "q":
			fmt.Println("Goodbye!")
			return
		}
	}

	g.render()
	if g.won {
		fmt.Printf("\033[92mYou escaped! Gold collected: %d  Moves taken: %d\033[0m\n", g.gold, g.moves)
	} else {
		fmt.Println("\033[91mYou were defeated. Better luck next time!\033[0m")
	}
}
