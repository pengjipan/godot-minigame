# Architecture Guide

## System Overview

### Global Architecture
```
┌─────────────────────────────────────────┐
│         EventBus (Signal Hub)           │
│  44+ events for all system communication │
└─────────────────────────────────────────┘
              ▲          ▲          ▲
              │          │          │
        ┌─────┴──────┬───┴──────┬───┴──────┐
        │            │          │          │
    ┌───▼──┐    ┌────▼─┐   ┌───▼──┐  ┌────▼─┐
    │Player│    │Enemy │   │Weapon│  │Items │
    └──────┘    └──────┘   └──────┘  └──────┘
        │            │          │          │
        └─────┬──────┴───┬──────┴───┬──────┘
              │          │          │
         ┌────▼──┐  ┌────▼─┐  ┌────▼──┐
         │Health │  │Hitbox│  │Hurtbox│
         │Comp   │  │Comp  │  │Comp   │
         └───────┘  └──────┘  └───────┘
```

### Game State Machine
```
┌───────────────────────────────────────────────────┐
│              GAME STATE MACHINE                    │
├───────────────────────────────────────────────────┤
│                                                     │
│  MAIN_MENU                                         │
│    │                                                │
│    ▼                                                │
│  CHARACTER_SELECT (pick character)                 │
│    │                                                │
│    ▼                                                │
│  PLAYING ◄────────────► PAUSED                     │
│    │                                                │
│    ├─► LEVEL_UP (auto on levelup)                 │
│    │      │ (select upgrade)                       │
│    │      └─► PLAYING                              │
│    │                                                │
│    ├─► WAVE_BREAK (end of wave)                   │
│    │      │ (30s countdown)                        │
│    │      └─► SHOP                                 │
│    │            │ (30s countdown)                  │
│    │            └─► PLAYING                        │
│    │                                                │
│    └─► GAME_OVER (on death)                       │
│          │ (show stats)                            │
│          └─► CHARACTER_SELECT (try again)         │
│                                                     │
└───────────────────────────────────────────────────┘
```

## Component Architecture

### Entity Composition
```
┌──────────────────────────────┐
│       CharacterBody2D        │
│     (Physics & Movement)     │
├──────────────────────────────┤
│ Components:                  │
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │ HealthComponent          │ │
│ │ - max_health: int        │ │
│ │ - current_health: int    │ │
│ │ - take_damage()          │ │
│ │ - health_changed signal  │ │
│ └──────────────────────────┘ │
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │ HurtboxComponent (Area2D)│ │
│ │ - collision detection    │ │
│ │ - take_damage()          │ │
│ │ - damaged signal         │ │
│ └──────────────────────────┘ │
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │ HitboxComponent (Area2D) │ │
│ │ - damage: int            │ │
│ │ - on collision: deal dmg │ │
│ │ - hit signal             │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

## System Interaction

### Combat Flow
```
┌─────────────┐
│   Weapon    │ (auto_fire timer)
└──────┬──────┘
       │ fire() called
       ▼
┌──────────────────┐
│   Projectile     │ (Area2D)
│   Spawned        │
└──────┬───────────┘
       │ moves each frame
       ▼
┌──────────────────────┐
│ Collision Check      │
│ (area_entered)       │
└──────┬───────────────┘
       │
       ▼
┌────────────────────────┐
│ HurtboxComponent       │
│ take_damage()          │
└──────┬─────────────────┘
       │
       ▼
┌────────────────────────────┐
│ HealthComponent            │
│ Damage applied             │
│ health_changed emitted     │
└──────┬─────────────────────┘
       │
       ├─► EventBus.player_damaged or
       │   EventBus.enemy_damaged
       │
       ▼ (if health <= 0)
┌────────────────────────────┐
│ health_depleted signal     │
└──────┬─────────────────────┘
       │
       ▼
┌────────────────────────────┐
│ Death Handler              │
│ Drop items, emit event     │
│ queue_free()               │
└────────────────────────────┘
```

### Wave Flow
```
┌──────────────────────────┐
│ WaveManager              │
│ state = FIGHTING         │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ SpawnSystem              │
│ Spawn enemies in circle  │
│ around player            │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ Combat                   │
│ (60s duration)           │
│ Wave progress emitted    │
└──────┬───────────────────┘
       │
       ├─ (time or enemies all dead)
       │
       ▼
┌──────────────────────────┐
│ WaveManager              │
│ state = COUNTDOWN        │
│ 30s until shop opens     │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ ShopPanel (if disabled)  │
│ OR direct to next wave   │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│ WaveManager              │
│ state = PLAYING          │
│ Next wave starts         │
└──────────────────────────┘
```

### Experience & Leveling Flow
```
┌──────────────────┐
│ Enemy Dies       │
└────────┬─────────┘
         │
         ▼
┌────────────────────────────┐
│ ExperienceGem Spawned      │
│ Float to player            │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ Player Collision           │
│ ExperienceGem.collect()    │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ ExperienceSystem           │
│ add_experience(amount)     │
└────────┬───────────────────┘
         │
         ├─ current_exp < threshold
         │  └─► (no level up)
         │
         ├─ current_exp >= threshold
         │
         ▼
┌────────────────────────────┐
│ _level_up()                │
│ Reset experience           │
│ Increase threshold         │
│ Emit player_leveled_up     │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ GameManager.set_state()    │
│ LEVEL_UP (pauses game)     │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ UpgradeSystem              │
│ Generate 3-4 options       │
│ Emit upgrade_panel_opened  │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ Player Selects Upgrade     │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ UpgradeData.apply_upgrade()│
│ Modify player_stats        │
└────────┬───────────────────┘
         │
         ▼
┌────────────────────────────┐
│ GameManager.set_state()    │
│ PLAYING (game resumes)     │
└────────────────────────────┘
```

## Event Flow

### Key Event Sequences

#### On Enemy Death
```
Enemy._on_death()
  ├─ EventBus.enemy_died.emit(self, pos)
  │  ├─ GameManager.add_run_stat("enemies_killed", 1)
  │  ├─ GameHUD._on_enemy_died() → update kill counter
  │  └─ SpawnSystem respects wave limit
  │
  ├─ _drop_rewards()
  │  ├─ ExperienceGem.instantiate()
  │  │  └─ Player collects → add_experience()
  │  │
  │  └─ CoinPickup.instantiate()
  │     └─ Player collects → EventBus.coin_collected.emit()
  │                        → ShopSystem.player_gold += amount
  │
  └─ queue_free()
```

#### On Player Level Up
```
ExperienceSystem.add_experience(amount)
  │
  ├─ (if current_exp >= threshold)
  │
  ▼ _level_up()
  │
  ├─ current_level += 1
  ├─ current_experience = 0
  ├─ experience_threshold = level * 100
  │
  ├─ EventBus.player_leveled_up.emit(level)
  │  ├─ UpgradeSystem._on_player_leveled_up()
  │  │  ├─ Generate upgrade options
  │  │  └─ Emit upgrade_panel_opened
  │  │
  │  └─ GameManager.set_state(LEVEL_UP)
  │     └─ get_tree().paused = true
  │
  └─ EventBus.experience_updated.emit(0, threshold)
     └─ GameHUD._on_experience_updated()
        └─ Update experience bar
```

## Data Flow

### Resource Pipeline
```
Resources (Data Files)
│
├─ CharacterData.tres
│  ├─ character_name
│  ├─ max_health
│  ├─ move_speed
│  └─ starting_weapon
│
├─ WeaponData.tres
│  ├─ damage
│  ├─ fire_rate
│  ├─ projectile_speed
│  └─ pierce_count
│
├─ EnemyData.tres
│  ├─ max_health
│  ├─ move_speed
│  ├─ ai_type
│  └─ experience_reward
│
└─ UpgradeData.tres
   ├─ upgrade_name
   ├─ rarity
   └─ stat_modifiers
      └─ {"stat": {"type": "add|multiply", "value": X}}
```

### Save Data Structure
```
user://save_data.json
{
  "version": 1,
  "high_score": 45,
  "total_runs": 3,
  "characters_unlocked": ["Potato", "Carrot"]
}

user://run_stats.json
{
  "waves_survived": 10,
  "enemies_killed": 523,
  "gold_collected": 1250,
  "damage_taken": 145,
  "damage_dealt": 2450
}
```

## Signal Architecture

### EventBus Signals by Category

#### Combat Signals
```
weapon_fired(weapon, position)
projectile_hit(projectile, target)
enemy_died(enemy, position)
enemy_damaged(enemy, damage)
player_damaged(damage, health_remaining)
```

#### Progression Signals
```
player_leveled_up(new_level)
player_experience_gained(amount)
stat_upgraded(stat_name, new_value)
coin_collected(amount)
```

#### Game State Signals
```
game_started
game_paused
game_resumed
game_over(stats)
wave_started(wave_number)
wave_completed(wave_number)
wave_time_updated(time_remaining)
```

#### UI Signals
```
upgrade_panel_opened
upgrade_panel_closed
shop_opened
shop_closed
health_updated(current, max)
experience_updated(current, max)
kill_count_updated(count)
gold_amount_updated(amount)
```

## Performance Considerations

### Memory Management
```
ObjectPool
├─ Projectiles (pre-allocated)
├─ Experience Gems (pre-allocated)
├─ Coin Pickups (pre-allocated)
└─ Effects (when added)

Reuse Pattern:
- get_instance() from pool
- Use object
- return_instance() to pool
- Object reset and hidden
```

### CPU Optimization
```
Limiting Overhead:
├─ Only process active entities
├─ Area2D for efficient collision
├─ Signal-based event system (no polling)
└─ Component isolation (only needed systems)

Scaling:
├─ 10-20 enemies: No optimization needed
├─ 30-50 enemies: Watch frame time
└─ 50+ enemies: Consider distance culling
```

## Integration Points

### For Art/Animation
```
Current: ColorRect (debug)
Target: Sprite2D + AnimationPlayer
├─ Idle animation
├─ Run animation
├─ Attack animation
└─ Death animation
```

### For Audio
```
AudioManager ready to use:
├─ play_music(audio_path) → loops
├─ stop_music() → with fade
└─ play_sfx(audio_path, volume)

Connect points:
├─ weapon_fired → play shoot SFX
├─ enemy_died → play explosion SFX
├─ player_leveled_up → play level-up SFX
└─ wave_started → play combat music
```

### For Platform-Specific
```
Douyin SDK hooks (when needed):
├─ EventBus.game_over → share score
├─ Player stats → leaderboard push
└─ Achievement unlock → reward video

Android hooks:
├─ Haptic feedback on hit
├─ Game paused on background
└─ Save on app close
```

---

**Architecture Design Principles:**
1. **Loose Coupling** - Systems communicate via signals
2. **High Cohesion** - Related code grouped in components
3. **Single Responsibility** - Each system does one thing
4. **Data-Driven** - Content defined in resources, not code
5. **Mobile-First** - Touch input, efficient rendering
6. **Testable** - Systems can be tested independently
