#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

enum test {EEN, TWEE, DRIE};

int getal[3];

int main() {
    int old_stdout = dup(1);

    freopen ("/dev/null", "w", stdout); // or "nul" instead of "/dev/null"
    printf("asd1");
    fclose(stdout);

    stdout = fdopen(old_stdout, "w");
    printf("asd2");
    return 0;
}