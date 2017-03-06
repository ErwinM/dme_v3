#ifndef UNITS_H_   /* Include guard */
#define UNITS_H_

#include "types.h"

enum signalstate { ZZ, RE, HI, FE, LO };

const short IRtable[8] = { 1,2,4,8,-8,-4,-2,-1 };

enum flags { ZR, NG};
static const char *FLAGS_STRING[] = { "ZR", "NG"};

static const char *COND_STR[] = { "EQ", "NEQ", "SLT", "SLTEQ", "SGT", "SGTEQ", "LT", "LTEQ" };
static const char *ALUFUNC_STR[] = { "ADD", "SUB" };

#define PHASE \
      X(clk_RE) \
      X(clk_FE)

#define ICYCLE \
      X(ZERO_STATE) \
      X(FETCH) \
      X(FETCHM) \
      X(DECODE) \
      X(DECODEM) \
      X(READ) \
      X(READM) \
      X(EXECUTE) \
      X(EXECUTEM)

#define CSIGS \
       X(MAR_LOAD  ) \
       X(IR_LOAD   ) \
       X(MDR_LOAD ) \
       X(REG_LOAD  ) \
       X(RAM_LOAD  ) \
       X(INCR_PC) \
       X(SKIP   ) \
       X(BE   ) \

#define REGFILE \
      X(REG0  ) \
      X(REG1   ) \
      X(REG2   ) \
      X(REG3 ) \
      X(REG4  ) \
      X(REG5  ) \
      X(SP  ) \
      X(PC  ) \
      X(ARG0) \
      X(ARG1) \
      X(TGT) \
      X(TGT2) \
      X(FLAGS)

#define SYSREG \
      X(MAR) \
      X(MDR) \
      X(IR)

#define REGSEL \
      X(REGR0S  ) \
      X(REGR1S   ) \
      X(REGWS   )

#define IMMSEL \
      X(IMM7) \
      X(IMM10) \
      X(IMM13) \
      X(IMMIR) \
      X(IMM6)

// Bussel can only select from busses never from registers
// thus, their value indexes the BSIG array, except MDRS
#define BUSSEL \
      X(OP0S) \
      X(OP1S) \
      X(MDRS) \
      X(ALUS) \
      X(COND) \
      X(BYTE_ENABLE) \
      X(IMMS)

#define BSIGS \
      X(REGR0  ) \
      X(REGR1  ) \
      X(MDRout   )  \
      X(IRimm   ) \
      X(RAMout)  \
      X(ALUout   ) \
      X(MARin   ) \
      X(RAMin) \
      X(OP0   ) \
      X(OP1   ) \
      X(MDRin   ) \
      X(NEXTSTATE)

#define SKIPC \
      X(ZERO  ) \
      X(NOTZERO  ) \
      X(CHECKCOND  )





// code to generate enums and string arrays for CSIG and BSIG
// from: http://stackoverflow.com/questions/147267/easy-way-to-use-variables-of-enum-types-as-string-in-c/29561365#29561365
#define MACROSTR(k) #k

enum regfile {
#define X(Enum)       Enum,
    REGFILE
#undef X
};

static char *REGFILE_STR[] = {
#define X(String) MACROSTR(String),
    REGFILE
#undef X
};

enum bsig {
#define X(Enum)       Enum,
    BSIGS
#undef X
};

static char *BSIG_STR[] = {
#define X(String) MACROSTR(String),
    BSIGS
#undef X
};

enum phase {
#define X(Enum)       Enum,
    PHASE
#undef X
};

static char *PHASE_STR[] = {
#define X(String) MACROSTR(String),
    PHASE
#undef X
};

enum icycle {
#define X(Enum)       Enum,
  ICYCLE
#undef X
};

static char *ICYCLE_STR[] = {
#define X(String) MACROSTR(String),
  ICYCLE
#undef X
};

enum csig {
#define X(Enum)       Enum,
    CSIGS
#undef X
};

static char *CSIG_STR[] = {
#define X(String) MACROSTR(String),
    CSIGS
#undef X
};

enum bussel {
#define X(Enum)       Enum,
    BUSSEL
#undef X
};

static char *BUSSEL_STR[] = {
#define X(String) MACROSTR(String),
    BUSSEL
#undef X
};

enum regsel {
#define X(Enum)       Enum,
    REGSEL
#undef X
};

static char *REGSEL_STR[] = {
#define X(String) MACROSTR(String),
    REGSEL
#undef X
};

enum sysreg {
#define X(Enum)       Enum,
    SYSREG
#undef X
};

static char *SYSREG_STR[] = {
#define X(String) MACROSTR(String),
    SYSREG
#undef X
};

enum immsel {
#define X(Enum)       Enum,
    IMMSEL
#undef X
};

static char *IMMSEL_STR[] = {
#define X(String) MACROSTR(String),
    IMMSEL
#undef X
};

enum skipc {
#define X(Enum)       Enum,
    SKIPC
#undef X
};

static char *SKIPC_STR[] = {
#define X(String) MACROSTR(String),
  SKIPC
#undef X
};


#endif
