ld16 r1, 0x8000 ; -24k
ld16 r2, 0x1 ; -20k
skip.lt r1, r2 ; r1 is smaller than r2
br fail
ldi r5, 0xaa
hlt

fail:
ldi r5, 0xff
hlt


