; INIT controller
la16 r3, 0xffa0
mov bp, r3

ldi r1, 47
stw 6(bp), r1
la16 r1, 0x8851
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy
brk
ldw r1, 8(bp)
ldw r2, 10(bp)
ldw r3, 8(bp)
ldw r4, 10(bp)
hlt



;DATA = 0;
;CMD = (SD READREG|SD CMD)+58; SD WAIT WHILE BUSY;
;OCR = DATA;
;
;stw 6(bp), r0
;la16 r1, 0x27a
;stw 2(bp), r1
;addi sp, pc, 2
;br wait_while_busy
;brk
;ldw r1, 4(bp)
;ldw r2, 6(bp)
;hlt
;
;
;

wait_while_busy:
	ldw r1, 2(bp)
	la16 r2, 0x4000
	and r4, r1, r2
	skip.eq r4, r2
	br.r sp
	br wait_while_busy