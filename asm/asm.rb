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
      parsed_instr = parseline(line)
      if parsed_instr.nil? then
        next
      end

      if parsed_instr[:command] == ".code" then
        if $instr_nr != 0 then
          Error.mexit("ERROR: .code needs to be the first declaration (is: #{$instr_nr})")
        end
        if parsed_instr[:no_args] then next end
        # we need to relocate code and add a little trampoline to it at the start
        # load addr, branch to it
        trampoline = parsela16({:args => ["r1", parsed_instr[:args][0]]})
        trampoline << {:command => "br", :args => [parsed_instr[:args][0]]}
        appendinstr(trampoline)
        $instr_addr = parsed_instr[:args][0]
        next
      end
      if parsed_instr[:command] == ".data" then
        if $mem_ptr != 0 then
          Error.mexit("ERROR: .data can only be declared once")
        end
        if parsed_instr[:no_args] then next end
        $mem_ptr = parsed_instr[:args][0]
        next
      end
      if parsed_instr[:command] == "ld16" then
        instructions = parseld16(parsed_instr)
      elsif parsed_instr[:command] == "la16" then
        # this will often be a symbol which we haven't resolved at this point
        # we take a conservative approach and insert 2 instructions to be adjusted after symbols
        # have been resolved
        instr_lo = {:command => "lda", :args => [parsed_instr[:args][0], parsed_instr[:args][1]], :adjust => true}
        instr_hi = {:command => "addhi", :args => [parsed_instr[:args][0], parsed_instr[:args][1]], :adjust => true}
        instructions = [instr_lo, instr_hi]
      else
        instructions = [parsed_instr]
      end

      appendinstr(instructions)
    end
  end

  def self.appendinstr(instructions)
    instructions.each do |instr|
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
      $instr_addr += 2
    end
  end

  def self.parseline(line)
    puts "PreParsing: #{line}"
    instr = {}
    commands, comment = line.split(";")
    #binding.pry
    if commands.nil? then return end
    if commands.length == 0 then return end
    if commands[0] == '.' && commands[0..4] != '.code' && commands[0..4] != '.data' then return end
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
      if a.include?("(") then
        offset, base = a.split("(")
        base.chop!
        args_array << number(base) #order matters!
        args_array << number(offset)
      else
        args_array << number(a)
      end
      i += 1
    end
    instr[:args] = args_array
    puts instr
    return instr
  end

  def self.number(nr)
    if nr.include?("0x") then
      return nr.to_i(16) #hex
    elsif nr.isnum? then
      return nr.to_i(10) #dec
    else
      return nr.downcase #label or variable
    end
  end

  def self.parseld16(instr)
    # ld16 allows the compiler to load an arbitrary length (up to 16b) imm in a reg
    # here we check its length and see if we need 1 or 2 instructions

    if instr[:args][1] <= 511 then
      # imm is small enough to load with ldi
      return [{:command => "ldi", :args => instr[:args]}]
    else
      # imm requires two instructions to load: ldi followed by addhi
      lo = instr[:args][1] & 0x1ff
      hi = (instr[:args][1] & 0xfe00) >> 9
      instr_lo = {:command => "ldi", :args => [instr[:args][0], lo] }
      instr_hi = {:command => "addhi", :args => [instr[:args][0], hi]}
      return [instr_lo, instr_hi]
    end
  end

  def self.parsela16(instr, addr)
    # la16 allows the compiler to load an arbitrary length (up to 16b) address in a reg
    # here we check its length and see if we need 1 or 2 instructions
    #binding.pry

    if addr <= 511 then
      if instr[:command] == "lda" then
        # addr is small enough to load with lda
        return addr
      else
        # commmand == addhi which is not needed
        instr[:nop] = true
        return :nop
      end
    else
      # addr requires two instructions to load
      if instr[:command] == "lda" then
        return (addr & 0x1ff)
      else
        return (addr & 0xfe00) >> 9
      end
    end
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
    if token == 'NO ARG TEMPLATE' then
      return false
    end
    return true
  end

  def self.placemem()
    if $mem_ptr == 0 then
      $mem_ptr = $instr_addr
    end
    $mem_instructions.each do |instr|
      instr[:addr] = $mem_ptr
      $instructions[$mem_ptr] = instr
      $mem_ptr += 1
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
    puts "- SYMBOL TABLE ----- (#{$symbols.length})"
    #binding.pry
    $symbols.each do |nr, symbol|
      puts "#{nr} => #{symbol} (#{(symbol[:addr]).to_s(16)})\n"
    end
  end
end

class Coder

  def self.build(out_hex, out_mif)
    $instructions.each do |addr, instr|
      if instr[:label] then next end
      code = encode(instr)
      if code == :nop then
        $addr_offset += 2
        next
      end
      if code.length != 16 then
        binding.pry
        puts "Coder::build: code malformed (#{code.length} instead of 16b)\n"
        exit
      end
      b0 = code[0..7]
      b1 = code[8..15]

      h0 = b0.to_i(2)
      h1 = b1.to_i(2)

      hex = (h0.to_i == 0) ? "00" : "%02x" % h0
      hex += (h1.to_i == 0) ? "00" : "%02x" % h1
      instr[:encoding] = hex;
      Writer.hex(out_hex, code)
      Writer.mif(out_mif, instr[:addr]-$addr_offset, code)
    end
  end

  def self.encode(instr)
    code = ""
    puts "Encoding: #{instr}\n"
    #binding.pry
    instr[:opcode] = ISA::OPCODES[instr[:command]]
    if instr[:opcode].nil? then
      puts "Unknown instruction: #{instr[:command]}\n"
      exit
    end
    if instr[:opcode] == :mem then
      code = ""
    elsif instr[:opcode] <= 3 then
      code += "0"
      code += "%02b" % instr[:opcode]
    else
      code += "1"
      code += "%06b" % instr[:opcode]
      if [31,32].include?(instr[:opcode]) then
        # padd instructions
        code += "000000"
      end
    end
    if instr[:no_args] then
      code += "000000000"
      return code
    end
    i = instr[:args].length - 1
    ISA::ARGS[instr[:command]].each do |argtemplate|
      # get the right arg
      if argtemplate[0] == 'x' then
        # template does not consume an arg
        arg = 'NO ARG TEMPLATE'
      else
        arg = instr[:args][i]
        i -= 1
      end
      #binding.pry
      if SymbolTable.issym?(arg) then
        argr = arg
        arg = SymbolTable.resolvesym(arg)
        puts "Resolved: (#{i})#{argr} into #{SymbolTable.resolvesym(argr)}\n"
        #binding.pry
      end

      if instr[:adjust] && (argtemplate == :imm10 || argtemplate == :imm7u) then
        arg = Parser.parsela16(instr, arg)
        #binding.pry
        if arg == :nop then
          return :nop
        end
      end

      case argtemplate
      when :imm16
        code += bitsfromint(arg, 16, false)
      when :imm10
        code += bitsfromint(arg, 10, true)
      when :imm13br
        # we need to calculate the relative offset
        # instructions are +2
        # and we need to account for the extra increment the CPU does
        #binding.pry
        loc = (arg - (instr[:addr] + 1))
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
      when :xr0
        code += "000"
      when :BPreg
        if arg.upcase != "BP" && arg.upcase != "R5" then
          puts "Encode: base must be bp/r5"
          exit(1)
        end
      else
        #binding.pry
        puts "Encode: cannot resolve argument: #{arg}\n"
        exit
      end
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
        Error.mexit("Bitsfromint: signed int #{int} cannot fit in #{bitnr} bits!")
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
        Error.mexit("Bitsfromint: unsigned int #{int} cannot fit in #{bitnr} bits!")
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
    "lda"   => 0,
    "br"   => 1,
    "ldw"  => 4,
    "stw"  => 7,
    "add" => 10,
    "mov" => 10,
    "sub" => 11,
    "addskp.z" => 15,
    "addskp.nz" => 16,
    "addi" => 17,
    "addskpi.z" => 22,
    "addskpi.nz" => 23,
    "ldwb" => 24,
    "stwb" => 26,
    "addhi" => 30,
    "push" => 31,
    "pop" => 32,
    "defw" => :mem,
    "hlt" => 63
  }.freeze

  ARGS= {
    "ldi" => [:imm10, :reg],
    "lda" => [:imm10, :reg],
    "br" => [:imm13br],
    "ldw" => [:imm7, :BPreg, :reg2],
    "stw" => [:imm7, :BPreg, :reg2],
    "add" => [:reg, :reg, :reg],
    "mov" => [:reg, :xr0, :reg],
    "sub" => [:reg, :reg, :reg],
    "addskp.z" => [:reg, :reg, :reg],
    "addskp.nz" => [:reg, :reg, :reg],
    "addi" => [:immir, :reg, :reg],
    "addskpi.z" => [:immir, :reg, :reg],
    "addskpi.nz" => [:immir, :reg, :reg],
    "ldwb" => [:reg, :reg, :reg],
    "stwb" => [:reg, :reg, :reg],
    "addhi" => [:imm7u, :reg2],
    "push" => [:reg],
    "pop" => [:reg],
    "defw" => [:imm16]
  }.freeze

  REGS= {
    "r0" => 0,
    "r1" => 1,
    "r2" => 2,
    "r3" => 3,
    "r4" => 4,
    "r5" => 5,
    "bp" => 5,
    "sp" => 6,
    "r6" => 6,
    "pc" => 7
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
  def self.mexit(msg)
    puts "#{msg}\n\n"
    exit(1)
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
$mem_ptr = 0
$symnr = 0
$addr_offset = 0
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
  puts "0x#{(nr).to_s(16)} => #{instr}\n"
end