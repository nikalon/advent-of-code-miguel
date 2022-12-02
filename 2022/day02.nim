import strutils

type
    Item = enum
        Rock = 0, Paper = 1, Scissors = 2 # The ordinal values are indices for MatchResults matrix
    Round = enum
        Defeat = 0, Draw = 3, Win = 6 # The ordinal values are the outcome of the round

proc value(item: Item): int =
    case item:
    of Rock: return 1
    of Paper: return 2
    of Scissors: return 3

#                            (My items)
#                     ------------------------
#                     Rock    Paper   Scissors
const MatchResults = [[Draw,   Win,    Defeat ], # Rock      ]
                      [Defeat, Draw,   Win    ], # Paper     ] (Opponent items)
                      [Win,    Defeat, Draw   ]] # Scissors  ]

proc play(myItem: Item, opponentItem: Item): Round =
    return MatchResults[ord(opponentItem)][ord(myItem)]

proc parseItem(item: string): Item =
    # Part 1 of the exercice
    case item:
    of "A", "X":
        return Item.Rock
    of "B", "Y":
        return Item.Paper
    of "C", "Z":
        return Item.Scissors
    else: discard

proc parseItemAsAction(item: string, opponentItem: Item): Item =
    # Part 2 of the exercice. Parses the item according to the action that I need
    # to do in relation to the opponent item.
    case item:
    of "X":
        # I need to lose
        let i = MatchResults[ord(opponentItem)].find(Defeat)
        return Item(i)
    of "Y":
        # I need to draw
        return opponentItem
    of "Z":
        # I need to win
        let i = MatchResults[ord(opponentItem)].find(Win)
        return Item(i)
    else: discard


let
    file = readFile("day02.input.txt").splitLines()

var
    score1 = 0
    score2 = 0

for line in file:
    if line == "": continue

    # Part 1
    let
        items = line.split(' ')
        opponentItem: Item = parseItem(items[0])
        myItem1: Item = parseItem(items[1])
        round1: Round = play(myItem1, opponentItem)

    score1 += ord(round1) + myItem1.value()

    # Part 2
    let
        myItem2: Item = parseItemAsAction(items[1], opponentItem)
        round2: Round = play(myItem2, opponentItem)

    score2 += ord(round2) + myItem2.value()

echo "Part 1. Your final score is ", score1
echo "Part 2. Your final score is ", score2