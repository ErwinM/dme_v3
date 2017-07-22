//C hello world example
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

#include "defs.h"
#include "arch.h"
#include "types.h"


int main(void)
{
  uint32_t b1, b2, b3, result32;
	int16_t sresult32;

  b1=0x4;
  b2=0x6;
  b3=0xff00;

	result32 = (b1&0xffff) -(b2&0xffff);
	sresult32 = b1 -b2;

  printf("%x - %x = %x (%d)\n", b1, b2, result32, (result32 > 0xffff));
  printf("%x - %x = %x (%d)\n", b1, b2, sresult32, (sresult32 > 0xffff));

}