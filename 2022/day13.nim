# This is a task better suited for Lisp

import algorithm
import math
import re
import sequtils
import strutils
import sugar

type List = object
  values: seq[string]

proc isNumber(num: string): bool =
  try:
    discard num.parseInt()
    return true
  except ValueError:
    return false

proc init_list(items: string): List =
  if items.isNumber():
    result = List()
    result.values.add(items)
  else:
    assert items.len() >= 2, "items is not a valid list"
    assert items[0] == '[', "items is not a valid list"
    assert items[^1] == ']', "items is not a valid list"
    result = List()

    let parse_items = items[1 .. ^2]
    var start = 0
    var nest_level = 0
    for i, ch in parse_items:
      if ch == '[':
        inc nest_level
      elif ch == ']':
        dec nest_level
      elif ch == ',' and nest_level == 0:
        let add_value = parse_items[start .. i-1].strip()
        result.values.add(add_value)
        start = i+1
    result.values.add(parse_items[start .. ^1].strip())


type Items = iterator(list: List): string

iterator items(list: List): string {.closure.} =
  var i = 0
  while i < list.values.len():
    yield list.values[i]
    inc i


type ListComparison = enum
  Ordered = -1
  Equal = 0
  Disordered = 1

proc order(p1, p2: List): ListComparison =
  var
    iter_1: Items = items
    iter_2: Items = items

  while true:
    let item_1 = iter_1(p1)
    let item_2 = iter_2(p2)
    if finished(iter1) and finished(iter2):
      return Equal

    if finished(iter1):
      return Ordered

    if finished(iter2):
      return Disordered

    # In case one of the lists is empty
    if item_1 == "":
      return Ordered

    if item_2 == "":
      return Disordered

    # Both items are numbers
    if item_1.isNumber() and item_2.isNumber():
      let
        n1 = item_1.parseInt()
        n2 = item_2.parseInt()
      if n1 == n2:
        continue
      elif n1 < n2:
        return Ordered
      else:
        return Disordered

    # Either p1 or p2 is a list. Convert both values to lists and compare them. Note: init_list() will not transform a
    # input list into list of lists, it will leave it untouched.
    let
      pp1 = init_list(item_1)
      pp2 = init_list(item_2)
      order = order(pp1, pp2)
    if order == Equal:
      continue
    else:
      return order

  # In case p1 and p2 are the same
  return Equal

# Tests
assert order(init_list("2"), init_list("2")) == Equal
assert order(init_list("[1, 2]"), init_list("[1, 2]")) == Equal
assert order(init_list("[[1]]"), init_list("[[1]]")) == Equal
assert order(init_list("[[2]]"), init_list("[[2]]")) == Equal
assert order(init_list("[[6]]"), init_list("[[6]]")) == Equal

assert order(init_list("1"), init_list("2")) == Ordered
assert order(init_list("3"), init_list("2")) == Disordered

assert order(init_list("[1]"), init_list("[2]")) == Ordered
assert order(init_list("[3]"), init_list("[2]")) == Disordered

assert order(init_list("[1, 2, 3]"), init_list("[1, 2, 5]")) == Ordered
assert order(init_list("[1, 2, 3]"), init_list("[5]")) == Ordered
assert order(init_list("[1, 2, 3]"), init_list("[1]")) == Disordered

assert order(init_list("[1, [1, 2]]"), init_list("[1, [1, 2, 3]]")) == Ordered
assert order(init_list("[1, [1, 2]]"), init_list("[1, [1]]")) == Disordered

assert order(init_list("[[1],[2,3,4]]"), init_list("[[1],4]")) == Ordered
assert order(init_list("[9]"), init_list("[[8,7,6]]")) == Disordered
assert order(init_list("[[4,4],4,4]"), init_list("[[4,4],4,4,4]")) == Ordered
assert order(init_list("[7,7,7,7]"), init_list("[7,7,7]")) == Disordered
assert order(init_list("[]"), init_list("[3]")) == Ordered
assert order(init_list("[[[]]]"), init_list("[[]]")) == Disordered
assert order(init_list("[1,[2,[3,[4,[5,6,7]]]],8,9]"), init_list("[1,[2,[3,[4,[5,6,0]]]],8,9]")) == Disordered


let file_content = readFile("day13.input.txt")

# Part 1
var sum_ordered = 0
let packet_pairs = file_content.split("\n\n")
for i, pair in packet_pairs:
  let
    packet = pair.split("\n")
    left_packet = init_list(packet[0])
    right_packet = init_list(packet[1])
  if order(left_packet, right_packet) == Ordered:
    sum_ordered += i+1
echo "Part 1: ", sum_ordered

# Part 2
let
  first_divider = init_list("[[2]]")
  second_divider = init_list("[[6]]")
var
  divider_pos = newSeqOfCap[int](2)
  packets = file_content.replace("\n\n", "\n")
                        .replace(re"\n$", "")  # Remove the last '\n' from the input file
                        .split("\n")
                        .map(str => init_list(str))
packets.add(first_divider)
packets.add(second_divider)
packets.sort((a, b) => order(a, b).ord())
for i, packet in packets:
  if order(first_divider, packet) == Equal or order(second_divider, packet) == Equal:
    divider_pos.add(i+1)
echo "Part 2: ", divider_pos.prod()