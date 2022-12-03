import strutils

let file_content = readFile("day03.input.txt").splitLines()

func value(c: char): int =
    # Normalize lowercase ASCII character values to range [1, 26] and uppercase character values to range [27, 52]
    if c.isLowerAscii(): result = ord(c) - 96
    else: result = ord(c) - 38

proc part1(file_content: seq[string]): int =
    for line in file_content:
        # Assuming each line has an even number of characters
        let sep = line.len div 2
        let compartments = [line[0 ..< sep], line[sep .. ^1]]
        for c in compartments[0]:
            # Assuming there's only one repeated element in each compartment
            if c in compartments[1]:
                result += c.value()
                break

proc part2(file_content: seq[string]): int =
    for i in countup(0, file_content.len() - 1, 3):
        let current_line = file_content[i]
        for c in current_line:
            # Assuming there's only one repeated element in each line
            if c in file_content[i+1] and c in file_content[i+2]:
                result += c.value()
                break


echo "Part 1: ", part1(file_content)
echo "Part 2: ", part2(file_content)