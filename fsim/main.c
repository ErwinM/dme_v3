// DME functional simulator (?)
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include  <signal.h>

#include "../arch2.h"
#include "../types.h"
#include "defs.h"

uint16_t ram[4096] = {0};
uint16_t regfile[16] = {0};
uint16_t cr, cr2;

short instr;
struct instr_t cinstr;

int asm_dir;
int os_dir;
int pauze;

int
main(int argc,char *argv[]) {
	ushort ir;
	uint16_t imm, addr, arg2, result;
	int16_t simm, sresult;
	int32_t result32;
	cr = 0x8;

	parseopts(argc, argv);
  //init();
	loadbios();
	signal(SIGINT, INThandler);
	ir = -1;
	while(regfile[PC] < 0x2000 && ir != 0 ) {
		pauze = 1;
		ir = readram(regfile[PC], 0);
		regfile[PC] += 2;
		printf("\nPC: %x, ", regfile[PC]);
		decode(ir, &cinstr);

		cr = cr & 0xfffd;

		switch(cinstr.opcode){
		case 0: //ldi reg, s10
			simm = (int16_t)((cinstr.full & 0x1ff8) << 3) >> 6;
			regfile[cinstr.tgt] = simm;
			printf("R%d <- %x\n", cinstr.tgt, simm);
			break;
		case 1:
			simm = (int16_t)((cinstr.full & 0x1fff) << 3) >> 3;
			printf("imm: %x", simm);
			regfile[PC] += simm;
			printf(" PC <- %x\n", regfile[PC]);
			break;
		case 4: // ldw tgt, sw7(R5)
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = regfile[BP] + simm;
			regfile[cinstr.tgt2] = readram(addr, 0);
			printf("r%d <- %x ", cinstr.tgt2, regfile[cinstr.tgt2]);
			break;
		case 5: // ldb sb7(r5),tgt
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = regfile[BP] + simm;
			regfile[cinstr.tgt2] = readram(addr, 1);
			break;
		case 7: // stb sb7(r5),tgt
			simm = (int16_t)((cinstr.full & 0x1fc) << 7) >> 9;
			addr = regfile[BP] + simm;
			writeram(addr, regfile[cinstr.tgt2], 1);
			break;
		case 10: // add op1,op2,res
			regfile[cinstr.tgt] = regfile[cinstr.arg0] + regfile[cinstr.arg1];
			result32 = regfile[cinstr.arg0] + regfile[cinstr.arg1];
			if (regfile[cinstr.tgt] != result32) {
				cr = cr | 0x2;
				printf("set carry ");
			}
			break;
		case 11: // add op1,op2,res
			regfile[cinstr.tgt] = regfile[cinstr.arg0] - regfile[cinstr.arg1];
			result32 = regfile[cinstr.arg0] + regfile[cinstr.arg1];
			if (regfile[cinstr.tgt] != result32) {
				cr = cr | 0x2;
				printf("set carry ");
			}
			break;
		case 12: // add op1,op2,res
			regfile[cinstr.tgt] = regfile[cinstr.arg0] & regfile[cinstr.arg1];
			break;
		case 13: // add op1,op2,res
			regfile[cinstr.tgt] = regfile[cinstr.arg0] | regfile[cinstr.arg1];
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
			result = regfile[cinstr.arg0] - regfile[cinstr.arg1];
			result32 = regfile[cinstr.arg0] - regfile[cinstr.arg1];
			printf("%x - %x = r16: %x, 32: %x, s16: %x", regfile[cinstr.arg0], regfile[cinstr.arg1], result, result32, sresult);
			if (result != result32) {
				cr = cr | 0x2;
				printf("set carry ");
			}
			if (result == 0 && cinstr.tgt == 3) { regfile[PC] += 2; }
			else if (result == 0 && cinstr.tgt == 0) { regfile[PC] += 2; }
			else if (result == 0 && cinstr.tgt == 5) { regfile[PC] += 2; }
			else if (result > 0x7fff && cinstr.tgt == 3) { regfile[PC] += 2; }
			else if (result > 0x7fff && cinstr.tgt == 1) { regfile[PC] += 2; }
			else if (result > 0x7fff && cinstr.tgt == 2) { regfile[PC] += 2; }
			else if (result < 0x8000 && cinstr.tgt == 5) { regfile[PC] += 2; }
			else if (result < 0x8000 && cinstr.tgt == 1) { regfile[PC] += 2; }
			else if (result < 0x8000 && cinstr.tgt == 4) { regfile[PC] += 2; }

			else if ((cr & 0x2) && cinstr.tgt == 6 && result != 0) { regfile[PC] += 2;}
			else if ((cr & 0x2) && cinstr.tgt == 7) { regfile[PC] += 2;}
			else if (result == 0 && cinstr.tgt == 7) { regfile[PC] += 2; }

			//if (result > 0 && cinstr.tgt == 4) { regfile[PC] += 2; }

			break;
		case 15: // addskp.z op1,op2,res
			regfile[cinstr.tgt] = regfile[cinstr.arg0] - regfile[cinstr.arg1];
			if(regfile[cinstr.tgt] == 0)
				regfile[PC] += 2;
			break;
		case 16: // addskp.nz op1,op2,res
			regfile[cinstr.tgt] = regfile[cinstr.arg0] - regfile[cinstr.arg1];
			if(regfile[cinstr.tgt] != 0)
				regfile[PC] += 2;
			break;
		case 17: // add imm,op2,res
			simm = IRtable[cinstr.arg0];
			regfile[cinstr.tgt] = simm + regfile[cinstr.arg1];
			break;
		case 19: // add imm,op2,res
			simm = IRtable[cinstr.arg0];
			regfile[cinstr.tgt] = simm & regfile[cinstr.arg1];
			break;
		case 20: // add imm,op2,res
			simm = IRtable[cinstr.arg0];
			regfile[cinstr.tgt] = simm | regfile[cinstr.arg1];
			break;
		case 22: //addskp.zimm imm,op2,res
			simm = IRtable[cinstr.arg0];
			regfile[cinstr.tgt] = simm - regfile[cinstr.arg1];
			printf("arg0: %x, arg1: %x, tgt: %x", simm, regfile[cinstr.arg1], regfile[cinstr.tgt]);
			if(regfile[cinstr.tgt] == 0)
				regfile[PC] += 2;
			break;
		case 23: //addskp.nzimm imm,op2,res
			simm = IRtable[cinstr.arg0];
			regfile[cinstr.tgt] = simm - regfile[cinstr.arg1];
			printf("arg0: %x, arg1: %x, tgt: %x", simm, regfile[cinstr.arg1], regfile[cinstr.tgt]);
			if(regfile[cinstr.tgt] != 0)
				regfile[PC] += 2;
			break;
		case 24: //addskp.nzimm imm,op2,res
			addr = regfile[cinstr.arg0] + regfile[cinstr.arg1];
			regfile[cinstr.tgt] = readram(addr, 0);
			break;
		case 25: // ldbb idx, base, tgt
			addr = regfile[cinstr.arg0] + regfile[cinstr.arg1];
			regfile[cinstr.tgt] = readram(addr, 1);
			break;
		case 26: // stwb idx, base, value
			addr = regfile[cinstr.arg0] + regfile[cinstr.arg1];
			writeram(addr, regfile[cinstr.tgt], 0);
			break;
		case 27: // stbb idx, base, value
			addr = regfile[cinstr.arg0] + regfile[cinstr.arg1];
			writeram(addr, regfile[cinstr.tgt], 1);
			break;
		case 30: // addih u7,tgt2
			imm = (cinstr.full & 0x1fc) << 7;
			regfile[cinstr.tgt2] = (regfile[cinstr.tgt2] & 0x1ff) | imm;
			printf("R%d <- %x", cinstr.tgt2, regfile[cinstr.tgt2]);
			break;
		case 31: // push src
			regfile[SP] -= 2;
			writeram(regfile[SP], regfile[cinstr.tgt], 0);
			break;
		case 32: // pop tgt
			regfile[cinstr.tgt] = readram(regfile[SP], 0);
			regfile[SP] += 2;
			break;
		case 37: // brk
			printf("Break encountered. \n");
			getinput();
			break;
		case 38: // lcr reg
			regfile[cinstr.tgt] = cr;
			break;
		case 39: // scr reg
			cr = regfile[cinstr.arg0];
			break;
		case 45: // shl cnt, tgt2
			imm = ((cinstr.full & 0x1e0) >> 5)+1;
			arg2 = (cinstr.full &  0x1c) >> 2;
			regfile[cinstr.tgt2] = regfile[arg2] << imm;
			printf("R%d <- %x ", cinstr.tgt2, regfile[cinstr.tgt2]);
			break;
		case 46: // shl cnt, tgt2
			imm = ((cinstr.full & 0x1e0) >> 5)+1;
			arg2 = (cinstr.full &  0x1c) >> 2;
			regfile[cinstr.tgt2] = regfile[arg2] >> imm;
			break;
		case 63:
			printf("HALT instruction at %x\n", (regfile[PC]-2));
			getinput();
			einde();
			break;
		default:
			printf("Encountered unknown opcode: %d\n", cinstr.opcode);
			einde();
			break;
		}
	}
}


int
einde() {
	dumpregs();
	exit(1);
}

void dumpregs(){
	int i;
  printf("----------------------------REGISTERS-----------------------\n");
  for(i=0; i<8; i++){
    printf("R%d: %04x\n", i, regfile[i]);
  }
}

void decode(ushort ir, struct instr_t *p) {
	ushort i;

	printf("instruction: %x, ", ir);

	i = ir >> 9;
	//printf("i: %d", i);
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
	printf("opcode: %d ", p->opcode);
}

int
readram(ushort addr, int be) {
  int ramaddr;
	uint16_t ramdata;

  ramaddr = addr >> 1;
	if(be) {
		//printf("RAM: %x: %x ", ramaddr, ram[ramaddr]);
		//printf("MAR: %x", (sysreg[MAR] % 2));
		if(addr % 2) {
      // MAR is odd thus we need to return the low byte
      ramdata = ram[ramaddr] & 0xff;
    } else {
			//printf("RAM 16b: %x, RAMout: %x", ram[ramaddr], (ram[ramaddr]>>8));
      // MAR is even thus we need to return the high byte
      ramdata = ram[ramaddr] >> 8;
			//printf("ram: %x -> RAMout: %x", ram[ramaddr], bsig[RAMout]);
    }
  } else {
    ramdata = ram[ramaddr];
  }
	return ramdata;
}

void
writeram(ushort addr, ushort value, int be) {
  int ramaddr, MDRlowb, tmp;

  ramaddr = addr >> 1;
  if(be) {
    MDRlowb = value & 0x00ff; // low byte from MDR
    if(addr % 2) {
      // MAR is odd thus we need to write the low byte
      tmp = ram[ramaddr] & 0xff00; // clear the low byte
      ram[ramaddr] = tmp | MDRlowb;
      printf("RAM[%xL] <- %x (%x)\n", ramaddr*2, MDRlowb, ram[ramaddr]);
    } else {
      // MAR is even thus we need to write the high byte
      tmp = ram[ramaddr] & 0xff;
      ram[ramaddr] = tmp | MDRlowb << 8;
      printf("RAM[%xH] <- %x (%x)\n", ramaddr*2, MDRlowb, ram[ramaddr]);
    }
  } else {
    ram[ramaddr] = value;
    printf("RAM[%x] <- %x\n", ramaddr*2, value);
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

	// printf("number of tokens: %d", t);
	// for (i = 0; i < t; ++i)
	// 	printf("%s\n", token[i]);

	if (strcmp(token[0], "r") == 0) {
		dumpregs();
		goto again;
	} else if (strcmp(token[0], "e") == 0) {
		exit(1);
	} else if (strcmp(token[0], "x") == 0) {
		if (t == 2) {
			addr = (uint)strtol(token[1], NULL, 16);
			printf("%04x: %04x", addr, readram(addr, 0));
		} else if (t == 3) {
			int nr = strtol(token[2], NULL, 10);
			addr = (uint)strtol(token[1], NULL, 16);
			d=0;
			while (d < nr) {
				printf("\n%04x: ", addr+d);
				d += 16;
				for (i=0; i<=16; i+=2) {
					printf("%04x  ", readram((addr+d+i), 0));
				}
			}
		}
	} else if (strcmp(token[0], "s") == 0) {
		// dump the stack
		int nr = strtol(token[1], NULL, 10);
		addr = regfile[SP];
		d=0;
		while (d < nr) {
			printf("\n%04x: ", addr+d);
			d += 16;
			for (i=0; i<=16; i+=2) {
				printf("%04x  ", readram((addr+d+i), 0));
			}
		}
	} else if (strcmp(token[0], "c") == 0) {
		return;
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
		//printf("%x: %x\n", addr, ram[(addr >> 1)]);
	}
  fclose(fp);
  if (line)
    free(line);
}

int parseopts(int argc,char *argv[]) {
  opterr = 0;
  int c;
  while ((c = getopt(argc, argv, "ao")) != -1) {
    printf("opt: %d\n", c);
    switch (c) {
		case 'o':
			os_dir = 1;
			break;
		case 'a':
			asm_dir = 1;
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