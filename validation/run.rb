# run.rb
require 'pry'

args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
test_groups = args["t"].split("")

output = File.open("all.s", "w+")

# build list of tests to run
all_tests = Dir["*.s"]
in_files = []

all_tests.each do |name|
  if name[1] == "_" && test_groups.include?(name[0]) then
    in_files << name
  end
end

init_mem = 0
testnr = 0
last_test = in_files.length

output.write(".code 0x100\n\n")

in_files.each do |test_name|
  testnr +=1;
  tname, ext = test_name.split(".")
  puts tname
  syms = []

  tf = File.open(test_name, "r")

  tf.readlines.each do |line|
    handled = 0;
    # check for init_mem
    # replace END_TEST
    # replace PASS(pass)
    # - strategy add a label to the start of each test (with a dummy instr?)
    # - let a replaced PASS(pass) link there

    if line.strip == "include(tmacros.h)" then
      if testnr == 1 then
        output.write(line)
      end
      handled = 1
    end

    if line.strip[0..2] == "SYM" then
      l, symbol = line.strip.split("(")
      symbol.chop!
      syms << symbol
      handled = 1
      #binding.pry
    end

    if line.strip[0..8] == "INIT_TEST" then
      label = "runall_#{testnr}:"
      output.write("#{label}\n")
      output.write(line)
      handled = 1
    end

    if init_mem == 0 && line.strip == "INIT_MEM" then
      output.write("INIT_MEM\n")
      init_mem = 1
      handled = 1
    end

    if line.strip == "PASS(pass)" then
      if testnr == last_test then
        output.write(line)
      else
        output.write("PASS(runall_#{(testnr + 1)})")
      end
      handled = 1
    end

    if line.strip == "END_TEST" then
      if testnr == last_test then
        output.write(line)
      end
      handled = 1
    end

    unless (handled == 1) then
      syms.each do |s|
        line.sub!(s, "#{s}_#{tname}")
        #puts s
      end
      #puts line
      #binding.pry
      output.write(line)
    end
  end
  tf.close
end

output.close
