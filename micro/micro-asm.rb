require 'pry'


class Parser
  def self.parse(file)
    file.readlines.each do |line|
      line.strip!
      if line.size == 0 || line[0..1]=="//" then
        puts "skip"
        # skip empty lines and comments
        next
      end
      instr = {}
      instr = parseline(line)
      $instructions[$nr] = instr
      $nr += 1
    end
  end

  def self.parseline(line)
    puts "Parsing: #{line}"
    if line.include?("//") then
      line, comment = line.split("//")
    end
    words = line.split(",")
    m = {}
    m[:opcode] = words[0].strip.to_i
    if words.length == 1 then
      m[:dummy] = 1;
      return m
    end
    m[:descr] = words[1].strip
    m[:cycle] = words[2].strip.upcase
    Parser.checkcycle(m[:cycle])
    words[3..(words.length)].each do |word|
      if word.include?("[") then
        mux, tgt = word.split("[")
        mux.strip!
        tgt.chop!
        m[mux.upcase] = tgt.upcase
        Parser.checkword(mux)
      else
        m[word.strip.upcase] = 1
        Parser.checkword(word.strip)
      end
    end
    return m
  end

  def Parser.checkword(word)
    if !(["brk", "ureg", "reti", "incr_sp", "skipstate","alu", "mar_load", "ir_load", "mdr_load", "reg_load", "ram_load", "incr_pc", "decr_sp", "be", "mdrs", "regr0s", "regr1s", "regws", "imms", "op0s", "op1s", "skipc"]).include?(word.strip.downcase) then
      puts "ERROR: unknown signal: >>#{word}<<\n"
      exit
    end
  end

  def Parser.checkcycle(cycle)
    if !(["DECODE", "READ", "EXEC"]).include?(cycle.upcase) then
      puts "ERROR: unknown cycle: #{cycle}\n"
      exit
    end
  end

end

class Coder

  REGS_MUX= {
    "REG0"   => "0000",
    "REG1"   => "0001",
    "REG2"   => "0010",
    "REG3"   => "0011",
    "REG4"   => "0100",
    "REG5"   => "0101",
    "REG6"   => "0110",
    "SP"      => "0110",
    "PC"   => "0111",
    "ARG0"   => "1000",
    "ARG1"   => "1001",
    "TGT"   => "1010",
    "TGT2"   => "1011",
    "ARG2"   => "1100",
    "CR"   => "1111"
  }

  # parameter REG0 = 3'b000, REG1 = 3'b001, REG2 = 3'b010, REG3 = 3'b011, REG4 = 3'b100, REG5 = 3'b101, REG6 = 3'b110, PC = 4'b111;
#   parameter MDRS_IMM = 2'b00, MDRS_RAM = 2'b01, MDRS_ALU = 2'b10;
#   parameter OPS_R0 = 2'b00, OPS_R1 = 2'b01, OPS_MDR = 2'b10;
#   parameter FETCH = 3'b001, FETCHM = 3'b010, DECODE = 3'b011, READ = 3'b100, READM = 3'b101, EXEC = 3'b110, EXECM = 3'b111;
#

  OPS_MUX= {
    "REGR0"   => "00",
    "REGR1"   => "01",
    "MDR"  => "10"
  }

  MDRS_MUX = {
    "IMM" => "00",
    "RAM" => "01",
    "ALU" => "10"
  }

  IMMS_MUX = {
    "IMM7" => "000",
    "IMM10" => "001",
    "IMM13" => "010",
    "IMMIR"  => "011",
    "IMM7U" => "100",
    "IMM4" => "101"
  }

  CYCLE= {
    "FETCH"  => "001",
    "DECODE" => "011",
    "READ"   => "100",
    "EXEC"   => "110"
  }

  # this includes the 3rd bit which is 'check cond'
  SKIPC_MUX= {
    "ZR"  => "001",
    "NZR" => "011",
    "COND"   => "101"
  }

  ALU= {
    "ADD"  => "000",
    "SUB" => "001",
    "AND" => "010",
    "OR"  => "011",
    "SHL"  => "100",
    "SHR"  => "101",
    "ADDHI" => "110"
  }

  SKIPSTATE= {
    "1" => "01",
    "2" => "10"
  }

  def self.encode(output, intelhex, memlist)
    ["DECODE", "READ", "EXEC"].each do |cycle|
      case cycle
      when "DECODE"
        entries = 64
        addr_offset = 64
      when "READ"
        entries = 64
        addr_offset = 128
      when "EXEC"
        entries = 64
        addr_offset = 192
      end
      $instructions.each do |line, instr|
        addr = addr_offset - entries

        if instr[:dummy] then
          output.write("0x0\n")
          writehex(addr, 0, 0, 0, 0, 0, intelhex)
          memlist.write("000000000000000000000000000000000000000000000000\n")
          entries -= 1;
          next
        end
        if instr[:cycle]!=cycle then
          puts "SKIP: cycle mismatch (#{instr[:cycle]} != #{cycle})"
          next
        end
        puts line, instr

        microcode = ""

        instr["MAR_LOAD"] ?  microcode += "1" : microcode +="0"
        instr["IR_LOAD"]  ?  microcode += "1" : microcode +="0"
        instr["MDR_LOAD"] ?  microcode += "1" : microcode +="0"
        instr["REG_LOAD"] ?  microcode += "1" : microcode +="0"
        instr["RAM_LOAD"] ?  microcode += "1" : microcode +="0"
        instr["INCR_PC"] ?  microcode += "1" : microcode +="0"
        instr["DECR_SP"] ?  microcode += "1" : microcode +="0"
        instr["BE"] ?  microcode += "1" : microcode +="0"

        instr["REGR0S"] ? microcode += REGS_MUX[instr["REGR0S"]] : microcode +="0000"
        instr["REGR1S"] ? microcode += REGS_MUX[instr["REGR1S"]] : microcode +="0000"
        instr["REGWS"] ? microcode += REGS_MUX[instr["REGWS"]] : microcode +="0000"
        instr["MDRS"] ? microcode += MDRS_MUX[instr["MDRS"]] : microcode +="00"
        instr["IMMS"] ? microcode += IMMS_MUX[instr["IMMS"]] : microcode +="000"
        instr["OP0S"] ? microcode += OPS_MUX[instr["OP0S"]] : microcode +="00"
        #puts "OP0S: #{instr["OP0S"]}"
        instr["OP1S"] ? microcode += OPS_MUX[instr["OP1S"]] : microcode +="00"

        instr["SKIPC"] ? microcode += SKIPC_MUX[instr["SKIPC"]] : microcode +="000"
        instr["ALU"] ? microcode += ALU[instr["ALU"]] : microcode +="000"
        instr["SKIPSTATE"] ? microcode += SKIPSTATE[instr["SKIPSTATE"]] : microcode +="00"
        instr["INCR_SP"] ?  microcode += "1" : microcode +="0"
        instr["TRAP"] ?  microcode += "1" : microcode +="0"
        instr["RETI"] ?  microcode += "1" : microcode +="0"
        instr["UREG"] ?  microcode += "1" : microcode +="0"
        instr["BRK"] ?  microcode += "1" : microcode +="0"


        microcode +="000000" # PADDING

        if microcode.length != 48
          puts "Invalid microword length (#{microcode.length})\n"
          exit(1)
        end

        puts microcode
        b0 = microcode[0..7]
        b1 = microcode[8..15]
        b2 = microcode[16..23]
        b3 = microcode[24..31]
        b4 = microcode[32..39]
        b5 = microcode[40..47]
        #puts b0


        h0 = b0.to_i(2)
        h1 = b1.to_i(2)
        h2 = b2.to_i(2)
        h3 = b3.to_i(2)
        h4 = b4.to_i(2)
        h5 = b5.to_i(2)


        hex = "0x"
        hex += (h0.to_i == 0) ? "00" : "%02x" % h0
        hex += (h1.to_i == 0) ? "00" : "%02x" % h1
        hex += " 0x"
        hex += (h2.to_i == 0) ? "00" : "%02x" % h2
        hex += (h3.to_i == 0) ? "00" : "%02x" % h3
        hex += " 0x"
        hex += (h4.to_i == 0) ? "00" : "%02x" % h4
        hex += (h5.to_i == 0) ? "00" : "%02x" % h5
        puts hex
        #if addr = 149 then binding.pry end
        # write the sim init file
        output.write(hex)
        output.write("\n")
        Coder.writehex(addr, h0, h1, h2, h3, h4, intelhex)
        memlist.write("#{microcode}\n")
        entries -= 1;
      end
      while(entries>0)
        addr = addr_offset - entries
        output.write("0x0\n")
        writehex(addr, 0, 0, 0, 0, 0, intelhex)
        memlist.write("000000000000000000000000000000000000000000000000\n")
        entries -= 1
      end
    end
  end

  def self.writehex(addr, d0,d1,d2,d3, d4, intelhex)
    addrstr = "%04x" % addr
    lsbsum = (04 + addr + d0 + d1 + d2 + d3 + d4) & 0xff
    checksum = ( -lsbsum & 0xff)
    #puts "lsbsum: #{lsbsum}"
    #puts "chk: #{checksum}"

    intelhex.write(":04#{addrstr}00")
    intelhex.write( "%02x" % d0)
    intelhex.write( "%02x" % d1)
    intelhex.write( "%02x" % d2)
    intelhex.write( "%02x" % d3)
    intelhex.write( "%04x" % d4)
    intelhex.write("%02x\n" % checksum)
  end


end
# main
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
file_name = args["f"]
file = File.open(file_name, "r")
output = File.open("micro.hexish", "w+")
intelhex = File.open("micro.hex", "w+")
memlist = File.open("micro.list", "w+")
$instructions = {}
$nr = 0;

puts "Opening: #{file_name}\n"
Parser.parse(file)
Coder.encode(output, intelhex, memlist)
# SymbolTable.resolve($symbols)
# Coder.encode(output)