; init
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

	; read LSR to reset
	ldw r1, 5(r5)

	; go into infinite loop
halt:
	br halt