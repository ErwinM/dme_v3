; bootloader version 0.1


; setup stack
	la16 r1, 0x1800
	mov r6, r1

init_uart:
	la16 r1, 0xff90
	mov r5, r1
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

_main:
	la16 r4, welcome
	addi r1, pc, 4	; setup return addr
	push r1
	br wr_string
	la16 r4, loading_msg
	addi r1, pc, 4	; setup return addr
	push r1
	br wr_string

	brk
	mov r3, r0
	addi r1, pc, 4
	push r1
	br wait_for_byte
	ldi pc, 0


_exit:
	la16 r1, 0xff80
	ldi r2, 0xaa
	stw 0(r1), r2
	hlt



wait_for_byte:
	ldb r1, 5(bp)		; read LSR
	andi r2, r1, 1	; check for bit 0: Data Ready
	addskpi.z r2, r2, 1
	br wait_for_byte
	ldb r4, 0(r5)		; get the byte
	stb.b 0(r3), r4 ; store read byte
	addi r3, r3, 1
	br wait_for_byte

_exit_wait_for_byte:
	pop r1
	br.r r1


wr_string:
	; pointer to str in r5
	mov r3, r0
wr_string_loop:
	addi r1, pc, 4
	push r1
	br check_tx_free

	ldb r2, r3(r4)				; load the char
	addskp.nz r1, r2, r0 	; check for null terminator
	br wr_string_return
	stb 0(r5), r2					; write the char
	addi r3, r3, 1
	br wr_string_loop

wr_string_return:
	pop r1
	br.r r1

check_tx_free:
	ldw r1, 5(bp)
	ldi r2, 0x60
	and r1, r1, r2
	addskp.z r2, r2, r1
	br check_tx_free
	pop r1
	br.r r1
	ldi r5, 0xff
	hlt


welcome:
	defb 0xff
	defstr "Welcome to DME Bootloader"

loading_msg:
	defb 0xa
	defb 0xd
	defstr "Waiting for program over serial..."
result:
	defs 20