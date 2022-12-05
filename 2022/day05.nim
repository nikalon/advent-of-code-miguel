import strutils, strscans

type Stack = seq[char]

let
    file_content = readFile("day05.input.txt").split("\n\n")
    load_section = file_content[0].splitLines()
    move_section = file_content[1]

proc parseStackList(load_section: seq[string]): seq[Stack] =
    # Could be cleaner. Maybe reverse load_section variable to read numbers first?
    let how_many_stacks = (1 + load_section[0].len) div 4
    for s in 1 .. how_many_stacks:
        result.add(newSeq[char]())

    for line in load_section:
        for i, ch in line.pairs():
            if ch.isAlphaAscii():
                result[i div 4].insert(ch, 0)

proc getTopCharsFromStackList(stack_list: seq[Stack]): string =
    for item in stack_list:
        result = result & item[^1]

var
    first_stack_list = parseStackList(load_section)
    second_stack_list = parseStackList(load_section)

# Move items
for line in move_section.splitLines():
    var item_quantity, origin, dest: int
    if scanf(line, "move $i from $i to $i", item_quantity, origin, dest):
        # Normalize index
        dec origin
        dec dest

        # Part 1. Move items one by one individually
        for i in 1 .. item_quantity:
            first_stack_list[dest].add(first_stack_list[origin].pop())

        # Part 2. Move items in groups and preserve their order
        second_stack_list[dest] = second_stack_list[dest] & second_stack_list[origin][^item_quantity .. ^1]
        for i in 1 .. item_quantity:
            discard second_stack_list[origin].pop()

echo "Part 1: ", getTopCharsFromStackList(first_stack_list)
echo "Part 2: ", getTopCharsFromStackList(second_stack_list)