# godot-minigame

A simple terminal dungeon-crawler minigame written in Go.

## Gameplay

Navigate your character (`@`) through a randomly generated dungeon and reach the exit (`E`) before your HP runs out.

| Symbol | Meaning              |
|--------|----------------------|
| `@`    | Player               |
| `#`    | Wall                 |
| `E`    | Exit (reach to win!) |
| `X`    | Enemy (costs 3 HP)   |
| `G`    | Gold (collect it!)   |

## Controls

| Key | Action    |
|-----|-----------|
| `w` | Move up   |
| `s` | Move down |
| `a` | Move left |
| `d` | Move right|
| `q` | Quit      |

## Requirements

- [Go](https://golang.org/) 1.21 or later

## Running

```bash
go run .
```

## Building

```bash
go build -o minigame .
./minigame
```

## Testing

```bash
go test ./...
```