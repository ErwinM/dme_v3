	la16 r4, 0xff90
	mov r5, r4
	mov r1, r0
	stw 1(bp), r1   ; port + 1 0x00 - disable all interrupts
	ldi r1, 0x80
	stw 3(bp), r1   ; port + 3 0x80 enable dlab
	ldi r1, 52
	stw 0(bp),r1		; port + 0 set divisor to 1 LSB
	ldi r1, 0
	stw 1(bp), r1		; port + 1 set divisor to 1 MSB
	ldi r1, 3
	stw 3(bp), r1		; port + 3 set LCR - validate
	brk
	ldi r1, char 'e'
	stw 0(r5),r1
check_tx_free:
	ldw r1, 5(bp)   ; offset of LSR
	ldi r2, 0x61
	skip.eq r2, r1
	br check_tx_free
	ldi r1, char 'r'
	stw r0(bp),r1		; port set transport byte
	hlt
	hlt
