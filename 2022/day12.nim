# This exercice is modeled using a directed, unweighted graph. We can find the shortest path using the breadth-first
# search between two vertices and counting the number of steps taken.

import re
import strutils

type Graph = object
  # This graph could've been implemented using adjacency lists and they should be more efficient when traversing the
  # graph. But I wanted to try using an adjacency matrix because I've never implemented one before.
  n_vertices: int
  adjacency_matrix: seq[bool] # This is treated as a two-dimensional matrix in spite of being one-dimensional

proc new_graph(n_vertices: int): Graph =
  result = Graph()
  result.n_vertices = n_vertices
  result.adjacency_matrix = newSeq[bool](n_vertices * n_vertices)

proc insert_edge(graph: var Graph, v1, v2: int) =
  assert(v1 >= 0 and v1 < graph.n_vertices, "v1 must be a valid vertex")
  assert(v2 >= 0 and v2 < graph.n_vertices, "v2 must be a valid vertex")
  let pos = v1 * graph.n_vertices + v2
  graph.adjacency_matrix[pos] = true

type VertexState = enum
  UNDISCOVERED = 0
  DISCOVERED
  PROCESSED

proc bfs(graph: Graph, start_vertex: int): seq[int] =
  # Breadth-first search. Returns a list of traversed vertices and its corresponding parent vertices.

  # Init discovery relation
  result = newSeq[int](graph.n_vertices)
  for i in 0 ..< result.len(): result[i] = -1 # -1 means a vertex has no parents

  # Keep state of all vertices during traversal
  var v_state = newSeq[VertexState](graph.n_vertices)

  # Start vertex traversal
  var vertex_queue: seq[int]
  vertex_queue.insert(start_vertex, 0)

  while vertex_queue.len() > 0:
    let successor_vertex = vertex_queue.pop()
    v_state[successor_vertex] = PROCESSED

    # Search all child vertices for current successor vertex
    for j in 0 ..< graph.n_vertices:
      let vertex_is_connected = graph.adjacency_matrix[successor_vertex * graph.n_vertices + j]
      if vertex_is_connected and v_state[j] == UNDISCOVERED:
          # Add this child vertex to the queue and process it later
          vertex_queue.insert(j, 0)
          v_state[j] = DISCOVERED
          result[j] = successor_vertex

proc find_shortest_path(graph: Graph, v_start, v_end: int): int =
  let parents = graph.bfs(v_start)
  var vertex = parents[v_end]

  if v_start != v_end and vertex == -1:
    # v_start is not connected to v_end
    return -1

  while vertex != -1:
    vertex = parents[vertex]
    inc result


# Parse input file into a graph
let
  file_content = readFile("day12.input.txt").replace(re"\n$", "").splitLines()
  rows = file_content.len()
  cols = file_content[0].len()
  n_squares = rows * cols

proc get_char_helper(file_lines: seq[string], row, col: int): (int, int, char) =
  # Returns the ASCII value of the character at the specified position, its position (between 0 and n_squares - 1) into
  # the graph and its real character value
  let
    cols = file_content[0].len()
    char_pos = row * cols + col
    ch = file_lines[row][col]
  case ch
  of 'S':
    # Starting point
    result = (ord('a'), char_pos, ch)
  of 'E':
    # End point
    result = (ord('z'), char_pos, ch)
  else:
    result = (ord(ch), char_pos, ch)

var
  graph = new_graph(n_squares)
  start_pos, end_pos: int

# Squares are numerated from 0 to n_squares - 1
for i in 0 ..< rows:
  for j in 0 ..< cols:
    let (current_square, current_square_pos, ch) = get_char_helper(file_content, i, j)
    if ch == 'S':
      # Starting point
      start_pos = current_square_pos
    elif ch == 'E':
      # End point
      end_pos = current_square_pos

    # Check if it can connect to upper square
    if i > 0:
      let (upper_square, upper_square_pos, _) = get_char_helper(file_content, i-1, j)
      if upper_square - 1 == current_square or upper_square <= current_square:
        graph.insert_edge(current_square_pos, upper_square_pos)

    # Check if it can connect to lower square
    if i < rows-1:
      let (lower_square, lower_square_pos, _) = get_char_helper(file_content, i+1, j)
      if lower_square - 1 == current_square or lower_square <= current_square:
        graph.insert_edge(current_square_pos, lower_square_pos)

    # Check if it can connect to right square
    if j < cols-1:
      let (right_square, right_square_pos, _) = get_char_helper(file_content, i, j+1)
      if right_square - 1 == current_square or right_square <= current_square:
        graph.insert_edge(current_square_pos, right_square_pos)

    # Check if it can connect to left square
    if j > 0:
      let (left_square, left_square_pos, _) = get_char_helper(file_content, i, j-1)
      if left_square - 1 == current_square or left_square <= current_square:
        graph.insert_edge(current_square_pos, left_square_pos)

echo "Part 1: ", graph.find_shortest_path(start_pos, end_pos)


# Part 2. For every 'a' and 'S' in the map it will find the shortest path from 'a' to 'E'
var shortest_path: int
for i in 0 ..< rows:
  for j in 0 ..< cols:
    let (_, current_square_pos, ch) = get_char_helper(file_content, i, j)
    if ch == 'S' or ch == 'a':
      let steps = graph.find_shortest_path(current_square_pos, end_pos)
      if steps != -1:
        if shortest_path == 0:
          shortest_path = steps
        else:
          shortest_path = min(shortest_path, steps)

echo "Part 2: ", shortest_path