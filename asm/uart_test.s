	la16 r4, 0xff90
	mov r5, r4
	mov r1, r0
	stw r1, 1(r5)   ; port + 1 0x00 - disable all interrupts
	ldi r1, 0x80
	stw r1, 3(r5)   ; port + 3 0x80 enable dlab
	ldi r1, 32
	stw r1, 0(r5)		; port + 0 set divisor to 1 LSB
	ldi r1, 0
	stw r1, 1(r5)		; port + 1 set divisor to 1 MSB
	ldi r1, 3
	stw r1, 3(r5)		; port + 3 set LCR - validate
	ldi r1, char 'e'
	stw r1, 0(r5)		; offset of LSR
check_tx_free:
	ldw r1, 5(r5)
	ldi r2, 0x61
	addskp.z r2, r2, r1
	br check_tx_free
	ldi r1, char 'r'
	stw r1, 0(r5)		; port set transport byte
	hlt
	hlt
