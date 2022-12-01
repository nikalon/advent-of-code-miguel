import strutils
import std/algorithm
import math

let file = readFile("day01.input.txt")
var
    currentCalories: int
    calories: seq[int]

for line in file.splitLines():
    if line == "":
        # Current Elf has no more items
        calories.add(currentCalories);
        currentCalories = 0
    else:
        currentCalories += parseInt(line)

calories.sort(Descending)
echo "Part 1. The maximum number of calories that a single Elf is carrying is ", calories[0], " calories"
echo "Part 2. The sum of the top three with the most calories is: ", calories[0..2].sum()