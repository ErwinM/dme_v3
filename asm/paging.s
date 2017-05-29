; lets test paging (lol)


ldi r1, 1
wpte r0, r1
ld16 r2, 3
shl r2, r2, 8
ori r2, r2, 1
ori r2, r2, 2
wpte r1, r2
lpte r4, r1

; turn on paging
lcr r1
ori r1, r1, 4
scr r1

; address something high
la16 r3, 0x810
la16 r1, iets
ldw r1, r0(r1)
stw r0(r3), r1
hlt


iets:
	defw 0xbabe