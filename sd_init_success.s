; INIT controller
la16 r3, 0xffa0
mov bp, r3
; clear errors
la16 r1, 0x8000
stw 2(bp), r1
addi sp, pc, 2

ldi r1, 9  ; divider
stw 6(bp), r1 ; save divider in data
la16 r1, 0x0ff
stw 2(bp), r1 ; issue SD_SETAUX command

; Start INIT SDcard

; CMD0
ldi r1, 0x40
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy

la16 r1, 0x4000
stw 4(bp), r1
stw 6(bp), r0
la16 r1, 0x41
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy

brk

; CMD8
la16 r1, 0x1a5
stw 6(bp), r1
ldi r1, 0x48
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy

brk


; Loop CMD 55 + CMD ACMD41 with HCS 1
get_out_of_idle:
	ldi r1, 0x77
	stw 2(bp), r1
	addi sp, pc, 2
	br wait_while_busy

	la16 r1, 0x4000
	stw 4(bp), r1
	stw 6(bp), r0
	la16 r1, 0x69
	stw 2(bp), r1
	addi sp, pc, 2
	br wait_while_busy

	;la16 r1, 0x1a5
	;stw 6(bp), r1
	;ldi r1, 0x48
	;stw 2(bp), r1
	;addi sp, pc, 2
	;br wait_while_busy

	ldw r1, 2(bp)
	andi r1, r1, 1
	skip.eq r1, r0
	br get_out_of_idle
	ldi r5, 0xaa
	hlt


wait_while_busy:
	ldw r1, 2(bp)
	la16 r2, 0x4000
	and r4, r1, r2
	skip.eq r4, r2
	br.r sp
	br wait_while_busy