	la16 r4, 0x0ff0	; uart offset
	mov r5, r4
	mov r1, r0
	stw 1(r5), r1   ; port + 1 0x00 - disable all interrupts
	ldi r1, 0x80
	stw 3(r5), r1   ; port + 3 0x80 enable dlab
	ldi r1, 32
	stw 0(r5), r1		; port + 0 set divisor to 1 LSB
	ldi r1, 0
	stw 1(r5), r1		; port + 1 set divisor to 1 MSB
	ldi r1, 3
	stw 3(r5), r1		; port + 3 set LCR - validate
	ldi r1, char 'e'
	stw 0(r5), r1		; offset of LSR
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'r'
	stw 0(r5), r1		; port set transport byte
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'w'
	stw 0(r5), r1		; port set transport byte
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'i'
	stw 0(r5), r1		; port set transport byte
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'n'
	stw 0(r5), r1		; port set transport byte
	ldi r5, 0xaa
	hlt
	hlt

check_tx_free:
	ldw r1, 5(r5)
	ldi r2, 0x61
	addskp.z r2, r2, r1
	br check_tx_free
	br.r r4
	ldi r5, 0xff
	hlt
