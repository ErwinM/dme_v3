#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

int sbin2dec(char *bin, int size) {
  int result, i, c;

  result=0;
  i=0;
  for(c=size-1;c>=0;c--) {
    if(bin[c] == '1') {
      result +=pow(2,i);
    }
    i++;
  }

  if(bin[0]=='1') {
    // negative number
    printf("NEG!");
    result = -(pow(2,size)-result);
  }
  printf("bin2dec: %s(%d)\n", bin, result);
  return result;
}

int mergehex(int a, int b) {
  int temp, result;

  result = a & 0xff;
  return result;
}

int main() {
  const char *bin = "0111";

  printf("Result: %x\n", mergehex(0xa032,0));
}