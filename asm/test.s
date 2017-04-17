; lets test paging (lol)

wpte r0, r0
ldi r1, 1
ld16 r2, 2
shl r2, r2, 8
wpte r1, r2
lpte r4, r1

; turn on paging
lcr r1
ori r1, r1, 4
scr r1

; address something high
la16 r2, 0x810
ldw r1, r0(r2)

