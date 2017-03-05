//C hello world example
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

#include "defs.h"
#include "arch.h"
#include "types.h"

uint micro[256];

int main(void)
{
  uint64_t b1, b2, b3, micro;

  b1=0xaaaa;
  b2=0xbbbb;
  b3=0xff00;

  micro = b1 << 32;
  micro = micro | b2 << 16;
  micro = micro | b3;

  printf("Micro: %llx\n", micro);

}