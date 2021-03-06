#include <stdint.h>
#include "../types.h"
#include "../arch2.h"

struct instr_t{
	ushort full;
	ushort opcode;
	ushort args;
	ushort arg0;
	ushort arg1;
	ushort tgt;
	ushort tgt2;
};

int parseopts();
void loadbios();
void init();
int bin2dec(char *bin, int size);
void decode(ushort ir, struct instr_t *ptr);
int readram(ushort addr, int be, int bypasspag);
void writeram(ushort addr, ushort value, int be);
int readuart(uint32_t addr);
uint16_t readreg(int reg);
void writereg(int reg, uint16_t value);
void incr_pc();
void writecr(uint16_t value, int ureg);
uint16_t readcr(int ureg);
uint32_t pageaddr(ushort laddr);
ushort getpte(ushort laddr);

void traps();

void  INThandler(int);
void dumpregs();
void dumpcr();
void printd(const char *fmt, ...);
int einde();
static int getLine (char *prmpt, char *buff, size_t sz);
void getinput();

void writesd(uint8_t addr, uint16_t value);
void bread(int bn);
uint16_t readsd(uint8_t addr);

