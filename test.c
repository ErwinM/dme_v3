//C hello world example
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "defs.h"
#include "arch.h"
#include "types.h"

uint micro[256];

int main(void)
{
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    uint microcode, i = 0;
    char * pch;

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
        int number = (int)strtol(pch, NULL, 0);
        switch(c){
          case 1:
            microcode = number << 18;
            break;
          case 2:
            microcode = microcode | number;
            break;
        }

        //printf ("%x\n",microcode);
        pch = strtok (NULL, " ");
      }
      micro[i] = microcode;
      i++;
    }
    for(i=0;i<130;i++) {
      printf("RAM[%d]: %s\n", i, dec2bin(micro[i], 34));
    }



    fclose(fp);
    if (line)
        free(line);
    exit(EXIT_SUCCESS);
}