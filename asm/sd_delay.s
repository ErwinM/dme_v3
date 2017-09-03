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


; CMD8
la16 r1, 0x1a5
stw 6(bp), r1
ldi r1, 0x48
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy



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

;void read(int sector num, int *buf) {
;	// Set the FIFO length to 128 words, 27.
; DATA = 0x0700;
;	CMD = SD SETAUX;
; // Read from the reqeusted sector
;	DATA = sector num;
;	CMD = SD READ SECTOR;
; SD WAIT WHILE BUSY;
; for(int i=0; i<128; i++)
;  buf[i] = FIFO[0];

la16 r1, 0x0700
stw 6(bp), r1
la16 r1, 0x0ff
ldi r1, 1
stw 6(bp), r1
la16 r1, 0x8851
stw 2(bp), r1
addi sp, pc, 2
mov r3, r0
br count_while_busy
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


count_while_busy:
	addi r3, r3, 1
	ldw r1, 2(bp)
	la16 r2, 0x4000
	and r4, r1, r2
	skip.eq r4, r2
	hlt
	br count_while_busy