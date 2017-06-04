#!/usr/bin/env ruby

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
      parsed_instr[:line] = line
      #binding.pry
      if parsed_instr[:command] == ".code" then
        if $instr_nr != 0 then
          Error.mexit("ERROR: .code needs to be the first declaration (is: #{$instr_nr})")
        end
        if parsed_instr[:no_args] then next end
        # we need to relocate code and add a little trampoline to it at the start
        # load addr, branch to it
#         trampoline = parseld16({:args => ["r1", parsed_instr[:args][0]], :line => line})
#         trampoline << {:command => "br", :args => [parsed_instr[:args][0]]}
#         #binding.pry
#         noreloc = 0
#         trampoline.each do |tr|
#           tr[:no_reloc] = noreloc
#           noreloc +=2
#         end
#         appendinstr(trampoline)
        $code_ptr = parsed_instr[:args][0]
        next
      end
      if parsed_instr[:command] == ".data" then
        if $data_ptr != 0 then
          Error.mexit("ERROR: .data can only be declared once")
        end
        if parsed_instr[:no_args] then next end
        $data_ptr = parsed_instr[:args][0]
        puts "data pointer #{$data_ptr}\n"
        next
      end
      if parsed_instr[:command] == "ld16" then
        instructions = parseld16(parsed_instr)
      elsif parsed_instr[:command] == "la16" then
        # this will often be a symbol which we haven't resolved at this point
        # we take a conservative approach and insert 2 instructions to be adjusted after symbols
        # have been resolved
        instr_lo = {:command => "lda", :args => [parsed_instr[:args][0], parsed_instr[:args][1]], :adjust => true, :line => line}
        instr_hi = {:command => "addhi", :args => [parsed_instr[:args][0], parsed_instr[:args][1]], :adjust => true}
        instructions = [instr_lo, instr_hi]
        #binding.pry
      elsif parsed_instr[:command] == "defstr" then
        # expand the string into individual chars and add NULL
        instructions = []
        for i in 0..(parsed_instr[:string].length)
          instr ={}
          instr[:command] = "defb"
          instr[:mem] = true
          instr[:byte_enable] = true
          if i == parsed_instr[:string].length
            instr[:args] = [0] # null terminator
          else
            instr[:args] = [parsed_instr[:string][i].ord]
          end
          if i == 0 || i == 1 then
            instr[:line] = line
          end
          #binding.pry
          instructions << instr
        end

        #binding.pry
      elsif parsed_instr[:command] == "defs" then
        instructions = []
        for i in 1..(parsed_instr[:bss] / 2)
          instr ={}
          instr[:command] = "defw"
          instr[:mem] = true
          instr[:bss] = true
          instr[:args] = [0]
          if i == 1 then
            instr[:line] = line
          end
          instructions << instr
        end
      else
        # if its a stw/b s7(bp), r0 instr
        if parsed_instr[:command] == "stw" && parsed_instr[:args][0].is_a?(Integer) && parsed_instr[:args][2] == "r0" then
          parsed_instr[:command] = "stw0"
        end
        if parsed_instr[:command] == "stb" && parsed_instr[:args][0].is_a?(Integer) && parsed_instr[:args][2] == "r0" then
          parsed_instr[:command] = "stb0"
        end
        instructions = [parsed_instr]
      end
      appendinstr(instructions)
    end
  end

  def self.appendinstr(instructions)
    instructions.each do |instr|
      valid_instr?(instr)
      puts "adding: #{instr} - #{$instr_nr} (#{$double_label_guard})\n"
      if instr[:mem] then
        instr[:instr_nr] = $instr_nr
        $instr_nr += 1
        $mem_instructions << instr
        $double_label_guard = 0
        next
      end
      if instr[:label] then
        if $double_label_guard > 0 then
          if $double_label_guard > 1 then
            Error.mexit("Encountered more than two sequential labels")
          end
          prev_label = find_label($instr_nr - 1)
          prev_label[:ptr] += 1
        end
        instr[:ptr] = $instr_nr + 1
        instr[:instr_nr] = $instr_nr
        $instr_nr += 1
        $labels << instr
        $double_label_guard += 1
        next
      end
      instr[:addr] = $instr_addr
      instr[:instr_nr] = $instr_nr
      $instr_nr += 1
      $instructions << instr
      $double_label_guard = 0
    end
  end

  def self.valid_instr?(instr)
    if instr[:label] then return end
    if ISA::OPCODES[instr[:command]].nil?
      Error.mexit("Unknown command: #{instr[:command]}\n")
    end

    unless instr[:no_args]
      nr_of_args = ISA::ARGS[instr[:command]].values.select {|a| a != :x}.length
      if nr_of_args != instr[:args].length then
        binding.pry
        Error.mexit("Argument error: #{instr[:command]}, #{ISA::ARGS[instr[:command]].length} got #{instr[:args].length}")
      end
    end
    return
  end

  def self.find_label(nr)
    $labels.each do |label|
      if label[:instr_nr] == nr then
        return label
      end
    end
  end

  def self.parseline(line)
    puts "Parsing: #{line}"
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
      if instr[:command] == 'defb' || instr[:command] == 'defw' then
        args = argstr.split("'")
        if args.length == 1 then
          arg = number(args[0])
        else
          arg = args[1].ord
        end
        instr[:args]=[arg]
      end
      if instr[:command] == 'defb' then
         instr[:byte_enable] = true
      end
      if instr[:command] == 'defstr' then
        if argstr.scan(/["]/).empty?
          Error.mexit("ERROR: defs expects a quoted string or # of bytes. (#{argstr})")
        end
        instr[:string] = argstr[1..-2]
        #binding.pry
      end
      if instr[:command] == 'defs' then
        instr[:bss] = argstr.to_i
      end
      return instr
    end
    if instr[:command].length > 4 && instr[:command][0..3] == "skip" then
      # split condition from command and add it to the argstr
      skip, cond = instr[:command].split(".")
      instr[:command] = skip
      argstr += "," + cond
      #binding.pry
    end
    if argstr.nil? || argstr == "" then
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
        args_array << number(offset)
        args_array << number(base)
      else
        args_array << number(a)
      end
      i += 1
    end
    instr[:args] = parseargs(args_array)

    puts instr
    return instr
  end

  def self.parseargs(args)
    #binding.pry
    # check if we are loading a char
    if args[1].is_a? String then
      if args[1][0..3] == "char" then
        if args[1].include?("@") then
          # extra signal char for use with m4 macros
          x, char = args[1].split("@")
        else
          x, char = args[1].split("'")
        end
        #binding.pry
        args[1] = char.ord
      end
    end
    #binding.pry
    return args
  end

  def self.number(nr)
    #binding.pry
    if nr.to_s[0..1] == "0x" then
      return nr.to_i(16) #hex
    elsif nr.isnum? then
      return nr.to_i(10) #dec
    else
      return nr #label or variable
    end
  end

  def self.parseld16(instr)
    # ld16 allows the compiler to load an arbitrary length (up to 16b) imm in a reg
    # here we check its length and see if we need 1 or 2 instructions

    if instr[:args][1] <= 511 then
      # imm is small enough to load with ldi
      return [{:command => "ldi", :args => instr[:args], :line => instr[:line]}]
    else
      # imm requires two instructions to load: ldi followed by addhi
      lo = instr[:args][1] & 0x1ff
      hi = (instr[:args][1] & 0xfe00) >> 9
      instr_lo = {:command => "ldi", :args => [instr[:args][0], lo], :line => instr[:line] }
      instr_hi = {:command => "addhi", :args => [instr[:args][0], hi] }
      return [instr_lo, instr_hi]
    end
  end
end

class SymbolTable
  # only label symbols for now

  def self.idsymbols()
    puts "ID SYM\n"
    $labels.each do |label|
      SymbolTable.push(label[:ptr], label[:name], :label)
    end
    $instructions.each do |instr|
      # is it a symbol
      if instr[:no_args] then next end
      new_args = []
      idx = 0
      instr[:args].each do |arg|
        #if instr[:command] == "ldi" then binding.pry end
        # id calculations
        if arg.is_a?(String) && ( arg.include?("+") || arg.include?("-")) then
          arg, calc = arg.split(/(?=[+|-])\s*/)
          new_args << arg
          instr[:calc] = calc
          #binding.pry
        else
          new_args << arg
        end
        if SymbolTable.issym?(arg) then
          #binding.pry
          SymbolTable.push(999, arg, :var)
          next
        end
        idx += 1
      end
      instr[:args] = new_args
    end
  end

  def self.issym?(token)
    if token.is_a? Integer then
      return false
    end
    if ISA::REGS.include?(token) then
      return false
    end
    if ISA::COND.include?(token) then
      return false
    end
    if token == 'NO ARG TEMPLATE' then
      return false
    end
    return true
  end

  def self.placeinstr()
    $last_addr = $code_ptr
    $instructions.each do |instr|
      # if instr[:mem] then
#         next
#       end
      if instr[:no_reloc] then
        instr[:addr] = instr[:no_reloc]
      else
        if instr[:byte2] then
          instr[:addr] = $last_addr - 1
        else
          instr[:addr] = $last_addr
          $last_addr += 2
        end
      end
    end
    #binding.pry
  end

  def self.placemem()
    if $data_ptr != 0 then
      if $last_addr > $data_ptr then
        Error.mexit("ERROR: .code and .data sections overlap")
      end
      ptr = $data_ptr
      lock_loc = 1;
    else
      ptr = $last_addr
    end
    i = 0
    init_mem = []
    bss_mem = []
    #binding.pry
    while(i <= $mem_instructions.length - 1) do
      if $mem_instructions[i][:bss] then
        bss_mem << $mem_instructions[i]
      else
        init_mem << $mem_instructions[i]
      end
      i +=1
    end
    $mem_instructions = init_mem + bss_mem
    i = 0
    while(i <= $mem_instructions.length - 1) do
      instr = $mem_instructions[i]
      # for byte loads: check if next is also a byte then merge and skip one; other wise proceed as normal
      # we cannot fully skip the 2nd byte since we need to leave a breadcrumb to resolve the address
      if instr[:byte_enable] && $mem_instructions[i+1] && $mem_instructions[i+1][:byte_enable] then
        # byte_1
        #binding.pry
        instr[:args][0] = instr[:args][0] << 8 |  $mem_instructions[i+1][:args][0]
        instr[:addr] = ptr
        $instructions << instr
        # byte_2
        $mem_instructions[i+1][:byte2] = true
        $mem_instructions[i+1][:addr] = ptr + 1
        $instructions << $mem_instructions[i+1]
        ptr += 2
        i += 2 # skip the 2nd byte since we already added it
      else
        instr[:addr] = ptr
        $instructions << instr
        ptr += 2
        i += 1
      end
      if lock_loc == 1 then
        instr[:no_reloc] = instr[:addr]
      end
    end
    #binding.pry
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

  def self.adjustla16(resolve)
    to_delete = []
    $instructions.each_with_index do |instr, idx|
      if instr[:no_reloc] then next end
      if ["lda", "addhi"].include?(instr[:command]) && instr[:adjust] then
        arg = instr[:args][1]
        if SymbolTable.issym?(arg) then
          argr = arg
          arg = SymbolTable.resolvesym(arg)
          puts "Resolved: (#{argr} into #{SymbolTable.resolvesym(argr)}\n"
          #binding.pry
        end

        adjarg = parsela16(instr[:command], arg)
        if adjarg == :nop then
          $instructions.delete_at(idx)
        end
        if resolve then
          instr[:args][1] = adjarg
          #binding.pry
        end
      end
    end
  end

  def self.parsela16(cmd, addr)
    # la16 allows the compiler to load an arbitrary length (up to 16b) address in a reg
    # here we check its length and see if we need 1 or 2 instructions

    if addr <= 511 then
      if cmd == "lda" then
        # addr is small enough to load with lda
        return addr
      else
        # commmand == addhi which is not needed
        return :nop
      end
    else
      # addr requires two instructions to load
      if cmd == "lda" then
        #binding.pry
        return (addr & 0x1ff)
      else
        return (addr & 0xfe00) >> 9
      end
    end
  end

  def self.find_instr_nr(nr)
    # for performance we could build a seperate ordered hash of linenr => addr
    # lets deal with that later
    #binding.pry
    $instructions.each do |instr|
      #binding.pry
      return instr[:addr] if instr[:instr_nr] == nr
      #puts "found: #{instr[:addr]}\n"
    end
    SymbolTable.dump()
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
    #binding.pry
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

  def self.findaddr(addr)
    $symbols.each do |nr, symbol|
      return symbol if symbol[:addr] == addr
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
    $symbols.each do |nr, symbol|
      if symbol[:addr].nil? then
        binding.pry
        Error.mexit("Encountered undefined symbol: '#{symbol[:name]}'")
      end
      puts "#{nr} => #{symbol} (#{(symbol[:addr]).to_s(16)})\n"
    end
  end
end

class Coder

  def self.build()
    #
    $instructions.each do |instr|
      #binding.pry
      if instr[:label] || instr[:byte2] then next end
      code = encode(instr)
      if code.length != 16 then
        binding.pry
        puts "Coder::build: code malformed (#{code.length} instead of 16b)\n"
        exit
      end
      instr[:code] = code
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

    # some code to allow me to use ldw, ldb, stw and stb for 2 opcodes
    if [4,5,6,7].include?(instr[:opcode]) then
      # command is ldw, ldb, stw, stb
      # find out if its idx/base or imm/bp
      if instr[:command][0] == 'l' then
        unless instr[:args][1].is_a?(Integer) && instr[:args][2] == 'bp' then
          instr[:opcode] += 20
          instr[:command] = ISA::OPCODES.key(instr[:opcode])
        end
      else
        unless instr[:args][0].is_a?(Integer) && instr[:args][1] == 'bp' then
          instr[:opcode] += 20
          instr[:command] = ISA::OPCODES.key(instr[:opcode])
        end
      end
    end

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
    #i = 0
    #binding.pry
    ISA::ARGS[instr[:command]].each do |template, argnr|
      # get the right arg from argtemplate
      #binding.pry
      #template = argtemplate.keys[i]
      arg = instr[:args][argnr] unless argnr == :x
      #i += 1
      #binding.pry
      if SymbolTable.issym?(arg) then
        argr = arg
        arg = SymbolTable.resolvesym(arg)
        puts "Resolved: #{argr} into #{SymbolTable.resolvesym(argr)}\n"

        # we are assuming that the calc belongs to the (single) symbol FIXME
        if instr[:calc] then
          argstr = arg.to_s+instr[:calc]
          arg = eval(argstr)
        end
      end

      case template
      when :imm16
        code += bitsfromint(arg, 16, false)
      when :imm10
        code += bitsfromint(arg, 10, true)
      when :imm13br
        # we need to calculate the relative offset
        # instructions are +2
        # and we need to account for the extra increment the CPU does
        #binding.pry
        if arg > instr[:addr] then
          loc = arg - (instr[:addr] + 2)
        else
          loc = arg - (instr[:addr] + 2)
        end
        if loc > 4095 || loc < -4095 then
          Error.mexit("BR: br max offset is 4095. Instruction at #{instr[:addr]} is trying to br #{loc}")
        end
        #binding.pry
        puts "BR: calculated offset #{loc}\n"
        code += bitsfromint(loc, 13, true)
      when :imm7
        code += bitsfromint(arg, 7, true)
      when :imm4
        if arg == 0 then
          Error.mexit("shift amount cannot equal zero")
        end
        code += bitsfromint(arg, 4, false)
      when :imm7u
        code += bitsfromint(arg, 7, false)
      when :immir
        if ISA::IRIMM[arg.to_i].nil? then
          puts "Encode: no encoding available for immidiate: #{arg}\n"
          exit
        end
        code += "%03b" % ISA::IRIMM[arg.to_i]
      when :reg, :reg1, :reg2
        #binding.pry if instr[:instr_nr] == 131
        code += "%03b" % ISA::REGS[arg]
      when :tgt2
        #binding.pry
        if ISA::REGS2[arg].nil? then
          Error.mexit("Encode: instruction can only target R1-R4")
        end
        code += "%02b" % ISA::REGS2[arg]
      when :xr0
        code += "000"
      when :BPreg
        if arg.upcase != "BP" then
          puts "Encode: base must be bp/r5"
          exit(1)
        end
      when :R0reg
        if arg.upcase != "R0" then
          puts "Encode: error on stw0/stb0; not R0!"
          exit(1)
        end
        code += "00"
      when :pad3
        code += "000"
      when :pad6
        code += "000000"
      when :pad9
        code += "000000000"
      when :cond
        code += "%03b" % ISA::COND[arg]
      else
        #binding.pry
        puts "Encode: cannot resolve argument: #{arg}(:#{template})\n"
        exit
      end
    end
    puts code
    return code
  end

  def self.bitsfromint(int, bitnr, sext)
    #binding.pry #if int == false
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

  def self.addhex()
    $instructions.each do |instr|
      next if instr[:byte2]
      code = instr[:code]
      b0 = code[0..7]
      b1 = code[8..15]

      h0 = b0.to_i(2)
      h1 = b1.to_i(2)

      hex = (h0.to_i == 0) ? "00" : "%02x" % h0
      hex += (h1.to_i == 0) ? "00" : "%02x" % h1
      instr[:hex] = hex
      instr[:h0] = h0
      instr[:h1] = h1
    end
  end

  def self.write(file, target)
    # FIXME: this loop is called n times, could just store result in instr_hash
    $instructions.each do |instr|
      next if instr[:byte2]

      case target
      when :hex
        Writer.hex(file, instr[:hex])
      when :simple_hex
        if $code_ptr > 0 && instr[:addr] < 10 then
          next
        end
        Writer.simplehex(file, instr[:hex])
      when :ram
        Writer.mif(file, (instr[:addr]/2), instr[:code])
      when :sim
        Writer.mif(file, instr[:addr], instr[:code])
      when :bin
        Writer.bin(file, instr[:h0], instr[:h1])
      when :list
        Writer.list(file, instr[:addr], instr[:hex], instr[:line])
      end
    end
  end

  def self.bin(output, h0, h1)
    h = [(h0<<8)|h1]
    output.write(h.pack("n"))
  end

  def self.list(output, addr, hex, line)
    # FIXME: this is a very expensive way to add labels to the listing(but safe)
    if s=SymbolTable.findaddr(addr) then
      output.write("     :          | #{s[:name]}:\n")
    end
    output.write("%04x" % addr)
    output.write(" : #{hex}     |     #{line}\n")
  end

  def self.simplehex(output, hex)
    # iverilog cannot load to address
    # so we need to output two files: 1. code and 2. data
    # since data is loaded not immediately after...
    output.write(hex)
    output.write("\n")
  end

  def self.hex(output, hex)
    if ($hex_addr % 16) > 0 then
      output.write("#{hex} ")
    else
      output.write("\n")
      output.write("%04x: " % $hex_addr)
      output.write("#{hex} ")
    end
    $hex_addr += 2
  end

  def self.mifinit(output)
    output.write("DEPTH = 8192;\n")
    output.write("WIDTH = 16;\n")
    output.write("ADDRESS_RADIX = HEX;\n")
    output.write("DATA_RADIX = BIN;\n")
    output.write("CONTENT\n")
    output.write("BEGIN\n")
    output.write("\n")
  end

  def self.mif(output, addr, code)
    output.write("%04x" % addr)
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
    "ldi"  => 0,
    "lda"  => 0,
    "br"   => 1,
    "ldw"  => 4,
    "ldb"  => 5,
    "stw"  => 6,
    "stb"  => 7,
    "stw0"  => 8,
    "stb0"  => 9,
    "add" => 10,
    "mov" => 10,
    "sub" => 11,
    "and" => 12,
    "or" => 13,
    "skip" => 14,
    "addskp.z" => 15,
    "addskp.nz" => 16,
    "addi" => 17,
    "subi" => 18,
    "andi" => 19,
    "ori" => 20,
    "addskpi.z" => 22,
    "addskpi.nz" => 23,
    "ldw.b" => 24,
    "ldb.b" => 25,
    "stw.b" => 26,
    "stb.b" => 27,
    "sext" => 28,
    "addhi" => 30,
    "push" => 31,
    "pop" => 32,
    "br.r" => 33,
    "syscall" => 34,
    "reti" => 35,
    "push.u" => 36,
    "brk" => 37,
    "lcr" => 38,
    "scr" => 39,
    "wpte" => 40,
    "lpte" => 41,
    "wptb" => 42,
    "lptb" => 43,
    "wivec" => 44,
    "shl" => 45,
    "shr" => 46,
    "shl.r" => 47,
    "shr.r" => 48,
    "defw" => :mem,
    "defb" => :mem,
    "hlt" => 63,
    "nop" => 200
  }.freeze

  # these templates reflect the order in which args should end up in the encoding
  # template => arg number from parse (e.g. order in isa)
  ARGS= {
    "ldi" => {:imm10 => 1, :reg => 0},
    "lda" => {:imm10 => 1, :reg => 0},
    "br" => {:imm13br => 0},
    "ldw" => {:imm7 => 1, :BPreg => 2, :tgt2 => 0},
    "ldb" => {:imm7 => 1, :BPreg => 2, :tgt2 => 0},
    "stw" => {:imm7 => 0, :BPreg => 1, :tgt2 => 2},
    "stb" => {:imm7 => 0, :BPreg => 1, :tgt2 => 2},
    "stw0" => {:imm7 => 0, :BPreg => 1, :R0reg => 2},
    "stb0" => {:imm7 => 0, :BPreg => 1, :R0reg => 2},
    "add" => {:reg => 1, :reg1 => 2, :reg2 => 0},
    "mov" => {:reg => 1, :xr0 => :x, :reg1 => 0},
    "sub" => {:reg =>1, :reg1 => 2, :reg2 => 0},
    "and" => {:reg =>1, :reg1 => 2, :reg2 => 0},
    "or" => {:reg =>1, :reg1 => 2, :reg2 => 0},
    "skip" => {:reg => 0, :reg1 => 1, :cond => 2},
    "addskp.z" => {:reg => 1, :reg1 => 2, :reg2 => 0},
    "addskp.nz" => {:reg => 1, :reg1 => 2, :reg2 => 0},
    "addi" => {:immir => 2, :reg =>1, :reg2 => 0},
    "andi" => {:immir => 2, :reg =>1, :reg2 => 0},
    "subi" => {:immir => 2, :reg =>1, :reg2 => 0},
    "ori" => {:immir => 2, :reg =>1, :reg2 => 0},
    "addskpi.z" => {:immir => 2, :reg => 1, :reg1 => 0},
    "addskpi.nz" => {:immir => 2, :reg => 1, :reg1 => 0},
    "ldw.b" => {:reg => 1, :reg1 => 2, :reg2 => 0},
    "ldb.b" => {:reg => 1, :reg1 => 2, :reg2 => 0},
    "stw.b" => {:reg => 0, :reg1 => 1, :reg2 => 2},
    "stb.b" => {:reg => 0, :reg1 => 1, :reg2 => 2},
    "sext" => {:reg => 0, :pad3 => :x, :reg1 => 1},
    "addhi" => {:imm7u => 1, :tgt2 => 0},
    "push" => {:pad6 => :x, :reg => 0},
    "pop" => {:pad6 => :x, :reg => 0},
    "br.r" => {:pad6 => :x, :reg => 0},
    "syscall" =>{:pad9 => :x},
    "reti" =>{:pad9 => :x},
    "push.u" => {:pad6 => :x, :reg => 0},
    "brk" =>{:pad9 => :x},
    "lcr" => {:pad6 => :x, :reg => 0},
    "scr" => {:reg => 0, :pad6 => :x},
    "wpte" => {:reg => 0, :reg1 => 1, :pad3 => :x},
    "lpte" => {:reg => 1, :pad3 => :x, :reg1 => 0},
    "wptb" => {:reg => 0, :pad6 => :x},
    "lptb" => {:pad6 => :x, :reg => 0},
    "wivec" => {:pad6 => :x, :reg => 0},
    "shl" => {:imm4 => 2, :reg => 1, :tgt2 => 0},
    "shr" => {:imm4 => 2, :reg => 1, :tgt2 => 0},
    "shl.r" => {:reg => 1, :reg1 => 2, :reg2 => 0},
    "shr.r" => {:reg => 1, :reg1 => 2, :reg2 => 0},
    "defw" => {:imm16 => 0},
    "defb" => {:imm16 => 0}
  }.freeze

  REGS= {
    "r0" => 0,
    0 => 0,
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
  }.freeze

  MEMINSTR= {
    "defw" => 1,   # define word
    "defb" => 2,   # define byte
    "defstr" => 3,    # define string
    "defs" => 4    # reserve n bytes
  }.freeze

  COND= {
   "eq" => 0,
   "ne" => 1,
   "lt" => 2,
   "lte" => 3,
   "gt" => 4,
   "gte" => 5,
   "ult" => 6,
   "ulte" => 7
  }

end

class Error
  def self.mexit(msg)
    puts "\n#{msg}\n\n"
    exit(1)
  end
end


# main
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
file_name = args["f"]
if file_name.nil? then
  Error.mexit("ERROR: no filename given\n")
end
input = File.open(file_name, "r")

#out_hex = File.open("A.hex", "w+")
out_bin = File.open("A.bin", "w+")
sim_mif = File.open("A_sim.mif", "w+")
ram_mif = File.open("A_ram.mif", "w+")
simple_hex = File.open("A_simple.hex", "w+")
listing = File.open("A.list", "w+")

$instructions = []
$list = []
$mem_instructions =[]
$labels = []
$symbols = {}
$instr_nr = 0
$symnr = 0
$code_ptr = 0
$data_ptr = 0
$last_addr = 0
$hex_addr = 0
$double_label_guard = 0


# problem is i have 1 uncertain instruction: addhi which might not be needed:

# we do this:
# 1. resolve symbols -> first addresses
# 2. process la16s and identify unneeded addhi's - we could stop at like 2x 0x3ff probably
# 3. update addresses and resolve symbols again


# ALSO: if we load .data above 0x3ff (1023) all constant loads need two instructions
# this is only ~1000 instructions so it is safe to assume that all global loads will be 2 instructions
# but branching will also be below, we could optimise this later


#SymbolTable.loadpredefined()
Parser.parse(input)
SymbolTable.idsymbols()
SymbolTable.placeinstr()
SymbolTable.placemem()
SymbolTable.resolveptrs()
SymbolTable.adjustla16(false)
SymbolTable.placeinstr()
SymbolTable.resolveptrs()
SymbolTable.adjustla16(true)


Writer.mifinit(sim_mif)
Writer.mifinit(ram_mif)
Coder.build()
Writer.addhex()
Writer.write(out_bin, :bin)
Writer.write(ram_mif, :ram)
Writer.write(sim_mif, :sim)
Writer.write(simple_hex, :simple_hex)
Writer.write(listing, :list)
Writer.mifclose(ram_mif)
Writer.mifclose(sim_mif)
SymbolTable.dump()

#puts "\n------ Instruction tokens -----------\n"
#$instructions.each do |instr|
#  puts "0x#{(instr[:addr]).to_s(16)} => #{instr}\n"
#end