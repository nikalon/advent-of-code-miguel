import strutils

type Point2D = tuple[x, y: int]

iterator to(a, b: Point2D): Point2D =
  if a.x != b.x and a.y != b.y:
    assert false, "Only vertical or horizontal lines are allowed"

  var pos = a
  if a.x != b.x:
    # Move by x coordinate
    while pos.x != b.x:
      yield pos
      pos.x += clamp(b.x - a.x, -1, 1)
  else:
    # Move by y coordinate
    while pos.y != b.y:
      yield pos
      pos.y += clamp(b.y - a.y, -1, 1)

  yield pos


type Material = enum
  Air = 0
  Rock
  Sand

const CAVE_SIDE_LENGTH = 1000
type Cave = object
  cave: array[CAVE_SIDE_LENGTH * CAVE_SIDE_LENGTH, Material] # This is treated as a two-dimensional array
  deepest_height: int
  num_grains_of_sand_deposited: int
  is_falling: bool
  grain_of_sand_pos: Point2D

proc set_material_at_position(cave: var Cave; position: Point2D; material: Material) =
  assert position.x >= 0 and position.x < CAVE_SIDE_LENGTH, "Invalid x coordinate"
  assert position.y >= 0 and position.y < CAVE_SIDE_LENGTH, "Invalid y coordinate"
  let pos = position.x + (position.y * CAVE_SIDE_LENGTH)

  if material == Sand:
    assert cave.cave[pos] == Air, "Sand can only overwrite air or another sand source!"

  cave.cave[pos] = material

  # Store deepest y level for optimizations later on
  if material == Rock and position.y > cave.deepest_height:
    cave.deepest_height = position.y

proc get_material_at_position(cave: Cave; position: Point2D): Material =
  assert position.x >= 0 and position.x < CAVE_SIDE_LENGTH, "Invalid x coordinate"
  assert position.y >= 0 and position.y < CAVE_SIDE_LENGTH, "Invalid y coordinate"
  let pos = position.x + (position.y * CAVE_SIDE_LENGTH)
  result = cave.cave[pos]

proc init_cave(): Cave =
  result = Cave()
  result.is_falling = false

type CaveSimulationStatus = enum
  RUNNING
  SAND_FELL_INTO_VOID
  SAND_BLOCKED_SOURCE

proc simulateOneStep(cave: var Cave): CaveSimulationStatus =
  if cave.is_falling:
    # Move grain of sand
    if cave.grain_of_sand_pos.y > cave.deepest_height:
      return SAND_FELL_INTO_VOID

    # Check if it can move downwards
    let down = (cave.grain_of_sand_pos.x, cave.grain_of_sand_pos.y + 1)
    if cave.get_material_at_position(down) == Air:
      cave.set_material_at_position(cave.grain_of_sand_pos, Air)
      cave.set_material_at_position(down, Sand)
      cave.grain_of_sand_pos = down
      cave.is_falling = true
      return RUNNING

    # Check if it can move downwards and left
    let down_left = (cave.grain_of_sand_pos.x - 1, cave.grain_of_sand_pos.y + 1)
    if cave.get_material_at_position(down_left) == Air:
      cave.set_material_at_position(cave.grain_of_sand_pos, Air)
      cave.set_material_at_position(down_left, Sand)
      cave.grain_of_sand_pos = down_left
      cave.is_falling = true
      return RUNNING

    # Check if it can move downwards and right
    let down_right = (cave.grain_of_sand_pos.x + 1, cave.grain_of_sand_pos.y + 1)
    if cave.get_material_at_position(down_right) == Air:
      cave.set_material_at_position(cave.grain_of_sand_pos, Air)
      cave.set_material_at_position(down_right, Sand)
      cave.grain_of_sand_pos = down_right
      cave.is_falling = true
      return RUNNING

    # The grain of sand can't move anywhere
    if cave.grain_of_sand_pos == (500, 0):
      inc cave.num_grains_of_sand_deposited
      return SAND_BLOCKED_SOURCE
    else:
      cave.is_falling = false
      inc cave.num_grains_of_sand_deposited

  else:
    # Generate a new grain of sand
    cave.is_falling = true
    cave.grain_of_sand_pos = (500, 0)
    cave.set_material_at_position(cave.grain_of_sand_pos, Sand)


var
  cave = init_cave()
  cave2: Cave

# Draw rocks
let file_content = readFile("day14.input.txt").splitLines()
for line in file_content:
  let coordinates = line.split(" -> ")
  var last_pos: Point2D = (-1, -1)
  for coord in coordinates:
    let c = coord.split(",")
    if c.len() != 2:
      continue

    let pos: Point2D = (c[0].parseInt(), c[1].parseInt())
    if last_pos[0] == -1:
      last_pos = pos

    # Draw a straight line or a point
    for pos in last_pos.to(pos):
      cave.set_material_at_position(pos, Rock)
    last_pos = pos

# Clone cave for part 2
cave2 = cave

# Simulate falling sand and stop whenever one grain of sand falls below the deepest y level
while true:
  let status = cave.simulateOneStep()
  if status == SAND_FELL_INTO_VOID:
    break
  elif status == SAND_BLOCKED_SOURCE:
    assert false, "Sand blocked its source. This should not happen in part 1"

echo "Part 1: ", cave.num_grains_of_sand_deposited


# Add a bedrock layer below deepest level + 2
cave2.deepest_height += 2
for i in 0 ..< CAVE_SIDE_LENGTH:
  let pos = (i, cave2.deepest_height)
  cave2.set_material_at_position(pos, Rock)

# Simulate falling sand and stop whenever one grain of sand blocks its source
while true:
  let status = cave2.simulateOneStep()
  if status == SAND_FELL_INTO_VOID:
    assert false, "Sand must not fall into void. This is not possible in part 2."
  elif status == SAND_BLOCKED_SOURCE:
    break

echo "Part 2: ", cave2.num_grains_of_sand_deposited