; brk test program
; simple counter

	mov r1, r0
	ldi r1, 1
	ldi r2, 0x10
loop:
	addi r1, r1, 1
	addskp.z r3, r1, r2
	br loop

	brk
	ldi r2, 0x12

loop2:
	addi r1, r1, 1
	addskp.z r3, r1, r2
	br loop2
	hlt
