


	ldi r1, -3
	la16 r2, -2
	mov r4, r0

; if a > b
	skip.gt r1, r2
	br L2
; switch them
	mov r3, r1
	mov r1, r2
	mov r2, r3

L2:
; while r1 > 1 loop
	ldi r3, 1
	skip.gt r1, r3
	br L3
; check if r1 is even/odd
	andi r3, r1, 1
	addskpi.nz r3, r3, 1
	add r4, r4, r2
	shr r1, r1, 1
	shl r2, r2, 1
	br L2
L3:
	andi r3, r1, 1
	addskpi.nz r3, r3, 1
	add r4, r4, r2
	hlt