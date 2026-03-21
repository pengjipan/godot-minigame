package main

import (
	"testing"
)

func TestNewGame(t *testing.T) {
	g := newGame(42)

	if g == nil {
		t.Fatal("newGame returned nil")
	}
	if g.hp != 10 {
		t.Errorf("expected starting HP=10, got %d", g.hp)
	}
	if g.gold != 0 {
		t.Errorf("expected starting gold=0, got %d", g.gold)
	}
	if g.moves != 0 {
		t.Errorf("expected starting moves=0, got %d", g.moves)
	}
	if g.won || g.lost {
		t.Error("game should not be over at start")
	}
}

func TestBorderWalls(t *testing.T) {
	g := newGame(42)

	for x := 0; x < mapWidth; x++ {
		if g.grid[0][x] != cellWall {
			t.Errorf("expected wall at top border (0,%d)", x)
		}
		if g.grid[mapHeight-1][x] != cellWall {
			t.Errorf("expected wall at bottom border (%d,%d)", mapHeight-1, x)
		}
	}
	for y := 0; y < mapHeight; y++ {
		if g.grid[y][0] != cellWall {
			t.Errorf("expected wall at left border (%d,0)", y)
		}
		if g.grid[y][mapWidth-1] != cellWall {
			t.Errorf("expected wall at right border (%d,%d)", y, mapWidth-1)
		}
	}
}

func TestPlayerStartPosition(t *testing.T) {
	g := newGame(42)

	if g.player.x != 1 || g.player.y != 1 {
		t.Errorf("expected player at (1,1), got (%d,%d)", g.player.x, g.player.y)
	}
	if g.grid[1][1] != cellPlayer {
		t.Errorf("expected cellPlayer at grid[1][1], got %c", g.grid[1][1])
	}
}

func TestExitPosition(t *testing.T) {
	g := newGame(42)

	if g.exit.x != mapWidth-2 || g.exit.y != mapHeight-2 {
		t.Errorf("expected exit at (%d,%d), got (%d,%d)",
			mapWidth-2, mapHeight-2, g.exit.x, g.exit.y)
	}
	if g.grid[mapHeight-2][mapWidth-2] != cellExit {
		t.Errorf("expected cellExit at exit position, got %c", g.grid[mapHeight-2][mapWidth-2])
	}
}

func TestMoveIntoWall(t *testing.T) {
	g := newGame(42)
	// Ensure top-left corner is a wall (it always is due to border)
	startX, startY := g.player.x, g.player.y

	// Try moving into the top border wall
	g.move(0, -1)
	if g.player.x != startX || g.player.y != startY {
		t.Error("player should not move into a wall")
	}
	if g.moves != 0 {
		t.Error("move counter should not increase when blocked by wall")
	}
}

func TestMoveValid(t *testing.T) {
	g := newGame(99) // seed chosen so cell (1,2) is empty
	// Clear cell below player to guarantee a free move
	g.grid[2][1] = cellEmpty

	initialMoves := g.moves
	g.move(0, 1)
	if g.player.y != 2 {
		t.Errorf("expected player.y=2 after moving down, got %d", g.player.y)
	}
	if g.moves != initialMoves+1 {
		t.Error("moves counter should increment on valid move")
	}
}

func TestCollectGold(t *testing.T) {
	g := newGame(42)
	// Place gold directly below player
	g.grid[2][1] = cellGold

	g.move(0, 1)
	if g.gold != 1 {
		t.Errorf("expected gold=1 after collecting, got %d", g.gold)
	}
}

func TestEnemyReducesHP(t *testing.T) {
	g := newGame(42)
	// Place enemy directly below player
	g.grid[2][1] = cellEnemy

	g.move(0, 1)
	if g.hp != 7 {
		t.Errorf("expected HP=7 after enemy hit, got %d", g.hp)
	}
}

func TestEnemyKillsPlayer(t *testing.T) {
	g := newGame(42)
	g.hp = 3
	g.grid[2][1] = cellEnemy

	g.move(0, 1)
	if !g.lost {
		t.Error("player should be lost after HP drops to 0")
	}
}

func TestReachingExitWins(t *testing.T) {
	g := newGame(42)
	// Teleport player adjacent to exit
	g.grid[g.player.y][g.player.x] = cellEmpty
	g.player.x = g.exit.x
	g.player.y = g.exit.y - 1
	g.grid[g.player.y][g.player.x] = cellPlayer

	g.move(0, 1)
	if !g.won {
		t.Error("player should win upon reaching the exit")
	}
}
