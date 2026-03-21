# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Godot 4.5** game project named "MiniGame" configured for mobile rendering. The project is currently in its initial state with minimal structure.

## Project Configuration

- **Engine Version**: Godot 4.5
- **Rendering Method**: Mobile (optimized for mobile devices)
- **Features**: Mobile feature set
- **Project Root**: All resources use `res://` paths relative to the project root

## Development Workflow

### Running the Project

Godot projects are typically opened and run through the Godot Editor GUI:
1. Open the Godot Editor
2. Import or open this project directory
3. Press F5 to run the main scene, or F6 to run the current scene

### File Structure

Godot projects use specific file types:
- **`.tscn`**: Scene files (text-based scene trees)
- **`.gd`**: GDScript files (Godot's scripting language)
- **`.tres`**: Resource files (text-based resources)
- **`.import`**: Import configuration files (auto-generated, do not edit manually)
- **`.godot/`**: Editor cache and metadata (ignored in version control)

### GDScript Conventions

When writing GDScript code:
- Use `snake_case` for variables, functions, and file names
- Use `PascalCase` for class names
- Signals are declared at the top of the script
- Node references use `@onready var` for nodes acquired from the scene tree
- Entry point is `_ready()` for initialization and `_process(delta)` for per-frame updates
- Use `extends` to inherit from Godot node types

### Scene Organization

Godot uses a scene-based architecture where:
- Each `.tscn` file represents a scene (a tree of nodes)
- Scenes can be instanced within other scenes
- The root scene is typically set in `project.godot` under `[application]` as `run/main_scene`

### Common Node Paths

- Use `$NodeName` shorthand to access direct children
- Use `%UniqueNodeName` for nodes marked as unique in the scene tree
- Use `get_node("path/to/node")` for complex paths

## Testing and Debugging

- Use `print()`, `print_debug()`, or `push_warning()` for console output
- The Godot Editor shows output in the "Output" panel when running scenes
- Use the built-in debugger (Debug menu) for breakpoints and variable inspection

## Export and Build

To export the game for mobile platforms:
1. Use Project > Export from the Godot Editor
2. Configure export templates for target platforms (Android/iOS)
3. Export presets are stored in `export_presets.cfg` (not yet created)
