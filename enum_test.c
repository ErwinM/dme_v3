#define MACROSTR(k) #k

#define CSIGS \
       X(kZero  ) \
       X(kOne   ) \
       X(kTwo   ) \
       X(kThree ) \
       X(kFour  ) \
       X(kMax   )

enum {
#define X(Enum)       Enum,
    CSIGS
#undef X
} kConst;

static char *kConstStr[] = {
#define X(String) MACROSTR(String),
    CSIGS
#undef X
};




int main(void)
{
    int k;
    printf("Hello World!\n\n");

    for (k = 0; k < kMax; k++)
    {
        printf("%s\n", kConstStr[k]);
    }
    printf("%s\n", kConstStr[kTwo]);
    return 0;
}
