; test to see if traps during trap handling are buffered

; setup stack
	ld16 r1, 0x1000
	mov sp, r1

	ldi r1, inthandler
	wivec r1


; get to user space
backtouser:
	la16 r1, userstart
	push r1
	pop.u pc
	reti
	hlt

userstart:
	ldi r4, 0xaa
	syscall

inthandler:
	mov r1, r0
	ld16 r2, 100
doloop:
	addi r1, r1, 1
	skip.eq r1,r2
	br doloop
	br backtouser
