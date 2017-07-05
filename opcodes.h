static const char
*OPCODES_STRING[] = { "ldi",        // 0
                      "br",
                      "fetch",
                      "nocode",
                      "ldw s7",
                      "ldb s7",     // 5
                      "stw s7",
                      "stb s7",
                      "stw0 s7",
                      "stb0 s7",
                      "add",        // 10
                      "sub",
                      "and",
                      "or",
                      "skip.c",
                      "addskp.z",     // 15
                      "addskp.nz",
                      "addi",
                      "subi",
                      "andi",
                      "ori",       // 20
                      "nocode",
                      "addskpi.z",
                      "addskpi.nz",
                      "ldw.b",
                      "ldb.b",       // 25
                      "stw.b",
                      "stb.b",
                      "sext",
                      "nocode",
                      "addhi",        // 30
                      "push",
                      "pop",
                      "br.r",
                      "NG",
                      "NG",						// 35
                      "NG",
                      "brk",
                      "lcr",
                      "scr",
                      "NG",						// 40
                      "NG",
                      "wptb",
                      "lptb",
                      "wivec",
                      "shl",						// 45
                      "shr",
                      "NG",
                  };