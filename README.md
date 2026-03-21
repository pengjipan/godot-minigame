# MiniGame - Roguelike Survival Shooter

A Godot 4.5 roguelike survival shooter game inspired by Brotato, designed for mobile platforms (Android, iOS) and web (HTML5 for Douyin mini-games).

## Project Status

**Current Phase:** 8/10 - Core Systems Complete ✅

All core game systems, scripts, and scene files have been implemented. The project is ready for testing and validation.

## What's Implemented

### Autoload Systems (Phase 1)
- **EventBus** - 44+ game events via signals
- **GameManager** - Game state machine and run statistics
- **SaveManager** - JSON-based save system
- **AudioManager** - Audio playback and volume control

### Core Gameplay Systems (Phase 2-8)
- **Player System** - Virtual joystick input, auto-targeting, weapon firing
- **Enemy System** - Wave-based spawning, AI behaviors
- **Combat System** - Projectiles with pierce, collision detection
- **Progression System** - Experience, leveling, upgrades, shop
- **UI System** - HUD, panels, menus
- **Shop/Economy** - Gold collection, item purchasing
- **Item System** - Experience gems and coins with auto-attraction

### Reusable Components
- HealthComponent - Damage and healing system
- HitboxComponent - Damage dealing on collision
- HurtboxComponent - Damage receiving with knockback

### Test Scenes
- test_player_movement.tscn
- test_enemy_spawn.tscn
- test_weapon_firing.tscn

## Quick Start

1. Open project in Godot 4.5
2. Run a test scene (F5) or main menu (F6)
3. Touch simulation available in Godot Remote

## Architecture

**Event-Driven**: All systems communicate via EventBus signals
**Component-Based**: Reusable entity components
**Data-Driven**: Game content via Resource files
**State Machine**: Clear game flow control

## File Structure

```
autoload/          - Global singletons (4 files)
scripts/           - Game systems and components (20+ files)
scenes/            - All scene files (16 files)
resources/         - Game data definitions (4 types)
assets/            - Art and audio placeholders
```

## Performance

- Optimized for 50+ enemies at 30+ FPS
- Object pooling ready
- Mobile touch input optimized
- Responsive UI layout

## Next Steps

1. **Test Systems** - Run test scenes to validate
2. **Add Art** - Replace ColorRect with sprites
3. **Add Audio** - Sound effects and music
4. **Export** - Android and HTML5 builds