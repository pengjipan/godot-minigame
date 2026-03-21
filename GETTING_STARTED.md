# Getting Started Guide

## Setup

### 1. Open Project in Godot
- Launch Godot 4.5
- Open `D:\Work\VibeGameing\mini-game` folder
- Import and open the project

### 2. Verify Project Configuration
- Go to Project → Project Settings
- Check Rendering → Textures → Canvas Textures → Default Texture Filter
- Verify mobile rendering is enabled under Rendering → Rendering Method

## Testing Individual Systems

### Test Player Movement
```
Open: scenes/tests/test_player_movement.tscn
Press: F5 to run
Expected:
- Red square (player) in center
- Can drag to move player
- Camera follows smoothly
- Can move in all directions
```

### Test Enemy AI
```
Open: scenes/tests/test_enemy_spawn.tscn
Press: F5 to run
Expected:
- Red square (player) in center
- Green square (enemy) on left
- Enemy moves toward player
- Stops if in contact
```

### Test Weapon Firing
```
Open: scenes/tests/test_weapon_firing.tscn
Press: F5 to run
Expected:
- Red player in center
- Yellow projectiles fire continuously to the right
- Projectiles move across screen and disappear
- No errors in output
```

## Running the Full Game

### Main Menu
```
Open: scenes/menus/main_menu.tscn
Press: F5 to run
Expected:
- Title screen with "MINIGAME"
- Three buttons: START GAME, SETTINGS, QUIT
```

### Character Select
```
Click START GAME
Expected:
- Character selection screen appears
- Can select "Potato" character
- Game world loads
```

### Game World
```
Expected when game starts:
- Player visible in center
- Green enemies spawn around player
- HUD shows health, experience, wave, gold
- Virtual joystick in bottom-left
- Player auto-fires at enemies
- Enemies move toward player
```

## Understanding the Code

### Project Structure

**autoload/** - Global systems accessible everywhere
- `event_bus.gd` - Central event/signal hub
- `game_manager.gd` - Game state and run statistics
- `save_manager.gd` - Save/load data
- `audio_manager.gd` - Sound management

**scripts/systems/** - Core game logic
- `spawn_system.gd` - Enemy wave spawning
- `wave_manager.gd` - Wave timing and progression
- `experience_system.gd` - Player leveling
- `upgrade_system.gd` - Upgrade selection
- `shop_system.gd` - Item purchasing

**scripts/components/** - Reusable entity parts
- `health_component.gd` - Health and damage
- `hitbox_component.gd` - Damage dealing
- `hurtbox_component.gd` - Damage receiving

**scripts/ai/** - Enemy behaviors
- `melee_ai.gd` - Charge toward player
- `ranged_ai.gd` - Distance maintenance

**scenes/** - All scene files and scripts

### Key Game Flow

```
1. MainMenu loaded
   ↓
2. Player selects character
   ↓
3. GameWorld scene loaded
   ↓
4. GameManager state → PLAYING
   ↓
5. WaveManager starts first wave
   ↓
6. SpawnSystem spawns enemies
   ↓
7. Player controls character
   ↓
8. Combat happens (projectiles hit enemies)
   ↓
9. Enemies drop experience/gold
   ↓
10. Player levels up → Upgrade panel appears (game pauses)
   ↓
11. Wave ends → Shop opens (game pauses)
   ↓
12. Next wave starts
   ↓
(Repeat 7-12)
   ↓
13. Player dies → Game Over screen
```

### Important Classes

**Player.gd**
- Reads joystick input
- Auto-targets nearest enemy
- Manages inventory (weapons)
- Tracks health

**Enemy.gd**
- Spawned by SpawnSystem
- Uses AI for movement
- Has health and damage
- Drops rewards on death

**Weapon.gd**
- Fires projectiles
- Aims in specified direction
- Configurable fire rate
- Supports multiple projectiles

**Projectile.gd**
- Moves in direction
- Damages on collision
- Can pierce enemies
- Disappears off-screen

### Event System Example

```gdscript
# When enemy dies:
EventBus.enemy_died.emit(self, global_position)

# UI listens:
EventBus.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy, pos):
    kill_count += 1
    update_kill_label()
```

## Customizing Content

### Add New Weapon
1. Create file: `resources/weapons/sword.tres`
2. Set WeaponData properties:
   - damage = 25
   - fire_rate = 3.0
   - projectile_count = 1
3. Add to game

### Add New Enemy
1. Create file: `resources/enemies/goblin.tres`
2. Set EnemyData properties:
   - max_health = 40
   - move_speed = 150
   - ai_type = "melee"
3. Add to spawn pool

### Add New Upgrade
1. Create file: `resources/upgrades/strength_boost.tres`
2. Set UpgradeData:
   - upgrade_name = "Strength Boost"
   - stat_modifiers = {"weapon_damage": {"type": "multiply", "value": 1.2}}
3. Automatically available in upgrades

## Troubleshooting

### Player doesn't move
- Check virtual joystick is visible
- Verify touch input is enabled
- Check player has joystick input connected

### Enemies don't spawn
- Verify wave_manager is in scene
- Check spawn_system has enemy data
- Look for errors in Output panel

### Weapons don't fire
- Check weapon_base.tscn is valid
- Verify projectile.tscn exists
- Check weapon has valid fire_cooldown

### UI doesn't update
- Verify EventBus signals are emitted
- Check UI nodes are connected to events
- Look for signal connection errors in Output

## Performance Tips

### For Development
- Use test scenes for isolated testing
- Monitor FPS in editor (Debug → Monitor)
- Check memory usage (Debug → Profiler)

### For Testing
- Run on actual device if possible
- Test with many enemies (press F1 for stats)
- Monitor framerate with multiple upgrades applied

## Next Steps

1. **Replace Placeholder Art**
   - Download from Kenney.nl or OpenGameArt.org
   - Replace ColorRect sprites with Sprite2D nodes
   - Add animations

2. **Add Sound Effects**
   - Create audio files
   - Use AudioManager to play sounds
   - Add in combat scenarios

3. **Implement More Content**
   - Create more weapon types
   - Add more enemy varieties
   - Design upgrade progression

4. **Platform Export**
   - Configure Android export
   - Set up HTML5 export
   - Test on target devices

5. **Douyin Integration** (if needed)
   - Implement Douyin SDK calls
   - Add sharing functionality
   - Setup leaderboard

## Resources

- **Godot Docs**: https://docs.godotengine.org/
- **Free Assets**: https://kenney.nl/
- **Community Assets**: https://opengameart.org/
- **Game Dev**: https://itch.io/

## Getting Help

- Check error messages in Output panel
- Run test scenes individually
- Verify scene connections in Scene tree
- Review script comments for implementation details

---

**Ready to start developing!**
