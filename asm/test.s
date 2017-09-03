_mult:
	ld16 r2, 0x800 ; op1
	ld16 r3, 0x1e    ; op2
	mov r1, r0     ; result reg

; if a > b
	skip.gt r2, r3
	br multL2
; switch them
	mov r4, r2
	mov r2, r3
	mov r3, r4

multL2:
; while r1 > 1 loop
	ldi r4, 1
	skip.gt r2, r4
	br multL3
; check if r1 is even/odd
	andi r4, r2, 1
	skip.eq r4, r0
	add r1, r1, r3
	shr r2, r2, 1
	shl r3, r3, 1
	br multL2
multL3:
	andi r4, r2, 1
	skip.eq r4, r0
	add r1, r1, r3
	hlt