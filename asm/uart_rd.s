; init
	la16 r4, 0xff90	; uart offset
	mov r5, r4
	mov r1, r0
	stw 1(bp), r1   ; port + 1 0x00 - disable all interrupts
	ldi r1, 0x80
	stw 3(bp), r1   ; port + 3 0x80 enable dlab
	ldi r1, 32
	stw 0(bp), r1		; port + 0 set divisor to 1 LSB
	ldi r1, 0
	stw 1(bp), r1		; port + 1 set divisor to 1 MSB
	ldi r1, 3
	stw 3(bp), r1		; port + 3 set LCR - validate

	ldi r3, 0x64		; set mem ptr for read

wait_for_byte:
	ldb r1, 5(bp)		; read LSR
	andi r2, r1, 1	; check for bit 0: Data Ready
	addskpi.z r2, r2, 1
	br wait_for_byte
	ldb r4, 0(r5)		; get the byte
	stb.b 0(r3), r4 ; store read byte
	addi r3, r3, 1
	br wait_for_byte