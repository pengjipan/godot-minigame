extends Node
## Utility functions for screen adaptation and mobile support
class_name ScreenUtils

const REFERENCE_WIDTH: float = 1080.0
const REFERENCE_HEIGHT: float = 1920.0

## Get current viewport size
static func get_viewport_size() -> Vector2:
	return get_viewport().get_visible_rect().size

## Get UI scale based on reference resolution
static func get_ui_scale() -> float:
	var viewport_size = get_viewport_size()
	var width_scale = viewport_size.x / REFERENCE_WIDTH
	return minf(width_scale, 1.5)  # Cap at 1.5x for large screens

## Get safe area top (for notch/cutout)
static func get_safe_area_top() -> float:
	return DisplayServer.screen_get_usable_rect().position.y

## Get safe area bottom
static func get_safe_area_bottom() -> float:
	var usable_rect = DisplayServer.screen_get_usable_rect()
	return usable_rect.position.y + usable_rect.size.y

## Get safe area horizontal margins
static func get_safe_area_horizontal_margin() -> float:
	var viewport_size = get_viewport_size()
	var usable_rect = DisplayServer.screen_get_usable_rect()
	return (viewport_size.x - usable_rect.size.x) / 2.0

## Check if screen is in portrait orientation
static func is_portrait() -> bool:
	var viewport_size = get_viewport_size()
	return viewport_size.y > viewport_size.x

## Get world units per pixel (for scaling)
static func get_world_scale() -> float:
	var viewport_size = get_viewport_size()
	return REFERENCE_HEIGHT / viewport_size.y

## Convert screen position to world position given a camera
static func screen_to_world(screen_pos: Vector2, camera: Camera2D) -> Vector2:
	return camera.get_global_mouse_position()

## Clamp position to screen bounds with margin
static func clamp_to_screen(position: Vector2, margin: float = 0.0) -> Vector2:
	var viewport_size = get_viewport_size()
	return position.clamp(Vector2(margin, margin),
		viewport_size - Vector2(margin, margin))

## Get center of screen
static func get_screen_center() -> Vector2:
	return get_viewport_size() / 2.0

## Get random point on screen
static func get_random_screen_position() -> Vector2:
	var viewport_size = get_viewport_size()
	return Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)
