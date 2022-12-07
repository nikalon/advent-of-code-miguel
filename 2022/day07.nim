import strscans, strutils

type
  NodeType = enum
    File
    Directory

  # Improvement: maybe make File and Directory objects that inherit from Node?
  Node = ref object
    ntype: NodeType
    name: string
    size: int
    parent: Node
    subd: seq[Node]

proc makeDirectory(parent: var Node, name: string): var Node =
  var new_dir: Node
  new(new_dir)
  new_dir.ntype = Directory
  new_dir.name = name
  new_dir.parent = parent

  parent.subd.add(new_dir)
  # return new_dir # Why can't I just return new_dir?
  return parent.subd[parent.subd.len() - 1] # But then I can do this. Doesn't make sense to me.

proc makeFile(directory: var Node, name: string, size: int) =
  var new_file: Node
  new new_file
  new_file.ntype = File
  new_file.name = name
  new_file.size = size
  new_file.parent = directory

  # Update parent's size recursively
  var parent = directory
  while parent != nil:
    parent.size += size
    parent = parent.parent

  directory.subd.add(new_file)

#[
proc printTree(root: Node, deep: int = 0) =
  let tab = "  "

  if root.ntype == Directory:
    echo tab.repeat(deep), "- ", root.name, " (dir, size=", root.size, ")"
  else:
    echo tab.repeat(deep), "- ", root.name, " (file, size=", root.size, ")"

  for node in root.subd:
    printTree(node, deep+1)
]#

# This procedure is used for scanf(). Parses a directory or file name.
proc node_name(input: string; strVal: var string; start: int): int =
  let seps: set[char] = {'a'..'z', 'A'..'Z', '0'..'9', '-', '_', '.', '/'}
  for i in start ..< input.len():
    if input[i] in seps:
      inc result

  if result > 0:
    strVal = input[start ..< start + result]


var root: Node
new(root)
root.ntype = Directory
root.name = "/"
root.parent = nil

var current_dir = root

# Parse input file and make a filesystem tree
let file_path = "day07.input.txt"
for line in file_path.lines():
  var dir_name, file_name: string
  var file_size: int

  if scanf(line, "$$ cd ${node_name}", dir_name):
    if dir_name == "/":
      current_dir = root
    elif dir_name == "..":
      if current_dir.parent != nil:
        current_dir = current_dir.parent
    else:
      # Change directory. Make it if it doesn't exist.
      var dir_found = false
      for node in current_dir.subd:
        if node.ntype == Directory and node.name == dir_name:
          current_dir = node
          dir_found = true
      if not dir_found:
        current_dir = current_dir.makeDirectory(dir_name)

  elif line == "$ ls":
    # Ignore command. The following lines should be a list of files or directories to parse.
    continue

  elif scanf(line, "dir ${node_name}", dir_name):
    # Output of ls command. This is a directory.
    discard current_dir.makeDirectory(dir_name)

  elif scanf(line, "$i ${node_name}", file_size, file_name):
    # Output of ls command. This is a file.
    current_dir.makeFile(file_name, file_size)

proc part1(root: Node): int =
  if root.ntype == Directory:
    if root.size <= 100_000:
      result += root.size
    for node in root.subd:
      result += part1(node)

proc part2(root: Node, min_size: int, lowest_size_found: int = high(int)): int =
  # Improvement: this proc is a bit messy. Maybe make a traverse() proc that returns a sequence of directory sizes that
  # are at least of minimum size, then sort the list and return the lowest value.
  result = lowest_size_found
  if root.ntype == Directory:
    if root.size >= min_size and root.size < lowest_size_found:
      result = root.size

    for node in root.subd:
      result = part2(node, min_size, result)

echo "Part 1: ", part1(root)

let
  fs_size = 70_000_000
  update_size = 30_000_000
  available_space = max(0, fs_size - root.size)
  space_to_delete = max(0, update_size - available_space)
echo "Part 2: ", part2(root, space_to_delete)