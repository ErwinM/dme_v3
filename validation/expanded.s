; Test trap mechanisms:
; - wivec
; - syscall
; - push.u
; - reti






; setup trap vector
la16 r1, irq_handler
wivec r1

; setup a register context and trigger syscall
ldi r1, 0x12
ldi r2, 0x34
ldi r3, 0x56
ldi r4, 0x78
ldi r5, 0x9a
ldi r6, 0xbc

syscall
ldi r2, 0x12
addskp.z r1, r1, r2
br fail
br pass
hlt



irq_handler:
	la16 r2, 0x1000
	mov sp, r2

; push registers from user space
	push.u r1 ; sp 12
	push.u r2 ; sp 10
	push.u r3 ; sp 8
	push.u r4 ; sp 6
	push.u r5 ; sp 4
	push.u r6 ; sp 2
	push.u pc ; sp




; check if the correct values have been pushed
	mov bp, sp
	ldw r1, 2(bp)
	ldi r2, 0xbc
	addskp.z r1, r1, r2
	br fail

	ldw r1, 4(bp)
	ldi r2, 0x9a
	addskp.z r1, r1, r2
	br fail

	ldw r1, 6(bp)
	ldi r2, 0x78
	addskp.z r1, r1, r2
	br fail

	ldw r1, 8(bp)
	ldi r2, 0x56
	addskp.z r1, r1, r2
	br fail

	ldw r1, 10(bp)
	ldi r2, 0x34
	addskp.z r1, r1, r2
	br fail

	ldw r1, 12(bp)
	ldi r2, 0x12
	addskp.z r1, r1, r2
	br fail

	ld16 r1, 0xdead
	; return and check if original register values are preserved
	brk
	reti


; Finally, when done branch to pass
	pass:
	ld16 r3, 0xff80
	ldi r5, 0xAA
	stw 0(r3), r5
  hlt

fail:
	ld16 r3, 0xff80
	ldi r5, 0xFF
	stw 0(r3), r5
  hlt

