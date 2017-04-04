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
	ldi r1, char 'e'
	stw 0(bp), r1		; offset of LSR
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'r'
	stw 0(bp), r1		; port set transport byte
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'w'
	stw 0(bp), r1		; port set transport byte
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'i'
	stw 0(bp), r1		; port set transport byte
	addi r4, pc, 2
	br check_tx_free
	ldi r1, char 'n'
	stw 0(bp), r1		; port set transport byte
	ldi bp, 0xaa
	hlt
	hlt

check_tx_free:
	ldw r1, 5(bp)
	ldi r2, 0x60
	addskp.z r2, r2, r1
	br check_tx_free
	br.r r4
	ldi bp, 0xff
	hlt
