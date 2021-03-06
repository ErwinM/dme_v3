#include <stdint.h>
#include "types.h"
#include "arch2.h"
char *dec2bin(uint64_t n, int sz);
void loadmicrocode(void);
void loadbios(void);
int getbit(char *bitstring, int bitnr);
int bin2dec(char *bin, int size);
uint64_t bin2dec64(char *bin, int size);
int sbin2dec(char *bin, int size);
int bin2_to_dec(char *bin);
int bin3_to_dec(char *bin);
int bin7_to_dec(char *bin);
int bin10_to_dec(char *bin);
int bin13_to_dec(char *bin);
int getbit6(char *bitstring, int bitnr);
int getbit16(char *bitstring, int bitnr);
void init(void);
void readram(void);
int readramdump(int addr);
void writeram(void);
void update_csig(enum csig signame, enum signalstate state);
void update_bsig(int signame, ushort *value);
void update_bussel(enum bussel, ushort value);
void update_regsel(enum regsel signame, ushort value);
void dosignals(void);
void latch();
void writeregfile(void);
void ALU();
void clearsig(void);
void fetchsigs(void);
void decodesigs(void);
void CPUsigs(void);
int chkskip(void);
void dump(void);
void hideconsole(int ic, int vflag);
void restoreconsole(void);
int parseopts(int argc,char *argv[]);
void writeCR();
void setCR(int bit, int value);
int fsm_function();
