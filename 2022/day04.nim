import strscans

let file_path = "day04.input.txt"
var result1, result2 = 0

# I decided to use Sets just for learning something new, but checking ranges manually is also valid.
# In the tests that I performed using Sets is a bit slower than checking ranges manually, but it's still good enough.
for line in file_path.lines():
    var pair1, pair2: tuple[lower: int, top: int]
    if scanf(line, "$i-$i,$i-$i", pair1.lower, pair1.top, pair2.lower, pair2.top):
        # As long as there aren't negative numbers using Sets is fine
        let set1 = { pair1.lower .. pair1.top }
        let set2 = { pair2.lower .. pair2.top }
        # Part 1
        if set1 <= set2 or set2 <= set1:
            inc result1
        # Part 2
        if (set1 * set2).card() > 0:
            inc result2

echo "Part 1: ", result1
echo "Part 2: ", result2