import algorithm

let file_content = readFile("day06.input.txt")

proc allCharsAreDifferent(str: string): bool =
    # Checks whether all the characters in the input string are all unique using a linear search. This can be done when
    # the input string is sorted.
    var start_of_packet = str # Copy string
    start_of_packet.sort(Descending)
    for i in 1 ..< start_of_packet.len:
        if start_of_packet[i] == start_of_packet[i-1]:
            return false
    return true

proc findStartOfPacketPosition(file_content: string, packet_length: int): int =
    for i in 0 .. file_content.len - packet_length:
        var start_of_packet = file_content[i ..< i+packet_length]
        if start_of_packet.allCharsAreDifferent():
            return i + packet_length

echo "Part 1: ", findStartOfPacketPosition(file_content, 4)
echo "Part 2: ", findStartOfPacketPosition(file_content, 14)