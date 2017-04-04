; little trap experiment

	ldi r1, 10
	br 	start
	br	handler
	hlt

start:
; lets do a random loop
	addi r2, r2, 2
	mov r3, r2
	br start


handler:
	ldi r5, 0xaa
	reti