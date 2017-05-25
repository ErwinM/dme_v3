//C hello world example
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>

#include "defs.h"
#include "arch.h"
#include "types.h"

uint64_t micro[256];

int main(void) {

	int16_t i, j, r1;
	int32_t r2;
	unsigned int u, v;
	short c;

	i = -10;
	j = 20;

	u = 110;
	v = 10;

	r1 = u - v;
	r2 = u - v;

	printf(" %x - %x = %x \n", u, v, r1);
	printf(" %x - %x = %x \n", u, v, r2);

	if (r1 == r2)
		printf("huh?");

}