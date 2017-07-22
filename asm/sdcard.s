#define SD_CMD 0x040
#define SD_CLEARERR 0x8000
#define SD_SETAUX 0x0ff
#define SD_READAUX 0x0bf

#define SDCMD_REG_HIGH		0x0
#define SDCMD_REG_LOW			0x2
#define SDDATA_REG_HIGH		0x4
#define SDDATA_REG_LOW		0x6


; INIT controller
la16 r3, 0xffa0
mov bp, r3
; clear errors
la16 r1, SD_CLEARERR
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy

ldi r1, 9  ; divider
stw 6(bp), r1 ; save divider in data
la16 r1, SD_SETAUX
stw 2(bp), r1 ; issue SD_SETAUX command

; Start INIT SDcard

; DATA = 0;
; CMD = SD CMD+0
; SD WAIT WHILE BUSY;
stw 6(bp), r0
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

; DATA = 0x1aa;
; CMD = SD CMD+8;
; SD WAIT WHILE BUSY;
la16 r1, 0x1a5
stw 6(bp), r1
la16 r1, 0x48
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy
brk

; DATA = 0x4000 0000
; CMD = SD CMD+1
; SD WAIT WHILE BUSY;
la16 r1, 0x77 ; cmd55
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
hlt
hlt


wait_while_busy:
	ldw r1, 2(bp)
	la16 r2, 0x4000
	and r4, r1, r2
	skip.eq r4, r2
	br.r sp
	br wait_while_busy