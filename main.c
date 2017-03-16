//C hello world example
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

#include "defs.h"
#include "arch.h"
#include "opcodes.h"
#include "types.h"


struct {
  int instr;
  enum icycle icycle;
  enum phase phase;
} clk;

int vcycle;     //virtual cycle to allow signals to settle

uint64_t micro[256];
uint64_t microinstr;

enum signalstate csig[16] = {0};
uint16_t bsig[20] = {0};
uint16_t ram[1024] = {0};
uint16_t regfile[16] = {0};
uint16_t sysreg[3] = {0};
uint16_t regsel[3] = {0};
ushort bussel[10] = {0};
// ushort regselsrcmux[3] = {0};

ushort program[64] = {0};
ushort data[64] = {0};

int maxinstr = 100;
int sigupd;
char ALUopc[4];

ushort instr;
ushort codetype;
ushort opcode;
ushort opc2;
ushort opc3;
ushort opc4;
ushort imm7u;
ushort imm7;
ushort imm10;
ushort imm13;
ushort imm3;
ushort arg0;
ushort immIR;
ushort arg1;
ushort imms;
ushort nextstate;
ushort skipcycle;

ushort ALUresult;
ushort tgt;
ushort tgt2;

ushort regr0s_temp;
ushort regr1s_temp;
ushort regws_temp;

int stdoutBackupFd;
FILE *nullOut;
int vflag;

int main(int argc,char *argv[])
{
  vflag = 0;
  parseopts(argc, argv);
  init();
  stdoutBackupFd = dup(1);

  // Main execution loop
  while(clk.instr <= maxinstr) {
    for(clk.icycle = FETCH; clk.icycle <= EXECUTEM; clk.icycle++) {
      if(skipcycle > 0) {
        skipcycle--;
        continue;
      }
      clearsig();
      for(clk.phase=clk_RE; clk.phase<= clk_FE; clk.phase++){
        readram();
        hideconsole(clk.icycle, vflag);
        printf("------------------------------------------------------\n");
        printf("cycle: %d.%s, phase: %d, PC: %x, SP: %x, MAR: %x(%x), MDR: %x\n", clk.instr, ICYCLE_STR[clk.icycle], clk.phase, regfile[PC], regfile[SP], sysreg[MAR], bsig[RAMout], sysreg[MDR]);

        // signal generation phase
        sigupd=1;
        vcycle=0;
        while(sigupd==1) {
          if(vcycle > 15) {
            printf("ERROR: signal does not stabilize!\n");
            exit(1);
          }
          sigupd = 0;
          vcycle++;
          // if(clk.icycle == FETCH) {
//             fetchsigs();
//           } else {
          decodesigs();

          ALU();
          resolvemux();
          printf("\n");
        }
        printf("Stable after %d vcycles.\n", vcycle);
        printf("regfile: r0:%s, r1:%s, w:%s\n", REGFILE_STR[regsel[REGR0S]], REGFILE_STR[regsel[REGR1S]],REGFILE_STR[regsel[REGWS]]);
        printf("args: 0:%x, 1:%x, tgt:%x\n", arg0, arg1, tgt);
        printf("ALU: 0:%s(%x) 1:%s(%x) func:%s out:%x\n", BSIG_STR[bussel[OP0S]], bsig[OP0], BSIG_STR[bussel[OP1S]], bsig[OP1], ALUopc, bsig[ALUout]);
        printf("STACK: ");
        int sdump;
        for(sdump=100; sdump>74; sdump -=2) {
          printf("%x ", readramdump(sdump));
        }
        printf("\n");
      // Latch pass - single pass!
        restoreconsole();
      latch(clk.phase);
      if(sysreg[IR] == 0xfe00) {
        printf("HALT: encountered halt instruction.\n\n");
        goto halt;
      }
      }
    }
    clk.instr++;
  }
halt:
  dump();
  exit(1);
}

void dump() {
  // Dump lower part of RAM and regs
  printf("-------RAM---------DATA--------\n");
  int i;
  for(i=100; i>48; i-=2){
    printf("0x%03x: %02x         0x%03x: %02x\n", i, readramdump(i), (100-i), readramdump(100-i));
  }
  printf("----------------------------REGISTERS-----------------------\n");
  for(i=0; i<8; i++){
    printf("R%d: %04x\n", i, regfile[i]);
  }
  printf("----------------------------SYSREGS-----------------------\n");
  for(i=0; i<3; i++){
    printf("%s: %04x\n", SYSREG_STR[i], sysreg[i]);
  }
}

void
init(void) {

  bsig[PC] = 0;

  // load microcode
  loadmicrocode();

  // load program from bios.hex
  loadbios();


  printf("Init done..\n");
}

void
decodesigs() {

  char *instr_b;
  char codetype_b;
  char opcodeshort_b[2];
  char opcode_b[6];
  char *micro_b;
  char *micro_b64;

  char opc2_b[3];
  //char opc3_b[2];
  //char opc4_b[3];
  char imm7u_b[7];
  char imm7_b[7];
  char imm10_b[10];
  char imm13_b[13];
  char imm3_b[3];
  char arg0_b[3];
  char arg1_b[3];
  char tgt_b[3];
  char tgt2_b[2];

  int loadpos, loadneg;

  int skipcond = 0;
  int skiptype;

  // parse instruction
  instr_b = dec2bin(sysreg[IR], 16);

  if(sysreg[IR] == 0 && clk.icycle != FETCH && clk.icycle !=FETCHM ) {
    printf("\nHALT: no instruction in IR\n");
    dump();
    exit(1);
  }

  if (vcycle==1) {
    //printf("IR: %x ", sysreg[IR]);
    if (clk.icycle < 3 || (clk.icycle == 3 && clk.phase == 0)) {
      printf("IR: DECODING (%x) ", sysreg[IR]);
    } else {
      printf("IR: %s (%x) - ", OPCODES_STRING[opcode], sysreg[IR]);
      printf("(%s), ", instr_b);
    }
  }


  codetype_b = instr_b[0];
  //printf("i/r: %c", ir_b);
  codetype = codetype_b - '0';


  memcpy(opcodeshort_b, instr_b+1, 2);
  memcpy(opcode_b, instr_b+1, 6);

  // parse arguments - immediates
  memcpy(imm7u_b, instr_b+7, 7);
  imm7u= bin2dec(imm7u_b, 7);
  //printf("imm6: %x ", imm6);

  memcpy(imm7_b, instr_b+7, 7);
  imm7= sbin2dec(imm7_b, 7);
  //printf("imm7: %s(%d) ", imm7_b, imm7);

  memcpy(imm10_b, instr_b+3, 10);
  imm10= sbin2dec(imm10_b, 10);
  //printf("imm10: %s(%d) ", imm10_b, imm10);

  memcpy(imm13_b, instr_b+3, 13);
  imm13 = sbin2dec(imm13_b, 13);
  //printf("imm13: %d", imm13);

  memcpy(imm3_b, instr_b+7, 3);
  imm3 = bin3_to_dec(imm3_b);

  // parse arguments - operands
  memcpy(arg0_b, instr_b+7, 3);
  arg0 = bin3_to_dec(arg0_b);
  immIR = IRtable[arg0];

  memcpy(arg1_b, instr_b+10, 3);
  arg1 = bin3_to_dec(arg1_b);
  //printf(">>%s<<", arg1_b);

  memcpy(tgt_b, instr_b+13, 3);
  tgt = bin3_to_dec(tgt_b);

  memcpy(tgt2_b, instr_b+14, 2);
  tgt2 = bin2dec(tgt2_b, 2) + 1;
  //printf("tgt2: %s(%d)", tgt2_b,tgt2);


  // is this a micro op (first bit)?
  if(!codetype) {
    opcode = bin2dec(opcodeshort_b, 2);
  } else {
    opcode = bin2dec(opcode_b, 6);
  }
  // Micro op code
  // calculate microcode idx
  int idx;

  //printf("icycle: %d", clk.icycle);
  switch(clk.icycle) {
  case FETCH:
    //update_csig(INCR_PC, HI);
    idx = 2;
    break;
  case FETCHM:
    idx = 2;
    break;
  case DECODE:
  case DECODEM:
    idx = opcode;
    break;
  case READ:
  case READM:
    idx = 64 + opcode;
    break;
  case EXECUTE:
  case EXECUTEM:
    idx = 128 + opcode;
    break;
  }

  // fetch microcode str
  microinstr = micro[idx];

  micro_b = (char*)malloc(40+1);

  micro_b64 = dec2bin(microinstr, 64);
  memcpy(micro_b, &micro_b64[0], 40);
  micro_b[40] = '\0';

  if (vcycle==1) {
    printf("Micro(%d): %s\n", idx, micro_b);
  }
  // adjustments to deal with RAM latency
  if (clk.icycle % 2) {// odd
    loadpos = 1;
    loadneg = 0;
  } else {
    loadpos = 0;
    loadneg = 1;
  }
  //printf("icycle: %d loadneg: %d", clk.icycle, loadneg);
  // generate signals
  if (micro_b[0] == '1' && loadpos) { update_csig(MAR_LOAD, HI);}
  if (micro_b[1] == '1' && loadneg) { update_csig(IR_LOAD, HI);}
  if (micro_b[2] == '1' && loadpos) { update_csig(MDR_LOAD, HI);}
  if (micro_b[3] == '1' && loadneg) { update_csig(REG_LOAD, HI);}
  if (micro_b[4] == '1' && loadneg) { update_csig(RAM_LOAD, HI);}
  if (micro_b[5] == '1' && loadneg) { update_csig(INCR_PC, HI);}
  if (micro_b[6] == '1' && loadneg) { update_csig(DECR_SP, HI);}
  if (micro_b[7] == '1' && loadneg) { update_csig(BE, HI);}
  if (micro_b[37] == '1' && loadneg) { update_csig(INCR_SP, HI);}

  // parse muxes
  char regr0s_b[4];
  char regr1s_b[4];
  char regws_b[4];
  char mdrs_b[2];
  char imms_b[3];
  char op0s_b[2];
  char op1s_b[2];
  char skipc_b[2];
  char ALUfunc_b[3];
  char nextstate_b[2];

  memcpy(regr0s_b, micro_b+8, 4);
  update_regsel(REGR0S, bin2dec(regr0s_b, 4));
  // printf("regr0s: %s(%d)<<", regr0s_b, bin2dec(regr0s_b, 4));

  memcpy(regr1s_b, micro_b+12, 4);
  update_regsel(REGR1S, bin2dec(regr1s_b, 4));

  memcpy(regws_b, micro_b+16, 4);
  update_regsel(REGWS, bin2dec(regws_b, 4));

  memcpy(mdrs_b, micro_b+20, 2);
  update_bussel(MDRS, bin2dec(mdrs_b, 2));

  memcpy(op0s_b, micro_b+25, 2);
  update_bussel(OP0S, bin2dec(op0s_b, 2));
  //int temp = bin2dec(op0s_b, 2);
  //printf("op0s: %s(%d)<<", op0s_b, temp);

  memcpy(op1s_b, micro_b+27, 2);
  update_bussel(OP1S, bin2dec(op1s_b, 2));

  memcpy(imms_b, micro_b+22, 3);
  update_bussel(IMMS, bin2dec(imms_b, 3));
	//printf("%s(%d)", imms_b, bussel[IMMS]);

  memcpy(ALUfunc_b, micro_b+32, 3);
  update_bussel(ALUS, bin2dec(ALUfunc_b, 3));

  nextstate = -1;
  memcpy(nextstate_b, micro_b+35, 2);
  nextstate = bin2dec(nextstate_b, 2);
  //printf(" next: %d", nextstate);

  // IRimm MUX - which bits from IR should feed IRimm
  //printf("bussel-imms: %d", bussel[imms]);
  switch(bussel[IMMS]) {
  case 0:
    update_bsig(IRimm, &imm7);
    break;
  case 1:
    update_bsig(IRimm, &imm10);
    //printf("Irimm value: %d", imm10);
    break;
  case 2:
    update_bsig(IRimm, &imm13);
    //printf("Irimm value: %d", imm10);
    break;
  case 3:
    update_bsig(IRimm, &immIR);
    //printf("Irimm value: %d", imm10);
    break;
  case 4:
    update_bsig(IRimm, &imm7u);
    printf("Irimm value: %d", imm10);
    break;
  }

  // parse the branch conditions
  if(micro_b[31]=='1') {
    // skip condition to check
    memcpy(skipc_b, micro_b+29, 2);
    skiptype = bin2dec(skipc_b,2);
    switch(skiptype){
      case 0:
        // ALU == zero
        if(bsig[ALUout]==0) { goto skip;}
        break;
      case 1:
        // ALU != zero
        if(bsig[ALUout]!=0) { goto skip;}
        break;

    }
    update_csig(SKIP, LO);
    return;
skip:
    if(loadneg) {
      update_csig(SKIP, HI);
    }
  }

  free(micro_b);
}

void
resolvemux(void) {
  // Connect the muxed busses
  // and some simulator monkey patching :(

  readram();

  //printf("arg0: %d ", arg0);
  //printf("arg1: %d ", arg1);

  // grab selector from instruction
  switch(regsel[REGR0S]) {
    case ARG0:
      regr0s_temp = arg0;
      break;
    case ARG1:
      regr0s_temp  = arg1;
      break;
    case TGT:
      regr0s_temp  = tgt;
      break;
    case TGT2:
      regr0s_temp  = tgt2;
      break;
    default:
      regr0s_temp = regsel[REGR0S];
  }

  // grab selector from instruction
  switch(regsel[REGR1S]) {
    case ARG0:
      regr1s_temp  = arg0;
      break;
    case ARG1:
      regr1s_temp = arg1;
      break;
    case TGT:
      regr1s_temp = tgt;
      break;
    case TGT2:
      regr1s_temp = tgt2;
      break;
    default:
      regr1s_temp = regsel[REGR1S];
  }

  // grab selector from instruction
  switch(regsel[REGWS]) {
    case ARG0:
      regws_temp = arg0;
      break;
    case ARG1:
      regws_temp = arg1;
      break;
    case TGT:
      regws_temp = tgt;
      break;
    case TGT2:
      regws_temp = tgt2;
      break;
    default:
      regws_temp = regsel[REGWS];
  }

  update_bsig(REGR0, &regfile[regr0s_temp]);
  update_bsig(REGR1, &regfile[regr1s_temp]);

  //printf("OP: %d", bussel[OP0S]);

  update_bsig(OP0, &bsig[bussel[OP0S]]);
  update_bsig(OP1, &bsig[bussel[OP1S]]);

  update_bsig(MDRin, &bsig[bussel[MDRS]+3]); // translate to keep handling of busses on simulator simple
  //printf("MDRin being updated: bsig[%d]", bussel[MDRS]+3);
  update_bsig(MDRout, &sysreg[MDR]);  // programming crutch: MDRout == MDR
}

void
latch(enum phase clk_phase) {

  // RISING EDGE LATCHES
  if(clk_phase == clk_RE) {
    if(csig[SKIP]==HI) {
      regfile[PC] +=2;
      printf("PC++ (SKIP)\n");
    }
    if(csig[RAM_LOAD]==HI) {
      writeram();
    }
  }

  // FALLING EDGE LATCHES
  if(clk_phase == clk_FE) {
    if(csig[REG_LOAD]==HI) {
      writeregfile();
    }
    if(csig[INCR_PC]==HI) {
      regfile[PC]+=2; // PC acts as counter
      printf("PC++\n");
    }
    if(csig[DECR_SP]==HI) {
      regfile[SP]-=2; // SP acts as counter
      printf("SP--\n");
    }
    if(csig[INCR_SP]==HI) {
      regfile[SP]+=2; // SP acts as counter
      printf("SP++\n");
    }
    if(csig[IR_LOAD]==HI) {
      sysreg[IR] = bsig[RAMout];
      printf("IR <- %x\n", sysreg[IR]);
    }
    if(csig[MAR_LOAD]==HI) {
      sysreg[MAR] = bsig[ALUout];
      printf("MAR <- %x\n", sysreg[MAR]);
    }
    if(csig[MDR_LOAD]==HI) {
      sysreg[MDR] = bsig[MDRin];
      printf("MDR <- %04x\n", sysreg[MDR]);
      bsig[MDRout] = sysreg[MDR]; // programming crutch
    }
    if(clk.icycle == DECODEM ) { // never going to skip from anything else than decode
      if(nextstate > 0) {
        skipcycle = 2 * nextstate;
      }
    }
  }
}

void
ALU(void) {
  ushort result;
  printf("ALUS(%d) ", bussel[ALUS]);
  switch(bussel[ALUS]) {
  case 0:
    result = bsig[OP0] + bsig[OP1];
    break;
  case 1:
    result = bsig[OP1] - bsig[OP0];
    break;
  }
  //printf("ALU result: %d", result);
  update_bsig(ALUout, &result);
}

void
chkskip(void){
// condS  cond  0  neg  pos
// SLTEQ    3   1  1    0
// EQ       0   1  0    0
// SGTEQ    5   1  0    1
// NEQ      1   0  1    1
// SLT      2   0  1    0
// SGT      4   0  0    1
// LT       6   0  1    0 (unsigned)
// LTEQ     7   1  1    0 (unsigned)
  char *aluout = dec2bin(bsig[ALUout], 16);

  //printf("COND(%d) ALUout(%s) ", bussel[COND], aluout);
  // if its 0
  if(bsig[ALUout] == 0 && bussel[COND] == 3) { goto skip; }
  if(bsig[ALUout] == 0 && bussel[COND] == 0) { goto skip; }
  if(bsig[ALUout] == 0 && bussel[COND] == 5) { goto skip; }
  // if its neg - in HDL need to check most significant bit[0]
  if(aluout[0] == '1' && bussel[COND] == 3) { goto skip; }
  if(aluout[0] == '1' && bussel[COND] == 1) { goto skip; }
  if(aluout[0] == '1' && bussel[COND] == 2) { goto skip; }
  // if its pos - in HDL need to check most significant bit[0]
  if(aluout[0] == '0' && bussel[COND] == 5) { goto skip; }
  if(aluout[0] == '0' && bussel[COND] == 1) { goto skip; }
  if(aluout[0] == '0' && bussel[COND] == 4) { goto skip; }
  // unsigned conditions (NOT 100% sure this is how it should work...)
  if(bsig[ALUout] < 0 && bussel[COND] == 6) { goto skip; }
  if(bsig[ALUout] < 0 && bussel[COND] == 7) { goto skip; }
  if(bsig[ALUout] == 0 && bussel[COND] == 7) { goto skip; }
  update_csig(SKIP, LO);
  return;
skip:
  update_csig(SKIP, HI);
}


void
readram() {
  int ramaddr;

  ramaddr = sysreg[MAR] >> 1;
  if(bussel[BYTE_ENABLE] == 1) {
    if(sysreg[MAR] % 2) {
      // MAR is odd thus we need to return the low byte
      bsig[RAMout] = ram[ramaddr] & 0xff;
    } else {
      // MAR is even thus we need to return the high byte
      bsig[RAMout] = ram[ramaddr] >> 8;
    }
  } else {
    bsig[RAMout] = ram[ramaddr];
  }
}

void
writeram() {
  int ramaddr, MDRlowb, tmp;

  ramaddr = sysreg[MAR] >> 1;
  if(bussel[BYTE_ENABLE] == 1) {
    MDRlowb = bsig[MDRout] & 0x00ff; // low byte from MDR
    if(sysreg[MAR] % 2) {
      // MAR is odd thus we need to write the low byte
      tmp = ram[ramaddr] & 0xff00; // clear the low byte
      ram[ramaddr] = tmp | MDRlowb;
      printf("RAM[%xL] <- %x\n", ramaddr*2, MDRlowb);
    } else {
      // MAR is even thus we need to write the high byte
      tmp = ram[ramaddr] & 0xff;
      ram[ramaddr] = tmp | MDRlowb << 8;
      printf("RAM[%xH] <- %x\n", ramaddr*2, MDRlowb);
    }
  } else {
    ram[ramaddr] = bsig[MDRout];
    printf("RAM[%x] <- %x\n", ramaddr*2, bsig[MDRout]);
  }
}


void
writeregfile(void) {
  //printf("writeregfile: regws_temp: %d", regws_temp);
  if(regws_temp == REG0) {
    printf("\nwriteregfile: error trying to write to REG0!!\n");
    dump();
    exit(1);
  }
  if(csig[BE]) {
    regfile[regws_temp] = regfile[regws_temp] | bsig[ALUout] << 9;
    printf("%s <- %x\n", REGFILE_STR[regws_temp], (bsig[ALUout] << 9));
  } else {
    regfile[regws_temp] = bsig[ALUout];
    printf("%s <- %x\n", REGFILE_STR[regws_temp], bsig[ALUout]);
  }
}


// SIMULATOR ROUTINES
//

int
readramdump(int addr) {
  int ramaddr;

  ramaddr = addr >> 1;
  return ram[ramaddr];
}

void update_csig(enum csig signame, enum signalstate state) {
  if (csig[signame] != state) {
    sigupd = 1;
    printf("%s ", CSIG_STR[signame]);
  }
  csig[signame] = state;
}

void update_bsig(int signame, ushort *value) {
  //printf("signame: %d", signame);
  if (bsig[signame] != (*value & 0xffff)) {
    sigupd = 1;
    printf("%s(%d) ", BSIG_STR[signame], *value);
  }
  bsig[signame] = *value & 0xffff;
}

void update_bussel(enum bussel signame, ushort value) {
  //printf("signame: %d", signame);
  if (bussel[signame] != value) {
    sigupd = 1;
    switch(signame){
    case 0:
    case 1:
      printf("%s(%s) ", BUSSEL_STR[signame], BSIG_STR[value]);
      break;
    case 2:
      printf("%s(%s) ", BUSSEL_STR[signame], BSIG_STR[value+3]);
      break;
    case 3:
      printf("%s(%s) ", BUSSEL_STR[signame], ALUFUNC_STR[value]);
      break;
    case 4:
      printf("%s(%s) ", BUSSEL_STR[signame], COND_STR[value]);
      break;
    case 5:
      printf("%s(%x) ", BUSSEL_STR[signame], value);
      break;
    case IMMS:
      printf("%s(%s) ", BUSSEL_STR[signame], IMMSEL_STR[value]);
      break;
    //if (signame == AIN)
      //printf("v: %x", *value);
    }
  }
  bussel[signame] = value;
}

void update_regsel(enum regsel signame, ushort value) {
  //printf("OLD: %d", regsel[signame]);
  if (regsel[signame] != value) {
    sigupd = 1;
    printf("%s(%s) ", REGSEL_STR[signame], REGFILE_STR[value]);
  }
  regsel[signame] = value;
}

//
void
clearsig(){
  memset(csig, 0, sizeof(csig));
  memset(bussel, 0, sizeof(bussel));
  memset(regsel, 0, sizeof(regsel));
}

int
grabmicrocode(addr){
  return 0xc4e00000;
}

void
loadmicrocode(void)
{
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    uint64_t microcode;
    int i = 0;
    char * pch;

    fp = fopen("micro/micro.hexish", "r");
    if (fp == NULL) {
      printf("FAILURE opening micro/micro.hexish\n");
      exit(EXIT_FAILURE);
    }
    while ((read = getline(&line, &len, fp)) != -1) {
      //printf("Retrieved line of length %zu :\n", read);
      //printf("%s", line);

      //printf ("Splitting string \"%s\" into tokens:\n",str);
      pch = strtok (line," ");
      int c = 0;
      microcode = 0;
      while (pch != NULL)
      {
        c++;
        uint64_t number = (int)strtol(pch, NULL, 0);
        switch(c){
          case 1:
            microcode = number << 48;
            //printf("%llx\n", microcode);
            break;
          case 2:
            microcode = microcode | (number << 32);
            break;
          case 3:
            microcode = microcode | (number << 16);
            break;
        }

        pch = strtok (NULL, " ");
      }
      //printf ("%llx\n",microcode);
      //printf ("%s\n",dec2bin(microcode, 64));
      micro[i] = microcode;
      i++;
    }
    if (vflag == 1) {
      for(i=0;i<192;i++) {
        printf("micro[%d]: %s\n", i, dec2bin(micro[i], 64));
      }
    }
    fclose(fp);
    if (line)
        free(line);
}

void
loadbios(void)
{
  FILE * fp;
  char * line = NULL;
  size_t len = 0;
  ssize_t read;
	uint16_t addr;
	uint16_t opcode;
	char opcode_b[16]; //including ;
  char * pch, * colon;

  fp = fopen("asm/A.mif", "r");
  if (fp == NULL) {
    printf("FAILURE opening asm/A.mif\n");
    exit(EXIT_FAILURE);
  }
  while ((read = getline(&line, &len, fp)) != -1) {
    //printf("Retrieved line of length %zu :\n", read);
    //printf("%s", line);

    //printf ("Splitting string \"%s\" into tokens:\n",str);
    colon = strchr(line, ':');
		if (!colon) {
			printf("Found colon - skip: %x", (int)colon);
			continue;
		}
			//}
		pch = strtok (line," ");

		int c = 0;
    addr = 0;
		opcode = 0;


    while (pch != NULL)
    {
      c++;
      switch(c){
        case 1:
					// address
					addr = (int)strtol(pch, NULL, 16);
          //printf("%llx\n", microcode);
          break;
        case 2:
				  // colon ignore
        case 3:
					// opcode in binary + ;
				memcpy(opcode_b, pch, 16); // cut off ;
					opcode = bin2dec(opcode_b, 16);
          break;
      }

      pch = strtok (NULL, " ");
    }

    ram[(addr >> 1)] = opcode;
	  if (vflag == 1){
	  	printf("%x: %x\n", addr, opcode);
	  }
	}
  fclose(fp);
  if (line)
    free(line);
}





void
loadbiosold(void)
{
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    ushort instr, num;
    int i = 0;
    char * pch;

    fp = fopen("asm/A.hex", "r");
    if (fp == NULL) {
      printf("FAILURE opening asm/a.hex\n");
      exit(EXIT_FAILURE);
    }
    while ((read = getline(&line, &len, fp)) != -1) {
      //printf("Retrieved line of length %zu :\n", read);
      //printf("%s", line);

      //printf ("Splitting string \"%s\" into tokens:\n",str);
      instr = (ushort)strtol(line, NULL, 16);
      ram[i] = instr;
      if (vflag == 1){
        printf("%x: %x\n", i, instr);
      }
      i++;
    }
    // for(i=0;i<192;i++) {
    //   printf("micro[%d]: %s\n", i, dec2bin(micro[i], 64));
    // }

    fclose(fp);
    if (line)
        free(line);
}



void hideconsole(int ic, int vflag) {
  if ((ic % 2 && ic != 1) || vflag == 1) {
    // icycle = odd and not fetch, is main phase, thus show output
    fflush(stdout);
    fclose(nullOut);
    // Restore stdout
    dup2(stdoutBackupFd, 1);
  } else {
    // icycle = even, is M phase, thus supress output
    fflush(stdout);
    nullOut = fopen("/dev/null", "w");
    dup2(fileno(nullOut), 1);
  }
}

void restoreconsole(void) {
    fflush(stdout);
    fclose(nullOut);
    // Restore stdout
    dup2(stdoutBackupFd, 1);
}

int parseopts(int argc,char *argv[]) {
  opterr = 0;
  int c;
  while ((c = getopt(argc, argv, "vf:t:")) != -1) {
    printf("opt: %d\n", c);
    switch (c) {
    case 'v':
      printf("vflag!");
      vflag = 1;
      break;
    // case 'f':
//         filename = optarg;
//         break;
    case 't':
      maxinstr = atoi(optarg);
      break;
    case '?':
      if (optopt == 'f' || optopt == 't')
        fprintf (stderr, "Option -%c requires an argument.\n", optopt);
      else
        fprintf (stderr,
                 "Unknown option character `\\x%x'.\n",
                 optopt);
      return 1;
    default:
      printf("Aborting..");
      abort();
    }
  }
  return 0;
}