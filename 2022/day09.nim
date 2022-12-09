import strscans, sets

type
  Point2D = tuple[x: int, y: int]
  Vector2D = Point2D

const
  Left: Vector2D = (-1, 0)
  Right: Vector2D = (1, 0)
  Up: Vector2D = (0, 1)
  Down: Vector2D = (0, -1)

proc unit(vector: Vector2D): Vector2D =
  # Transform input vector into a unit vector
  result.x = clamp(vector.x, -1, 1)
  result.y = clamp(vector.y, -1, 1)

# Used for point movement
proc `+=`(point: var Point2D, direction: Vector2D) =
  point.x += direction.x
  point.y += direction.y


var
  # Head is knots[0], tail of part 1 is knots[1] and tail of part 2 is knots[9]
  knots: array[10, Point2D]
  visited_tail_points_part1: HashSet[Point2D] # All visited points of tail in part 1 (knots[1])
  visited_tail_points_part2: HashSet[Point2D] # All visited points of tail in part 2 (knots[9])

proc isAdjacent(a: Point2D, b: Point2D): bool =
  return abs(a.x - b.x) <= 1 and abs(a.y - b.y) <= 1

proc moveKnotAroundParentKnot(knot: var Point2D, parent: var Point2D) =
  let adjacent = knot.isAdjacent(parent)
  if not adjacent:
    let direction: Vector2D = (parent.x - knot.x, parent.y - knot.y).unit()
    knot += direction

proc simulateStepWithRepetitions(head_movement: Vector2D, count: int) =
  for i in 1 .. count:
    knots[0] += head_movement
    # for tail_knot in knots[1 ..< 9].mitems:
    for i in 1 .. 9:
      knots[i].moveKnotAroundParentKnot(knots[i-1])
      if i == 1:
        # Tail knot of part 1. Remember where this knot was.
        visited_tail_points_part1.incl(knots[i])
      elif i == 9:
        # Tail knot of part 2. Remember where this knot was.
        visited_tail_points_part2.incl(knots[i])


# Parse file
let file_path = "day09.input.txt"
for line in file_path.lines():
  var
    repetitions: int
    head_direction: Vector2D

  if scanf(line, "R $i", repetitions):
    head_direction = Right
  elif scanf(line, "L $i", repetitions):
    head_direction = Left
  elif scanf(line, "U $i", repetitions):
    head_direction = Up
  elif scanf(line, "D $i", repetitions):
    head_direction = Down

  simulateStepWithRepetitions(head_direction, repetitions)

echo "Part 1: ", visited_tail_points_part1.len()
echo "Part 2: ", visited_tail_points_part2.len()