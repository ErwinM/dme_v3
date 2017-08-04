ld16 r2, 0xffff
ld16 r3, 0xfffe



_mod:
	ldi r4, 1
modL1:
	skip.ult r3, r2
	br modL2
	shl r3, r3, 1
	shl r4, r4, 1
	br modL1

modL2:
	addskpi.nz r0, r4, -1
	br modL3
	shr r3, r3, 1
	shr r4, r4, 1

	skip.ulte r3, r2
	br modL2
	sub r2, r2, r3
	br modL2

modL3:
	mov r1, r2
	br.r bp ; return