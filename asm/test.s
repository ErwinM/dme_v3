; lets test paging (lol)

ldi r1, 1
wptb r1
ld16 r2, 0x800
wpte r1, r2

; turn on paging
lcr r1
ori r1, r1, 4
scr r1