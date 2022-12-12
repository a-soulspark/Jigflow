class_name Enums
enum Direction { TOP, LEFT, BOTTOM, RIGHT, NONE }

const DIRECTIONS = [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.ZERO]

static func flip(direction : Direction):
	if direction == Direction.NONE: return Direction.NONE
	return (direction + 2) % 4

static func vector(direction : Direction) -> Vector2i:
	return DIRECTIONS[direction]
