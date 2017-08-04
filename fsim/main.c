// DME functional simulator (?)
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <unistd.h>
#include  <signal.h>
#include <fcntl.h>

#include "../arch2.h"
#include "../types.h"
#include "../opcodes.h"
#include "defs.h"

uint16_t ram[32768] = {0}; // 64kb
uint16_t uregfile[16] = {0};
uint16_t sregfile[16] = {0};
uint16_t pagetable[512] = {0};
uint16_t ucr, scr, ptb, ivec, trapnr;

short instr;
struct instr_t cinstr;
int bank = 1;

int asm_dir;
int os_dir;
int pauze;
int vflag;
int sflag;
int tick;
int tx_delay;

// file system simulation
int fsfd;
char rfifo[512];
uint rfifo_p;
uint sddata;

int
main(int argc,char *argv[]) {
	ushort ir;
	uint16_t imm, addr, arg2, result;
	int16_t simm, sresult;
	uint32_t result32;
	int justsetcarry;
	int x,y;
	uint16_t byte, mask;

	ucr = 0x8;
	scr = 0x1;
	ptb =0xdead;

	parseopts(argc, argv);
  //init();
	loadbios();

	// open File System image
  fsfd = open("../../dme_os/mkfs/fs.img", O_RDWR);
  if(fsfd < 0){
    perror("fs.img");
    exit(1);
  }

	signal(SIGINT, INThandler);
	ir = -1;
	tick = 0;
	printf("\n\n");
	while(readreg(PC) < 0xf800 && ir != 0 ) {
		tick++;
		pauze = 1;
		if (sflag)
			getinput();
		traps();
		ir = readram(readreg(PC), 0, 0);
		incr_pc();

		printd("\n%x : ", readreg(PC)-2);
		decode(ir, &cinstr);
		justsetcarry = 0;


		switch(cinstr.opcode){
		case 0: //ldi reg, s10
			simm = (int16_t)((cinstr.full & 0x1ff8) << 3) >> 6;
			writereg(cinstr.tgt, simm);
			printd("R%d <- %x\n", cinstr.tgt, simm);
			break;
		case 1: // br imm13
			simm = (int16_t)((cinstr.full & 0x1fff) << 3) >> 3;
			printd("imm: %x", simm);
			writereg(PC, (readreg(PC)+simm));
			printd(" PC <- %x\n", readreg(PC));
			break;
		case 4: // ldw tgt, sw7(R5)
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = readreg(BP) + simm;
			writereg(cinstr.tgt2, readram(addr, 0, 0));
			printd("r%d <- %x(%x) ", cinstr.tgt2, readreg(cinstr.tgt2), addr);
			break;
		case 5: // ldb sb7(r5),tgt
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = readreg(BP) + simm;
			writereg(cinstr.tgt2, readram(addr, 1, 0));
			break;
		case 6: // stw sw7(r5), src
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = readreg(BP) + simm;
			writeram(addr, readreg(cinstr.tgt2), 0);
			break;
		case 7: // stb sb7(r5),tgt
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = readreg(BP) + simm;
			writeram(addr, readreg(cinstr.tgt2), 1);
			break;
		case 8: // stw0 sw7(r5), src
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = readreg(BP) + simm;
			writeram(addr, 0, 0);
			break;
		case 9: // stb0 sw7(r5), src
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = readreg(BP) + simm;
			writeram(addr, 0, 1);
			break;
		case 10: // add op1,op2,res
			x = readreg(cinstr.arg0);
			y = readreg(cinstr.arg1);
			writereg(cinstr.tgt, x+y);
			printd("%x + %x = >>%x (%x)", x, y, readreg(cinstr.tgt), x+y);
			result32 = readreg(cinstr.arg0) + readreg(cinstr.arg1);
			if (result32 > 0xffff) {
				writecr((readcr(0) | 0x2),0);
				printd("set carry ");
				justsetcarry = 1;
			}
			break;
		case 11: // sub op1,op2,res
			writereg(cinstr.tgt, (readreg(cinstr.arg0) - readreg(cinstr.arg1)));
			result32 = readreg(cinstr.arg0) - readreg(cinstr.arg1);
			if (result32 > 0xffff) {
				writecr((readcr(0) | 0x2),0);
				printd("set carry ");
				justsetcarry = 1;
			}
			break;
		case 12: // add op1,op2,res
			writereg(cinstr.tgt, (readreg(cinstr.arg0) & readreg(cinstr.arg1)));
			break;
		case 13: // add op1,op2,res
			writereg(cinstr.tgt, (readreg(cinstr.arg0) | readreg(cinstr.arg1)));
			break;
		case 14: // skip.c op1,op2, cond
			// condS  cond  0  neg  pos
			// SLTEQ    3   1  1    0
			// EQ       0   1  0    0
			// SGTEQ    5   1  0    1
			// NEQ      1   0  1    1
			// SLT      2   0  1    0
			// SGT      4   0  0    1
			// LT       6   0  1    0 (unsigned)
			// LTEQ     7   1  1    0 (unsigned)
			result = readreg(cinstr.arg0) - readreg(cinstr.arg1);
			result32 = readreg(cinstr.arg0) - readreg(cinstr.arg1);
			printd("%x - %x = r16: %x, 32: %x, s16: %x", readreg(cinstr.arg0), readreg(cinstr.arg1), result, result32, sresult);
			/* OLD
			if (result != result32) {
				writecr(readcr() | 0x2);
				printd("set carry ");
				justsetcarry = 1;
			}
			*/
			if ((unsigned)readreg(cinstr.arg1) > (unsigned)readreg(cinstr.arg0)) {
				writecr((readcr(0) | 0x2),0);
				printd("set carry ");
				justsetcarry = 1;
			}
			if (result == 0 && cinstr.tgt == 3) { incr_pc(); }
			else if (result == 0 && cinstr.tgt == 0) { incr_pc(); }
			else if (result == 0 && cinstr.tgt == 5) { incr_pc(); }
			else if (result > 0x7fff && cinstr.tgt == 3) { incr_pc(); }
			else if (result > 0x7fff && result != 0 && cinstr.tgt == 1) { incr_pc(); }
			else if (result > 0x7fff && cinstr.tgt == 2) { incr_pc(); }
			else if (result < 0x8000 && cinstr.tgt == 5) { incr_pc(); }
			else if (result < 0x8000 && result != 0 && cinstr.tgt == 1) { incr_pc(); }
			else if (result < 0x8000 && cinstr.tgt == 4) { incr_pc(); }

			else if ((readcr(0) & 0x2) && cinstr.tgt == 6 && result != 0) { incr_pc();}
			else if ((readcr(0) & 0x2) && cinstr.tgt == 7) { incr_pc();}
			else if (result == 0 && cinstr.tgt == 7) { incr_pc(); }

			//if (result > 0 && cinstr.tgt == 4) { regfile[PC] += 2; }

			break;
		case 15: // addskp.z op1,op2,res
			writereg(cinstr.tgt, (readreg(cinstr.arg0) + readreg(cinstr.arg1)));
			if(readreg(cinstr.tgt) == 0)
				incr_pc();
			break;
		case 16: // addskp.nz op1,op2,res
			writereg(cinstr.tgt, (readreg(cinstr.arg0) + readreg(cinstr.arg1)));
			if(readreg(cinstr.tgt) != 0)
				incr_pc();
			break;
		case 17: // addi imm,op2,res
			simm = IRtable[cinstr.arg0];
			writereg(cinstr.tgt, (simm + readreg(cinstr.arg1)));
			break;
		case 18: // subi imm, op2, tgt
		  simm = IRtable[cinstr.arg0];
			writereg(cinstr.tgt, (readreg(cinstr.arg1) - simm));
			break;
		case 19: // and imm,op2,res
			simm = IRtable[cinstr.arg0];
			writereg(cinstr.tgt, (simm & readreg(cinstr.arg1)));
			break;
		case 20: // or imm,op2,res
			simm = IRtable[cinstr.arg0];
			writereg(cinstr.tgt, (simm | readreg(cinstr.arg1)));
			break;
		case 22: //addskp.zimm imm,op2,res
			simm = IRtable[cinstr.arg0];
			writereg(cinstr.tgt, (simm + readreg(cinstr.arg1)));
			printd("arg0: %x, arg1: %x, tgt: %x", simm, readreg(cinstr.arg1), (simm + readreg(cinstr.arg1)));
			if(readreg(cinstr.tgt) == 0)
				incr_pc();
			break;
		case 23: //addskp.nzimm imm,op2,res
			simm = IRtable[cinstr.arg0];
			writereg(cinstr.tgt, (simm + readreg(cinstr.arg1)));
			printd("arg0: %x, arg1: %x, tgt: %x", simm, readreg(cinstr.arg1), readreg(cinstr.tgt));
			if(readreg(cinstr.tgt) != 0)
				incr_pc();
			break;
		case 24: // ldwb idx, base, tgt
			addr = readreg(cinstr.arg0) + readreg(cinstr.arg1);
			writereg(cinstr.tgt, readram(addr, 0, 0));
			printd("r%d <- %x\n", cinstr.tgt, readreg(cinstr.tgt));
			break;
		case 25: // ldbb idx, base, tgt
			addr = readreg(cinstr.arg0) + readreg(cinstr.arg1);
			writereg(cinstr.tgt, readram(addr, 1, 0));
			break;
		case 26: // stwb idx, base, value
			addr = readreg(cinstr.arg0) + readreg(cinstr.arg1);
			writeram(addr, readreg(cinstr.tgt), 0);
			break;
		case 27: // stbb idx, base, value
			addr = readreg(cinstr.arg0) + readreg(cinstr.arg1);
			writeram(addr, readreg(cinstr.tgt), 1);
			break;
		case 28: // sext reg, reg
	  	byte = (0xFF & readreg(cinstr.arg0));
	    mask = 0x80;
	    if (mask & byte)
	    	byte += 0xFF00;
			writereg(cinstr.tgt, byte);
			printd("sext: r%d <- R%d: %x", cinstr.tgt, cinstr.arg0, byte);
			break;
		case 30: // addhi u7,tgt2
			imm = (cinstr.full & 0x1fc) << 7;
			writereg(cinstr.tgt2, ((readreg(cinstr.tgt2) & 0x1ff) | imm));
			printd("R%d <- %x", cinstr.tgt2, readreg(cinstr.tgt2));
			break;
		case 31: // push src
			writereg(SP, (readreg(SP)-2));
			writeram(readreg(SP), readreg(cinstr.tgt), 0);
			printd("RAM[%x]<- R%d(%x) \n", readreg(SP), cinstr.tgt, readreg(cinstr.tgt));
			break;
		case 32: // pop tgt
			writereg(cinstr.tgt, readram(readreg(SP), 0, 0));
			printd("R%d <- %x ", cinstr.tgt, readreg(cinstr.tgt));
			writereg(SP, (readreg(SP)+2));
			break;
		case 33: // br.r tgt
			writereg(PC, readreg(cinstr.tgt));
			printd(" PC <- %x\n", readreg(PC));
			break;
		case 34: // syscall tgt
			trapnr = trapnr | 0x10;
			break;
		case 35: // reti
			bank = 0;
			break;
		case 36: // push.u
			writereg(SP, (readreg(SP)-2));
			writeram(readreg(SP), uregfile[cinstr.tgt], 0);
			break;
		case 37: // brk
			printf("\nBreak encountered. \n");
			getinput();
			break;
		case 38: // lcr reg
			writereg(cinstr.tgt, readcr(0));
			break;
		case 39: // scr reg
			writecr(readreg(cinstr.arg0),0);
			break;
		case 40: // wpte
			pagetable[readreg(cinstr.arg0)] = readreg(cinstr.arg1);
			printd("%d -> %d ", readreg(cinstr.arg0), readreg(cinstr.arg1));
			break;
		case 41: // lpte
			writereg(cinstr.tgt, pagetable[cinstr.arg0]);
			break;
		case 42: // wptb
			ptb = readreg(cinstr.arg0);
			break;
		case 44: // wivec
			ivec = readreg(cinstr.tgt);
			break;
		case 45: // shl cnt, tgt2
			imm = ((cinstr.full & 0x1e0) >> 5);
			arg2 = (cinstr.full & 0x1c) >> 2;
			printd("imm: %d", imm);
			writereg(cinstr.tgt2, (readreg(arg2) << imm));
			printd("result: %x",(readreg(arg2) << imm));
			printd("R%d <- %x ", cinstr.tgt2, readreg(cinstr.tgt2));
			break;
		case 46: // shr cnt, tgt2
			imm = ((cinstr.full & 0x1e0) >> 5);
			arg2 = (cinstr.full & 0x1c) >> 2;
			writereg(cinstr.tgt2, (readreg(arg2) >> imm));
			printd("R%d <- %x ", cinstr.tgt2, readreg(cinstr.tgt2));
			break;
		case 47: // shl.r src, cnt, tgt
			writereg(cinstr.tgt, (readreg(cinstr.arg0) << readreg(cinstr.arg1)));
			printd("R%d <- %x ", cinstr.tgt, readreg(cinstr.tgt));
			break;
		case 48: // shr.r src, cnt, tgt
			writereg(cinstr.tgt, (readreg(cinstr.arg0) >> readreg(cinstr.arg1)));
			printd("R%d <- %x ", cinstr.tgt, readreg(cinstr.tgt));
			break;
		case 49: // pop.u tgt
			uregfile[cinstr.tgt] = readram(readreg(SP), 0, 0);
			writereg(SP, (readreg(SP)+2));
			printd("R%d <- %x ", cinstr.tgt, uregfile[cinstr.tgt]);
			break;
		case 50: // lcr.u reg
			printd("R%d <- %x ", cinstr.tgt, readcr(1));
			writereg(cinstr.tgt, readcr(1));
			break;
		case 51: // wcr.u reg
			writecr(readreg(cinstr.arg0), 1);
			printd("CR <- %x ", readcr(1));
			break;
		case 63:
			printf("\nHALT instruction at %x\n", (readreg(PC)-2));
			printf("contents of R5: %x\n", readreg(BP));
			printf("Simulation ran for %d ticks\n", tick);
			getinput();
			einde();
			break;
		default:
			printf("\nEncountered (%x) unknown opcode: %d (%s)\n", cinstr.full, cinstr.opcode, OPCODES_STRING[cinstr.opcode]);
			getinput();
			einde();
			break;
		}
		if (!justsetcarry) {
			// carry flag needs to survive one instr cycle
			// then be reset
			writecr((readcr(0) & 0xfffd),0);
		}
	}
	printf("End of while-loop.\n");
	getinput();
}


int
einde() {
	dumpregs();
	exit(1);
}

void dumpregs(){
	int i;
  printf("----------------------------REGISTERS-----------------------\n");
  printf("current BANK: %d\n", bank);
	for(i=0; i<8; i++){
    printf("R%d: %04x\n", i, readreg(i));
  }
	dumpcr();
	printf("ivec: %x\n", ivec);
	printf("ir: %x\n", cinstr.full);
}

void dumpcr() {
	printf("CR: ");
	if (readcr(0) & 0x8) { printf("IR ");} else {printf("ir ");};
	if (readcr(0) & 0x4) { printf("PE ");} else {printf("pe ");};
	if (readcr(0) & 0x2) { printf("CR ");} else {printf("cr ");};
	if (readcr(0) & 0x1) { printf("SM ");} else {printf("um ");};
	printf("\n");
}

void decode(ushort ir, struct instr_t *p) {
	ushort i;

	printd("%x", ir);

	i = ir >> 9;
	//printd("i: %d", i);
	if (i > 66) {
		// long opcode
		p->opcode = i & 0x3f;
	} else {
		// short opcode
		p->opcode = (i >> 4);
	}
	p->full = ir;
	p->args = ir & 0x1ff;
	p->arg0 = p->args >> 6;
	p->arg1 = (p->args >> 3) & 0x7;
	p->tgt = p->args & 0x7;
	p->tgt2 = (p->args & 0x3) + 1;
	printd("(%s), ", OPCODES_STRING[p->opcode]);
}

uint16_t readreg(int reg) {
	if (bank) {
		//printd("reg: %d", reg);
		return sregfile[reg];
	} else {
		return uregfile[reg];
	}
}

void writereg(int reg, uint16_t value) {
	//printd("value: %x ", value);
	if (bank) {
		sregfile[reg] = value;
	} else {
		uregfile[reg] = value;
	}
}

void incr_pc() {
	if (bank) {
		sregfile[PC] +=2;
	} else {
		uregfile[PC] +=2;
	}
}

int
readram(ushort addr, int be, int bypasspag) {
  int ramaddr;
	int paddr;
	uint16_t ramdata;
	if(addr >= 0xffa0){
		return readsd(addr);
	}

	if(addr >= 0xff90) {
		return readuart(addr);
	}

	paddr = pageaddr(addr);

	if (bypasspag) {
		ramaddr = addr >> 1;
	} else {
		ramaddr = paddr >> 1;
	}

	if(be) {
		//printd("RAM: %x: %x ", ramaddr, ram[ramaddr]);
		//printd("MAR: %x", (sysreg[MAR] % 2));
		if(addr % 2) {
      // MAR is odd thus we need to return the low byte
      ramdata = ram[ramaddr] & 0xff;
    } else {
			//printd("RAM 16b: %x, RAMout: %x", ram[ramaddr], (ram[ramaddr]>>8));
      // MAR is even thus we need to return the high byte
      ramdata = ram[ramaddr] >> 8;
			//printd("ram: %x -> RAMout: %x", ram[ramaddr], bsig[RAMout]);
    }
  } else {
    ramdata = ram[ramaddr];
  }
	return ramdata;
}

void
writeram(ushort addr, ushort value, int be) {
  uint32_t paddr, ramaddr, MDRlowb, tmp;

	if (addr == 0xff90) {
		printf("%c", (value & 0xff));
		return;
	}
	if (addr >= 0xffa0) {
		writesd((addr&0xff), value);
	}
	if (addr > 0xff90) {
		return;
	}
	paddr = pageaddr(addr);
  ramaddr = paddr >> 1;

	if(be) {
    MDRlowb = value & 0x00ff; // low byte from MDR
    if(addr % 2) {
      // MAR is odd thus we need to write the low byte
      tmp = ram[ramaddr] & 0xff00; // clear the low byte
      ram[ramaddr] = tmp | MDRlowb;
      printd("RAM[%xL] <- %x (%x)\n", ramaddr*2, MDRlowb, ram[ramaddr]);
    } else {
      // MAR is even thus we need to write the high byte
      tmp = ram[ramaddr] & 0xff;
      ram[ramaddr] = tmp | MDRlowb << 8;
      printd("RAM[%xH] <- %x (%x)\n", ramaddr*2, MDRlowb, ram[ramaddr]);
    }
  } else {
    ram[ramaddr] = value;
    printd("RAM[%x] <- %x\n", ramaddr*2, value);
  }
}

void writesd(uint8_t addr, uint16_t value) {
	if(addr == 0xa6) {
		sddata = value;
		printd("SDDATA <- %x", value);
	}
	if(addr == 0xa2 && value ==0x8851) {
		// read sector in data
		bread(sddata);
	}
}

uint16_t readsd(uint8_t addr) {
	if(addr == 0xa2) {
		// reading R1 response
		return 0;
	}
	if(addr == 0xa8) {
		//printf("high word: %x %x --", rfifo[rfifo_p], rfifo[rfifo_p+1]&0xff);
		return (((rfifo[rfifo_p]&0xff)<<8)|(rfifo[rfifo_p+1]&0xff));
	}
	if(addr == 0xaa) {
		rfifo_p += 4;
		//printf("low word: %x %x \n", rfifo[rfifo_p-2], rfifo[rfifo_p-1]);
		return (((rfifo[rfifo_p-2]&0xff)<<8)|(rfifo[rfifo_p-1]&0xff));
	}
}

void bread(int bn) {
  printf("Attempting to read SD at: %x\n", bn*512);
	if(lseek(fsfd, bn * 512, 0) != bn * 512){
    perror("lseek");
    exit(1);
  }

  if(read(fsfd, &rfifo, 512) != 512){
		perror("read");
    exit(1);
  }
	rfifo_p = 0;
}

int readuart(uint32_t addr) {
	// 0xff95 - LSR, tx is free if bit5 & 6 are 1
	printd("readuart - addr: %x", addr);
	if (addr == 0xff95) {
		if (tick > (tx_delay + 1)) {
			tx_delay = tick;
			return 0x60;
		} else {
			return 0x0;
		}
	}
	return 0xdead;
}

uint16_t readcr(int ureg) {
	if (ureg)
		return ucr;
	else if (bank)
		return scr;
	else
		return ucr;
}

void writecr(uint16_t value, int ureg) {
	if (ureg)
		ucr = value;
	else if (bank)
		scr = value;
	else
		ucr = value;
}

void traps() {
	// page faulting will be kept out of this for now
	// only expecting syscall and timer so IRQs
	// irqs will be raised by directly setting the bit in trapnr
	if (trapnr > 0 && (readcr(0) & 0x8)) {
		printd("TRAP RAISED: %x\n", trapnr);
		sregfile[REG1] = trapnr;
		if (trapnr & 0x10) {
			// syscall
			trapnr = trapnr & 0xffef;
		} else if (trapnr & 0x20) {
			// timer irq
			trapnr = trapnr & 0xffdf;
		} else {
			printf("UNKOWN TRAP NR: %d", trapnr);
			exit(1);
		}
		sregfile[2] = cinstr.tgt;
		sregfile[PC] = ivec;
		bank = 1;
	}
	return;
}

ushort getpte(ushort laddr) {
	uint16_t ptidx;

	ptidx = ptb + (laddr >> 11);
	return pagetable[ptidx];
}

uint32_t pageaddr(ushort laddr){
	uint16_t pte;
	uint16_t ptetmp;

	if (readcr(0) & 0x4) {
		// paging is on
		pte = getpte(laddr);
		//printd("pte: %x", pte);
		ptetmp = (((pte & 0xff00) <<3) | (laddr & 0x7ff));
		//printd("return: %x ", ptetmp);
		if ((pte & 0x1)==0) {
			printf("FAULT: page not present (%x). Instr at addr: %x\n", laddr, readreg(PC));
			getinput();
		}
		if ((readcr(0) & 0x1)==0 && (pte & 0x2)){
			printf("FAULT: system page not accessible in use mode (%x)", laddr);
			getinput();
		}
		return ptetmp;
	} else {
		return laddr;
	}
}


void INThandler(int sig)
{
	signal(sig, SIG_IGN);
	getinput();
}
void getinput() {
	int rc,t,i,nr, d;
	char buff[40];
	char * pch;
	char *token[5];
	uint addr;
	// https://stackoverflow.com/questions/4023895/how-to-read-string-entered-by-user-in-c
again:
	rc = getLine ("> ", buff, sizeof(buff));
  if (rc == 1) {
		// no input
    goto again;
  }
	t=0;
	pch = strtok(buff," ");
  while (pch != NULL)
  {
    token[t++] = pch;
    pch = strtok (NULL, " ");
  }

	// printd("number of tokens: %d", t);
	// for (i = 0; i < t; ++i)
	// 	printd("%s\n", token[i]);

	if (strcmp(token[0], "r") == 0) {
		dumpregs();
		goto again;
	} else if (strcmp(token[0], "q") == 0) {
		exit(1);
	} else if (strcmp(token[0], "x") == 0) {
		if (t == 2) {
			addr = (uint)strtol(token[1], NULL, 16);
			printf("%04x: %04x\n", addr, readram(addr, 0, 0));
		} else if (t == 3) {
			int nr = strtol(token[2], NULL, 10);
			addr = (uint)strtol(token[1], NULL, 16);
			d=0;
			while (d < nr) {
				printf("\n%04x: ", addr+d);
				for (i=0; i<16; i+=2) {
					printf("%04x  ", readram((addr+d+i), 0, 0));
				}
				d += 16;
			}
			printf("\n");
		}
	} else if (strcmp(token[0], "p") == 0) {
		if (t == 2) {
			addr = (uint)strtol(token[1], NULL, 16);
			printf("%04x: %04x\n", addr, readram(addr, 0, 1));
		} else if (t == 3) {
			int nr = strtol(token[2], NULL, 10);
			addr = (uint)strtol(token[1], NULL, 16);
			d=0;
			while (d < nr) {
				printf("\n%04x: ", addr+d);
				for (i=0; i<=16; i+=2) {
					printf("%04x  ", readram((addr+d+i), 0, 1));
				}
				d += 16;
			}
			printf("\n");
		}
	} else if (strcmp(token[0], "s") == 0) {
		// dump the stack
		int nr = strtol(token[1], NULL, 10);
		addr = readreg(SP);
		d=0;
		while (d < nr) {
			printf("\n%04x: ", addr+d);
			for (i=0; i<=16; i+=2) {
				if(readreg(BP)==(addr+d+i))
					printf("%04x< ", readram((addr+d+i), 0, 0));
				else
					printf("%04x  ", readram((addr+d+i), 0, 0));
			}
		  d += 16;
		}
	} else if (strcmp(token[0], "ss1") == 0) {
		sflag = 1;
		return;
	} else if (strcmp(token[0], "ss0") == 0) {
		sflag = 0;
		return;
	} else if (strcmp(token[0], "c") == 0) {
		return;
	} else if (strcmp(token[0], "tab") == 0 ) {
		if (readcr(0) & 0x4) {
			printf("PTB: %x\n", ptb);
			for(i=0;i<32;i++){
				if(pagetable[ptb+i]){
					//printf("pt: %x", pagetable[ptb+i]);
					printf("[%x] 0x%04x -> [%x] 0x%04x\n", i, i*0x800,
					((pagetable[ptb+i]&0xff00)>>8), ((pagetable[ptb+i]&0xff00)<<3));}
			}
		} else {
			printf("Paging not enabled!\n");
		}
	} else if (strcmp(token[0], "page") == 0) {
		printf("%s -> %x\n", token[1], pageaddr(strtol(token[1], NULL, 16)));
	} else if (strcmp(token[0], "pte") == 0) {
		printf("%s -> %x\n", token[1], getpte(strtol(token[1], NULL, 16)));
	}
	goto again;
}

static int
getLine (char *prmpt, char *buff, size_t sz) {
  int ch, extra;

  // Get line with buffer overrun protection.
  if (prmpt != NULL) {
      printf ("%s", prmpt);
      fflush (stdout);
  }
  if (fgets (buff, sz, stdin) == NULL)
      return 1;

  // If it was too long, there'll be no newline. In that case, we flush
  // to end of line so that excess doesn't affect the next call.
  if (buff[strlen(buff)-1] != '\n') {
      extra = 0;
      while (((ch = getchar()) != '\n') && (ch != EOF))
          extra = 1;
      if (extra == 1) {
				printf("INPUT TOO_LONG");
				exit(1);
			} else {
				printf("OK");
				exit(1);
			}
  }

  // Otherwise remove newline and give string back to caller.
  buff[strlen(buff)-1] = '\0';
  return 0;
}

void printd(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    if (vflag)
			vprintf(fmt, args);
    va_end(args);
}

void
loadbios(void)
{
  FILE * fp;
  char * line = NULL;
  size_t len = 0;
  ssize_t read;
	uint16_t addr, a;
	uint16_t opcode;
	char opcode_b[16]; //including ;
  char * pch, * colon;

	if(asm_dir == 1){
    fp = fopen("../asm/A_sim.mif", "r");
    if (fp == NULL) {
      printf("FAILURE opening asm/A_sim.mif\n");
      exit(EXIT_FAILURE);
    }
	} else if (os_dir == 1){
    fp = fopen("../../dme_os/A_sim.mif", "r");
    if (fp == NULL) {
      printf("FAILURE opening dme_os/A_sim.mif\n");
      exit(EXIT_FAILURE);
    }
	} else {
    fp = fopen("../validation/A_sim.mif", "r");
    if (fp == NULL) {
      printf("FAILURE opening validation/A_sim.mif\n");
      exit(EXIT_FAILURE);
    } else {
    	printf("Opening: validation/A_sim.mif");
    }
	}
		a = 0;
  while ((read = getline(&line, &len, fp)) != -1) {
    //printf("Retrieved line of length %zu :\n", read);
    //printf("%s", line);

    //printf ("Splitting string \"%s\" into tokens:\n",str);
    colon = strchr(line, ':');
		if (!colon) {
			//printd("Found colon - skip: %x\n", (int)colon);
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

    ram[a] = opcode;
		printd("%x: %x\n", a, ram[a]);
		a += 1;
	}
  fclose(fp);
  if (line)
    free(line);
}

int parseopts(int argc,char *argv[]) {
  opterr = 0;
  int c;
  while ((c = getopt(argc, argv, "vaos")) != -1) {
    printf("opt: %d\n", c);
    switch (c) {
		case 'o':
			os_dir = 1;
			break;
		case 'a':
			asm_dir = 1;
			break;
		case 'v':
      printf("vflag!");
      vflag = 1;
      break;
		case 's':
			sflag = 1;
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