require 'lib/stateful/stateful'
# ===============================================================
# Welcome to repl.rb
# ===============================================================
# You can experiement with code within this file. Code in this
# file is only executed when you save (and only excecuted ONCE).
# ===============================================================

# ===============================================================
# REMOVE the "x" from the word "xrepl" and save the file to RUN
# the code in between the do/end block delimiters.
# ===============================================================

# ===============================================================
# ADD the "x" to the word "repl" (make it xrepl) and save the
# file to IGNORE the code in between the do/end block delimiters.
# ===============================================================

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
repl do
  class RecordEnter
    def call(subject) = subject.log << :chasing_after_enter_obj
  end

  class TestMob
    include Stateful

    attr_reader :log
    attr_accessor :scared, :sees_player, :safe

    state_machine do
      state :appearing, initial: true do
        after_enter :on_appear_enter            # symbol form
      end

      state :idling do                          # proc form
        before_enter { log << :idling_before_enter }
        after_enter  { log << :idling_after_enter }
        before_exit  { log << :idling_before_exit }
        after_exit   { log << :idling_after_exit }
      end

      state :chasing do
        after_enter RecordEnter.new             # callable-object form
      end

      state :fleeing

      event :idle do
        before { log << :idle_event_before }
        after  { log << :idle_event_after }
        transition from: :appearing, to: :idling
      end

      event :react do
        # Precedence: scared beats sees_player if both are true
        transition from: :idling, to: :fleeing, if: :scared?
        transition from: :idling, to: :chasing, if: :sees_player?
      end

      event :calm, if: :safe? do
        transition from: %i[chasing fleeing], to: :idling
      end
    end

    def initialize
      @log = []
      @scared = false
      @sees_player = false
      @safe = false
    end

    def scared?      = @scared
    def sees_player? = @sees_player
    def safe?        = @safe

    def on_appear_enter = @log << :appearing_after_enter

    # clear the log between steps so each assertion is isolated
    def reset_log = @log = []
  end

  $passed = 0
  $failed = 0

  def check(label, actual, expected)
    if actual == expected
      $passed += 1
      puts "✓ #{label}"
    else
      $failed += 1
      puts "✗ #{label}"
      puts "expected: #{expected.inspect}"
      puts "actual: #{actual.inspect}"
    end
  end

  def section(label)
    puts "\n=== #{label} ==="
  end

  mob = TestMob.new

  section 'initial state'
  check 'starts in :appearing', mob.current_state, :appearing
  check 'appearing? true', mob.appearing?, true
  check 'idling? false', mob.idling?, false

  section ':idle'
  mob.reset_log
  result = mob.idle
  check 'returns true', result, true
  check 'now :idling', mob.current_state, :idling
  check 'hook order', mob.log, %i[
    idle_event_before
    idling_before_enter
    idling_after_enter
    idle_event_after
  ]

  section ':react'
  mob.reset_log
  result = mob.react
  check 'returns false', result, false
  check 'stays :idling', mob.current_state, :idling
  check 'no callbacks ran', mob.log, []

  section ':react with sees_player?'
  mob.reset_log
  mob.sees_player = true
  result = mob.react
  check 'returns true', result, true
  check 'now :chasing', mob.current_state, :chasing
  check 'exit idling, enter chasing', mob.log, %i[
    idling_before_exit
    idling_after_exit
    chasing_after_enter_obj
  ]

  section ':calm while safe? false'
  mob.reset_log
  result = mob.calm
  check 'returns false', result, false
  check 'stays :chasing', mob.current_state, :chasing
  check 'no callbacks ran', mob.log, []

  section ':calm with safe? true'
  mob.reset_log
  mob.safe = true
  result = mob.calm
  check 'returns true', result, true
  check 'now :idling', mob.current_state, :idling

  section 'guard precedence: scared beats sees_player'
  mob.reset_log
  mob.scared = true
  mob.sees_player = true
  result = mob.react
  check 'returns true', result, true
  check 'now :fleeing', mob.current_state, :fleeing

  # ── tally ─────────────────────────────────────────────────────────────
  puts "\n#{'=' * 40}"
  puts "PASSED: #{$passed} FAILED: #{$failed}"
  puts "\n#{'=' * 40}"
end

# ====================================================================================
# Ruby Crash Course:
# Strings, Numeric, Booleans, Conditionals, Looping, Enumerables, Arrays
# ====================================================================================

# ====================================================================================
#  Strings
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  message = 'Hello World'
  puts 'The value of message is: ' + message
  puts "Any value can be interpolated within a string using \#{}."
  puts "Interpolated message: #{message}."
  puts 'This #{message} is not interpolated because the string uses single quotes.'
end

# ====================================================================================
#  Numerics
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  a = 10
  puts "The value of a is: #{a}"
  puts "a + 1 is: #{a + 1}"
  puts "a / 3 is: #{a / 3}"
end

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  b = 10.12
  puts "The value of b is: #{b}"
  puts "b + 1 is: #{b + 1}"
  puts "b as an integer is: #{b.to_i}"
  puts ''
end

# ====================================================================================
#  Booleans
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  c = 30
  puts "The value of c is #{c}."

  puts 'This if statement ran because c is truthy.' if c
end

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  d = false
  puts "The value of d is #{d}."

  puts 'This if statement ran because d is falsey, using the not operator (!) makes d evaluate to true.' unless d

  e = nil
  puts "Nil is also considered falsey. The value of e is: #{e}."

  puts 'This if statement ran because e is nil (a falsey value).' unless e
end

# ====================================================================================
#  Conditionals
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  i_am_true  = true
  i_am_nil   = nil
  i_am_false = false
  i_am_hi    = 'hi'

  puts '======== if statement'
  i_am_one = 1
  puts 'This was printed because i_am_one is truthy.' if i_am_one

  puts '======== if/else statement'
  if i_am_false
    puts 'This will NOT get printed because i_am_false is false.'
  else
    puts 'This was printed because i_am_false is false.'
  end

  puts '======== if/elsif/else statement'
  if i_am_false
    puts 'This will NOT get printed because i_am_false is false.'
  elsif i_am_true
    puts 'This was printed because i_am_true is true.'
  else
    puts 'This will NOT get printed i_am_true was true.'
  end

  puts '======== case statement '
  i_am_one = 1
  case i_am_one
  when 10
    puts 'case equaled: 10'
  when 9
    puts 'case equaled: 9'
  when 5
    puts 'case equaled: 5'
  when 1
    puts 'case equaled: 1'
  else
    puts "Value wasn't cased."
  end

  puts '======== different types of comparisons'
  puts 'equal (4 == 4)' if 4 == 4

  puts 'not equal (4 != 3)' if 4 != 3

  puts 'less than (3 < 4)' if 3 < 4

  puts 'greater than (4 > 3)' if 4 > 3

  puts 'or statement ((4 > 3) || (3 < 4) || false)' if (4 > 3) || (3 < 4) || false

  puts 'and statement ((4 > 3) && (3 < 4))' if (4 > 3) && (3 < 4)
end

# ====================================================================================
# Looping
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts '======== times block'
  3.times do |i|
    puts i
  end
  puts '======== range block exclusive'
  (0...3).each do |i|
    puts i
  end
  puts '======== range block inclusive'
  (0..3).each do |i|
    puts i
  end
end

# ====================================================================================
#  Enumerables
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts '======== array each'
  colors = %w[red blue yellow]
  colors.each do |color|
    puts color
  end

  puts '======== array each_with_index'
  colors = %w[red blue yellow]
  colors.each_with_index do |color, i|
    puts "#{color} at index #{i}"
  end
end

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts '======== single parameter function'
  def add_one_to(n)
    n + 5
  end

  puts add_one_to(3)

  puts '======== function with default value'
  def function_with_default_value(v = 10)
    v * 10
  end

  puts "passing three: #{function_with_default_value(3)}"
  puts "passing nil: #{function_with_default_value}"

  puts '======== Or Equal (||=) operator for nil values'
  def function_with_nil_default_with_local(a = nil)
    result   = a
    result ||= 'or equal operator was exected and set a default value'
  end

  puts "passing 'hi': #{function_with_nil_default_with_local 'hi'}"
  puts "passing nil: #{function_with_nil_default_with_local}"
end

# ====================================================================================
#  Arrays
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts '======== Create an array with the numbers 1 to 10.'
  one_to_ten = (1..10).to_a
  puts one_to_ten

  puts '======== Create a new array that only contains even numbers from the previous array.'
  one_to_ten = (1..10).to_a
  evens = one_to_ten.find_all do |number|
    number.even?
  end
  puts evens

  puts '======== Create a new array that rejects odd numbers.'
  one_to_ten = (1..10).to_a
  also_even = one_to_ten.reject do |number|
    number.odd?
  end
  puts also_even

  puts '======== Create an array that doubles every number.'
  one_to_ten = (1..10).to_a
  doubled = one_to_ten.map do |number|
    number * 2
  end
  puts doubled

  puts '======== Create an array that selects only odd numbers and then multiply those by 10.'
  one_to_ten = (1..10).to_a
  odd_doubled = one_to_ten.find_all do |number|
    number.odd?
  end.map do |odd_number|
    odd_number * 10
  end
  puts odd_doubled

  puts '======== All combination of numbers 1 to 10.'
  one_to_ten = (1..10).to_a
  all_combinations = one_to_ten.product(one_to_ten)
  puts all_combinations

  puts '======== All uniq combinations of numbers. For example: [1, 2] is the same as [2, 1].'
  one_to_ten = (1..10).to_a
  uniq_combinations =
    one_to_ten.product(one_to_ten)
              .map do |unsorted_number|
      unsorted_number.sort
    end.uniq
  puts uniq_combinations
end

# ====================================================================================
#  Advanced Arrays
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts '======== All unique Pythagorean Triples between 1 and 40 sorted by area of the triangle.'

  one_to_hundred = (1..40).to_a
  triples =
    one_to_hundred.product(one_to_hundred).map do |width, height|
      [width, height, Math.sqrt(width**2 + height**2)]
    end.find_all do |_, _, hypotenuse|
      hypotenuse.to_i == hypotenuse
    end.map do |triangle|
      triangle.map(&:to_i)
    end.uniq do |triangle|
      triangle.sort
    end.map do |width, height, hypotenuse|
      [width, height, hypotenuse, (width * height) / 2]
    end.sort_by do |_, _, _, area|
      area
    end

  triples.each do |width, height, hypotenuse, area|
    puts "(#{width}, #{height}, #{hypotenuse}) = #{area}"
  end
end
