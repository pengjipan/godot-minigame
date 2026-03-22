extends Node
## Utility functions for screen adaptation and mobile support
class_name ScreenUtils

const REFERENCE_WIDTH: float = 1080.0
const REFERENCE_HEIGHT: float = 1920.0

## Calculate world bounds based on viewport and camera zoom
## margin: extra space outside visible area for spawning/destroying objects
static func calculate_world_bounds(viewport: Viewport, camera_zoom: Vector2 = Vector2.ONE, margin: float = 200.0) -> Rect2:
	var viewport_size = viewport.get_visible_rect().size

	# Calculate visible world size based on camera zoom
	# zoom = 0.5 means camera shows 2x more area
	# zoom = 2.0 means camera shows 0.5x area
	var world_width = viewport_size.x / camera_zoom.x
	var world_height = viewport_size.y / camera_zoom.y

	# Add margin for off-screen spawning and destroy tolerance
	return Rect2(
		-margin,
		-margin,
		world_width + margin * 2,
		world_height + margin * 2
	)

## Get current viewport size from a node
static func get_viewport_size_from_node(node: Node) -> Vector2:
	if node:
		return node.get_viewport().get_visible_rect().size
	return Vector2(REFERENCE_WIDTH, REFERENCE_HEIGHT)  # Fallback

## Get UI scale based on reference resolution
static func get_ui_scale(viewport: Viewport) -> float:
	var viewport_size = viewport.get_visible_rect().size
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
static func get_safe_area_horizontal_margin(viewport: Viewport) -> float:
	var viewport_size = viewport.get_visible_rect().size
	var usable_rect = DisplayServer.screen_get_usable_rect()
	return (viewport_size.x - usable_rect.size.x) / 2.0

## Check if screen is in portrait orientation
static func is_portrait(viewport: Viewport) -> bool:
	var viewport_size = viewport.get_visible_rect().size
	return viewport_size.y > viewport_size.x

## Get world units per pixel (for scaling)
static func get_world_scale(viewport: Viewport) -> float:
	var viewport_size = viewport.get_visible_rect().size
	return REFERENCE_HEIGHT / viewport_size.y

## Convert screen position to world position given a camera
static func screen_to_world(screen_pos: Vector2, camera: Camera2D) -> Vector2:
	return camera.get_global_mouse_position()

## Get center of viewport in world coordinates
static func get_viewport_center(viewport: Viewport, camera_zoom: Vector2 = Vector2.ONE) -> Vector2:
	var viewport_size = viewport.get_visible_rect().size
	return (viewport_size / camera_zoom) / 2.0

## Get random point within visible area
static func get_random_viewport_position(viewport: Viewport, camera_zoom: Vector2 = Vector2.ONE) -> Vector2:
	var viewport_size = viewport.get_visible_rect().size
	var world_size = viewport_size / camera_zoom
	return Vector2(
		randf_range(0, world_size.x),
		randf_range(0, world_size.y)
	)
