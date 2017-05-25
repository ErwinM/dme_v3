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
int readram(ushort addr, int be);
void writeram(ushort addr, ushort value, int be);

void  INThandler(int);
void dumpregs();
int einde();
static int getLine (char *prmpt, char *buff, size_t sz);
void getinput();

