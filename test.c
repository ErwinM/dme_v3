//C hello world example
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "defs.h"
#include "arch.h"
#include "types.h"

uint64_t micro[256];

int main(void) {
  int i;

  for (i=0;i<=8;i++) {
    printf("%d", i);
    if(i==3){
      i=4;
    }
  }
}


int mainnn(void) {
  uint64_t num;
  // char * str = "0000000000001001000000000100100100100000";
  //
  // printf("%llx", bin2dec64(str, 64));


  num = 0x0009004920;
  printf("size: %d\n", (int)sizeof(num));
  printf("%s\n", dec2bin(num, 64));
}

int mainn(void)
{
    FILE * fp;
    char * line = NULL;
    char *microb, *temp;
    size_t len = 0;
    ssize_t read;
    uint64_t microcode;
    int i = 0;
    char * pch;

    microb = (char*)malloc(40+1);

    fp = fopen("micro/micro.hexish", "r");
    if (fp == NULL) {
      printf("FAILURE opening micro/micro.hexish\n");
      exit(EXIT_FAILURE);
    }
    while ((read = getline(&line, &len, fp)) != -1) {
      //printf("Retrieved line of length %zu :\n", read);
      //printf("%s", line);

      //printf ("Splitting string \"%s\" into tokens:\n",str);
      pch = strtok (line," ");
      int c = 0;
      microcode = 0;
      while (pch != NULL)
      {
        c++;
        uint64_t number = (int)strtol(pch, NULL, 0);
        switch(c){
          case 1:
            microcode = number << 48;
            printf("%llx\n", microcode);
            break;
          case 2:
            microcode = microcode | (number << 32);
            break;
          case 3:
            microcode = microcode | (number << 16);
            break;
        }

        //printf ("%x\n",microcode);
        pch = strtok (NULL, " ");
      }
      //microcode = microcode >>24;
      micro[i] = microcode;
      i++;
    }
    for(i=128;i<130;i++) {
      temp = dec2bin(micro[i], 64);
      memcpy(microb, &temp[0], 40);
      microb[40] = '\0';

      printf("RAM[%d]: %s ", i, microb);
      printf("(1st 40b of: %llx)\n", micro[i]);
      //printf("len: %d", strlen(microb));
    }



    fclose(fp);
    if (line)
        free(line);
    exit(EXIT_SUCCESS);
}