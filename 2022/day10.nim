import strscans, strutils

type Instruction = object
  duration_cycles: int
  return_value: int

proc noop(): Instruction =
  return Instruction(duration_cycles: 1, return_value: 0)

proc addx(return_value: int): Instruction =
  return Instruction(duration_cycles: 2, return_value: return_value)

type CPU = object
  X: int
  program_counter: int
  cycle: int
  current_instruction: Instruction
  instructions: seq[string]

proc beginCycle(cpu: var CPU) =
  # When the CPU ends the execution of the current instruction it will fetch and decode the next instruction
  if cpu.cycle == 0 or cpu.current_instruction.duration_cycles <= 0:
    if cpu.program_counter < cpu.instructions.len():
      let next_instruction = cpu.instructions[cpu.program_counter]
      inc cpu.program_counter
      var return_value: int
      if scanf(next_instruction, "addx $i", return_value):
        cpu.current_instruction = addx(return_value)
      elif next_instruction == "noop":
        cpu.current_instruction = noop()
    else:
      # End of execution reached. Add noops indefinitely.
      cpu.current_instruction = noop()

proc endCycle(cpu: var CPU) =
  dec cpu.current_instruction.duration_cycles
  if cpu.current_instruction.duration_cycles <= 0:
    # At this point the current instruction has finished execution and returned a value
    cpu.X += cpu.current_instruction.return_value

  inc cpu.cycle

var
  cpu = CPU(X: 1, instructions: readFile("day10.input.txt").splitLines())
  sum_of_signal_strengths_during_a_cycle: int # It is measured IN THE MIDDLE of a cycle, not at the beginning or at the end of a cycle

for i in 1 .. 240:
  cpu.beginCycle()

  # Print pixel
  let
    i_pixel = (i-1) mod 40
    i_sprite = cpu.X

  if i_pixel == (i_sprite - 1) or i_pixel == i_sprite or i_pixel == (i_sprite + 1):
    stdout.write('#')
  else:
    stdout.write('.')

  if i mod 40 == 0:
    stdout.write('\n')

  # Measure signal strength for part 1
  if i <= 220 and (i+20) mod 40 == 0:
    sum_of_signal_strengths_during_a_cycle += i * cpu.X

  cpu.endCycle()

echo ""
echo "Part 1: ", sum_of_signal_strengths_during_a_cycle