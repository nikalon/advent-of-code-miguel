# Very inefficient, very ugly, very quadratic algorithm to Day 08

let file_path = "day08.input.txt"
var grid: seq[seq[int]]

# Parse tree heights
for line in file_path.lines():
  var row = newSeqOfCap[int](line.len)
  for num in line:
    let val = ord(num) - 48
    row.add(val)
  grid.add(row)

proc isVisibleFromTheTopOutside(grid: seq[seq[int]]; row_target, col_target: int): bool =
  let tree_height = grid[row_target][col_target]
  for row in countdown(row_target-1, 0):
    let neighbour_height = grid[row][col_target]
    if neighbour_height >= tree_height:
      return false
  return true

proc isVisibleFromTheBottomOutside(grid: seq[seq[int]]; row_target, col_target: int): bool =
  let
    grid_height = grid.len
    tree_height = grid[row_target][col_target]
  for row in countup(row_target+1, grid_height-1):
    let neighbour_height = grid[row][col_target]
    if neighbour_height >= tree_height:
      return false
  return true

proc isVisibleFromTheLeftOutside(grid: seq[seq[int]]; row_target, col_target: int): bool =
  let tree_height = grid[row_target][col_target]
  for col in countdown(col_target-1, 0):
    let neighbour_height = grid[row_target][col]
    if neighbour_height >= tree_height:
      return false
  return true

proc isVisibleFromTheRightOutside(grid: seq[seq[int]]; row_target, col_target: int): bool =
  let
    grid_width = grid[row_target].len
    tree_height = grid[row_target][col_target]
  for col in countup(col_target+1, grid_width-1):
    let neighbour_height = grid[row_target][col]
    if neighbour_height >= tree_height:
      return false
  return true

proc part1(grid: seq[seq[int]]): int =
  for row in 0 ..< grid.len:
    for col in 0 ..< grid[row].len:
      if isVisibleFromTheTopOutside(grid, row, col) or isVisibleFromTheBottomOutside(grid, row, col) or
         isVisibleFromTheLeftOutside(grid, row, col) or isVisibleFromTheRightOutside(grid, row, col):
        inc result


proc numTreesVisibleTop(grid: seq[seq[int]]; row_target, col_target: int): int =
  let tree_height = grid[row_target][col_target]
  for row in countdown(row_target-1, 0):
    inc result
    let neighbour_height = grid[row][col_target]
    if neighbour_height >= tree_height:
      return result

proc numTreesVisibleBottom(grid: seq[seq[int]]; row_target, col_target: int): int =
  let
    grid_height = grid.len
    tree_height = grid[row_target][col_target]
  for row in countup(row_target+1, grid_height-1):
    inc result
    let neighbour_height = grid[row][col_target]
    if neighbour_height >= tree_height:
      return result

proc numTreesVisibleLeft(grid: seq[seq[int]]; row_target, col_target: int): int =
  let tree_height = grid[row_target][col_target]
  for col in countdown(col_target-1, 0):
    inc result
    let neighbour_height = grid[row_target][col]
    if neighbour_height >= tree_height:
      return result

proc numTreesVisibleRight(grid: seq[seq[int]]; row_target, col_target: int): int =
  let
    grid_width = grid[row_target].len
    tree_height = grid[row_target][col_target]
  for col in countup(col_target+1, grid_width-1):
    inc result
    let neighbour_height = grid[row_target][col]
    if neighbour_height >= tree_height:
      return result

proc part2(grid: seq[seq[int]]): int =
  result = 0 # Max scenic score
  for row in 0 ..< grid.len:
    for col in 0 ..< grid[row].len:
      let scenic_score = numTreesVisibleTop(grid, row, col) * numTreesVisibleBottom(grid, row, col) *
                         numTreesVisibleLeft(grid, row, col) * numTreesVisibleRight(grid, row, col)
      result = max(result, scenic_score)

echo "Part 1: ", part1(grid)
echo "Part 2: ", part2(grid)