import algorithm
import math
import sequtils
import strscans
import strutils
import sugar

type MonkeyReference = tuple[mon_pos: int, if_mon_pos: int, else_mon_pos: int]

type Monkey = object
  items: seq[int]
  operation: proc(item: int): int # Used to update item worry level when it is inspected
  test_divisible_num: int
  if_monkey: ref Monkey
  else_monkey: ref Monkey
  num_inspections: int

proc play(monkey: var ref Monkey, worry_level_constant: int = 3) =
  assert(monkey.if_monkey != nil, "This monkey doesn't have a reference to another monkey to throw items at")
  assert(monkey.else_monkey != nil, "This monkey doesn't have a reference to another monkey to throw items at")

  # Inspect items
  for item in monkey.items:
    inc monkey.num_inspections

    # Update worry level for this item
    var worry_level = monkey.operation(item)

    # Ugly and hacky, but I don't want to duplicate this function just for part 2.
    if worry_level_constant == 3:
      worry_level = worry_level div 3
    else:
      worry_level = worry_level mod worry_level_constant

    # Throw item to another monkey
    if worry_level mod monkey.test_divisible_num == 0:
      monkey.if_monkey.items.add(worry_level)
    else:
      monkey.else_monkey.items.add(worry_level)

  # Delete all items. Assuming a monkey can't throw items to itself.
  while monkey.items.len() > 0: discard monkey.items.pop()

# This procedure is used for scanf(). Parses a list of items.
proc items(input: string; out_items: var seq[int]; start: int): int =
  let str_values = input[start .. input.len() - 1]
  out_items = str_values.split(", ").map((s: string) => parseInt(s))
  return str_values.len()

# Dumb operation parser, but it works. I won't bother doing something more sophisticated.
proc parseOperation(input: string): proc(item: int): int =
  var num: int
  if input == "new = old * old":
    return proc(item: int): int = item * item
  elif scanf(input, "new = old * $i", num):
    return proc(item: int): int = item * num
  elif scanf(input, "new = old + $i", num):
    return proc(item: int): int = item + num
  else: discard

# Parse input file
proc init_monkeys(file_content: string): seq[ref Monkey] =
  let file_entries = file_content.split("\n\n")
  var temp_monkey_test_references = newSeqOfCap[MonkeyReference](file_entries.len())
  for i, entry in file_entries.pairs():
    var monkey_references: MonkeyReference = (i, -1, -1)
    var add_monkey: ref Monkey
    new(add_monkey)

    let lines = entry.replace("  ", "").split("\n")
    for line in lines:
      var
        items: seq[int]
        test_divisible_num, if_monkey, else_monkey: int
      if scanf(line, "Starting items: ${items}", items):
        add_monkey.items = items
      elif line.startsWith("Operation: "):
        add_monkey.operation = parseOperation(line.replace("Operation: ", ""))
      elif scanf(line, "Test: divisible by $i", test_divisible_num):
        add_monkey.test_divisible_num = test_divisible_num
      elif scanf(line, "If true: throw to monkey $i", if_monkey):
        monkey_references.if_mon_pos = if_monkey
      elif scanf(line, "If false: throw to monkey $i", else_monkey):
        monkey_references.else_mon_pos = else_monkey
      else: discard

    temp_monkey_test_references.add(monkey_references)
    result.add(add_monkey)

  # Set monkey references between each other. This ensures that the monkey will throw the item to the correct Monkey.
  for mon in temp_monkey_test_references:
    result[mon.mon_pos].if_monkey = result[mon.if_mon_pos]
    result[mon.mon_pos].else_monkey = result[mon.else_mon_pos]

proc playRounds(monkeys: var seq[ref Monkey], rounds: int, is_part_2: bool = false): int =
  if is_part_2:
    let worry_level_mod_constant = monkeys.map((mon) => mon.test_divisible_num).prod()
    for r in 1 .. rounds:
      for mon in monkeys.mitems:
        mon.play(worry_level_mod_constant)
  else:
    for r in 1 .. rounds:
      for mon in monkeys.mitems:
        mon.play()

  var total_inspections = monkeys.map((mon: ref Monkey) => mon.num_inspections)
  total_inspections.sort(Descending)
  result = total_inspections[0 .. 1].prod()


let file_content = readFile("day11.input.txt")

var monkeys = init_monkeys(file_content)
echo "Part 1: ", playRounds(monkeys, 20)

var monkeys_part2 = init_monkeys(file_content)
echo "Part 2: ", playRounds(monkeys_part2, 10_000, is_part_2 = true)