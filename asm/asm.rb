require 'pry'

class String
  def isnum?
    /\A[-+]?\d+\z/ === self
  end

  def ishex?
    self.gsub(/0x/, "")[/\H/]
  end
end



class Parser
  def self.parse(file)
    file.readlines.each do |line|
      line.strip!
      if line.size == 0
        puts "skip"
        # skip empty lines
        next
      end
      instr = parseline(line)
      if instr.nil? then
        next
      end
      if instr[:mem] then
        instr[:instr_nr] = $instr_nr
        $instr_nr += 1
        $mem_instructions << instr
        next
      end
      if instr[:label] then
        instr[:ptr] = $instr_nr+1
        instr[:instr_nr] = $instr_nr
        $instr_nr += 1
        $labels << instr
        next
      end
      instr[:addr] = $instr_addr
      instr[:instr_nr] = $instr_nr
      $instr_nr += 1
      $instructions[$instr_addr] = instr
      $instr_addr += 1
    end
  end

  def self.parseline(line)
    puts "Parsing: #{line}"
    instr = {}
    commands, comment = line.split(";")
    if commands.length == 0 then return end
    # is it a label?
    if commands.include?(":") then
      # it is a label
      puts "Found label: #{commands.strip.chop}\n"
      instr[:label] = true;
      instr[:name] = commands.chop.strip
      return instr
    end
    command, argstr = commands.split(" ", 2)
    instr[:command] = command.strip
    if ISA::MEMINSTR.include?(instr[:command])
      puts "Found mem instr: #{command}\n"
      instr[:mem] = true
    end
    if argstr.nil? then
      # instr without args
      instr[:no_args] = true
      return instr
    end
    args = argstr.split(",")
    i = 0;
    args_array = []
    args[0..(args.length)].each do |arg|
      a = arg.strip.tr(",", "")
      if a.include?("0x") then
        args_array << a.to_i(16) #hex
      elsif a.isnum? then
        args_array << a.to_i(10) #dec
      else
        args_array << a.downcase #label or variable
      end
      i += 1
    end
    instr[:args] = args_array
    puts instr
    return instr
  end
end

class SymbolTable
  # only label symbols for now

  def self.idsymbols()
    $labels.each do |label|
      SymbolTable.push(label[:ptr], label[:name], :label)
    end
    $instructions.each do |addr, instr|
      # is it a symbol
      if instr[:no_args] then next end
      instr[:args].each do |arg|
        #if instr[:command] == "ldi" then binding.pry end
        if SymbolTable.issym?(arg) then
          #binding.pry
          SymbolTable.push(999, arg, :var)
          next
        end
      end
    end
  end

  def self.issym?(token)
    if token.is_a? Integer then
      return false
    end
    if ISA::REGS.include?(token) then
      return false
    end
    return true
  end

  def self.placemem()
    $mem_instructions.each do |instr|
      instr[:addr] = $instr_addr
      $instructions[$instr_addr] = instr
      $instr_addr += 1
    end
  end

  def self.resolveptrs()
    $symbols.each do |nr, sym|
      #binding.pry
      if sym[:ptr] then
        sym[:addr] = find_instr_nr(sym[:ptr])
        #puts "resolve: ptr(#{sym[:ptr]} => #{$instructions[sym[:ptr]][:addr]})\n"
      end
    end
    dump()
  end

  def self.find_instr_nr(nr)
    # for performance we could build a seperate ordered hash of linenr => addr
    # lets deal with that later
    $instructions.each do |lnr, instr|
      #binding.pry
      return instr[:addr] if instr[:instr_nr] == nr
      #puts "found: #{instr[:addr]}\n"
    end
    puts "Error: cannot resolve ptr: #{nr}\n"
    exit
  end

  def self.resolvesym(name)
    $symbols.each do |nr, symbol|
      #binding.pry
      return symbol[:addr] if symbol[:name] == name
    end
    return false
  end

  def self.push(ptr, name, type)
    s = { name: name, type: type}
    #does the symbol already exist?
    #if name == "r1" then binding.pry end
    if SymbolTable.find(name) then
      if s[:type] == :label then
        puts "triggered!"
        existing_key = SymbolTable.findindex(s)
        $symbols.delete(existing_key)
        s[:ptr] = ptr
        $symbols[existing_key] = s
        return
      else
        puts " - exists"
        return
      end
    end
    #is it a label?
    if s[:type] == :label then
      s[:ptr] = ptr
    end

    #add the symbol to the table
    $symbols[$symnr] = s
    $symnr +=1
  end

  def self.find(name)
    $symbols.each do |nr, symbol|
      return symbol if symbol[:name] == name
    end
    return false
  end

  def self.findindex(symbol)
    # clients.select{|key, hash| hash["client_id"] == "2180" }
    matches = $symbols.find{ |index, s| s[:name] == symbol[:name] }
    puts "matches: #{matches[0]}"
    return matches[0]
  end

  def self.dump()
    puts "- SYMBOL TABLE -----"
    $symbols.each do |nr, symbol|
      puts "#{nr} => #{symbol}\n"
    end
  end
end

class Coder

  def self.build(out_hex, out_mif)
    $instructions.each do |addr, instr|
      if instr[:label] then next end
      code = encode(instr)
      if code.length != 16 then
        binding.pry
        puts "Coder::build: code malformed (#{code.length} instead of 16b)\n"
        exit
      end
      Writer.hex(out_hex, code)
      Writer.mif(out_mif, instr[:addr], code)
    end
  end

  def self.encode(instr)
    code = ""
    puts "Encoding: #{instr}\n"
    #binding.pry
    instr[:opcode] = ISA::OPCODES[instr[:command]]
    if instr[:opcode] == :mem then
      code = ""
    elsif instr[:opcode] <= 3 then
      code += "0"
      code += "%02b" % instr[:opcode]
    else
      code += "1"
      code += "%06b" % instr[:opcode]
    end
    if instr[:no_args] then
      code += "000000000"
      return code
    end
    i = 0
    instr[:args].reverse_each do |arg|
      if SymbolTable.issym?(arg) then
        argr = arg
        arg = SymbolTable.resolvesym(arg)
        puts "Resolved: #{argr} into #{SymbolTable.resolvesym(argr)}\n"
        #binding.pry
      end

      case ISA::ARGS[instr[:command]][i]
      when :imm16
        code += bitsfromint(arg, 16, false)
      when :imm10
        code += bitsfromint(arg, 10, true)
      when :imm13br
        # we need to calculate the relative offset
        # instructions are +2
        # and we need to account for the extra increment the CPU does
        #binding.pry
        loc = (arg - (instr[:addr] + 1)) * 2
        puts "BR: calculated offset #{loc}\n"
        code += bitsfromint(loc, 13, true)
      when :imm7
        code += bitsfromint(arg, 7, true)
      when :imm7u
        code += bitsfromint(arg, 7, false)
      when :immir
        if ISA::IRIMM[arg.to_i].nil? then
          puts "Encode: no encoding available for immidiate: #{arg}\n"
          exit
        end
        code += "%03b" % ISA::IRIMM[arg.to_i]
      when :reg
        #binding.pry
        code += "%03b" % ISA::REGS[arg]
      when :reg2
        #binding.pry
        code += "%02b" % ISA::REGS2[arg]
      else
        #binding.pry
        puts "Encode: cannot resolve argument: #{arg}\n"
        exit
      end
      i +=1
    end
    puts code
    return code
  end

  def self.bitsfromint(int, bitnr, sext)
    if sext then
      # MSB reserved for sign
      # 13bits -> 12 bits signed -> max 0xfff
      # 10bits -> 9 bits signed -> max 0x1FF
      # 7 bits -> 6 bits signed -> max 0x3f
      if int.abs > ((2**(bitnr-1))-1) then
        Error.exit("Bitsfromint: signed int #{int} cannot fit in #{bitnr} bits!")
      end
      if int < 0 then
        bin = (int & 0xffff).to_s(2)
        # bin will always be 16b long
        offset = 15 - bitnr
        bin.slice!(0..offset)
        return bin
      else
        return "%0#{bitnr}b" % int
      end
    else
      # we can use all the bits
      if int < 0 then
        puts "Bitsfromint: unsigned number cannot be negative! (#{int})\n"
        exit
      end
      if int > ((2**bitnr)-1) then
        Error.exit("Bitsfromint: unsigned int #{int} cannot fit in #{bitnr} bits!")
      end
      return "%0#{bitnr}b" % int
    end
  end
end

class Writer
  def self.hex(output, code)
    b0 = code[0..7]
    b1 = code[8..15]

    h0 = b0.to_i(2)
    h1 = b1.to_i(2)

    hex = (h0.to_i == 0) ? "00" : "%02x" % h0
    hex += (h1.to_i == 0) ? "00" : "%02x" % h1
    output.write(hex)
    output.write("\n")
  end

  def self.mifinit(output)
    output.write("DEPTH = 256;\n")
    output.write("WIDTH = 16;\n")
    output.write("ADDRESS_RADIX = HEX;\n")
    output.write("DATA_RADIX = BIN;\n")
    output.write("CONTENT\n")
    output.write("BEGIN\n")
    output.write("\n")
  end

  def self.mif(output, addr, code)
    output.write("%02x" % addr)
    output.write(" : ")
    output.write(code)
    output.write(";\n")
  end

  def self.mifclose(output)
    output.write("\n")
    output.write("END;")
  end
end

class ISA
  OPCODES= {
    "ldi"   => 0,
    "br"   => 1,
    "stw"  => 7,
    "add" => 10,
    "addskp.z" => 15,
    "addskp.nz" => 16,
    "addskpi.z" => 22,
    "addskpi.nz" => 23,
    "addhi" => 30,
    "defw" => :mem,
    "hlt" => 63
  }.freeze

  ARGS= {
    "ldi" => [:imm10, :reg],
    "br" => [:imm13br],
    "stw" => [:imm7, :reg, :reg],
    "add" => [:reg, :reg, :reg],
    "addskp.z" => [:reg, :reg, :reg],
    "addskp.nz" => [:reg, :reg, :reg],
    "addskpi.z" => [:immir, :reg, :reg],
    "addskpi.nz" => [:immir, :reg, :reg],
    "addhi" => [:imm7u, :reg2],
    "defw" => [:imm16]
  }.freeze

  REGS= {
    "r0" => 0,
    "r1" => 1,
    "r2" => 2,
    "r3" => 3,
    "r4" => 4,
    "r5" => 5,
    "SP" => 6,
    "r6" => 6,
    "r7" => 7,
    "PC" => 7
  }.freeze

  REGS2= {
    "r1" => 0,
    "r2" => 1,
    "r3" => 2,
    "r4" => 3
  }.freeze


  IRIMM= {
    #{ 1,2,4,8,-8,-4,-2,-1 }
    1 => 0,
    2 => 1,
    4 => 2,
    8 => 3,
    -8 => 4,
    -4 => 5,
    -2 => 6,
    -1 => 7
  }

  MEMINSTR= {
    "defw" => 1
  }
end

class Error
  def self.exit(msg)
    puts "#{msg}\n\n"
    exit
  end
end


# main
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
file_name = args["f"]
input = File.open(file_name, "r")
out_hex = File.open("A.hex", "w+")
out_mif = File.open("A.mif", "w+")

$instructions = {}
$mem_instructions =[]
$labels = []
$symbols = {}
$instr_nr = 0
$instr_addr = 0
$symnr = 0
#$memptr = 16


#SymbolTable.loadpredefined()
Parser.parse(input)
SymbolTable.idsymbols()
SymbolTable.placemem()
SymbolTable.resolveptrs()
Writer.mifinit(out_mif)
Coder.build(out_hex, out_mif)
Writer.mifclose(out_mif)
SymbolTable.dump()

puts "\n------ Instruction tokens -----------\n"
$instructions.each do |nr, instr|
  puts "#{nr} => #{instr}\n"
end