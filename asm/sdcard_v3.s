; http://e2e.ti.com/support/microcontrollers/hercules/f/312/p/206181/995168#995168

; Ok, I figured it out.
;
; Apparently I wasn't getting )xFF's I was getting 0x01's (though it seemed like 0xFF's on the oscilloscope).
;
; The problem was I was using a SDHC (high capacity card) which requires additional instructions to initialize.
;
; The sequence was this:
;
; Send CMD0
;
; Send CMD8 with argument 0x000001AA and checksum 0x87 (which is for SDC V2)
;
; Send CMD55
;
; Send ACMD41 with argument 0x40000000 (default checksum 0x95)
;
; Send CMD16 with argument 512 for block length
;
; Send CMD59 to disable CRC

; INIT controller
la16 r3, 0xffa0
mov bp, r3
; clear errors
la16 r1, 0x8000
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy

ldi r1, 9  ; divider
stw 6(bp), r1 ; save divider in data
la16 r1, 0x0ff
stw 2(bp), r1 ; issue SD_SETAUX command

; Start INIT SDcard

; Send CMD0
stw 6(bp), r0
ldi r1, 0x40
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy

; Send CMD8 with argument 0x000001AA and checksum 0x87 (which is for SDC V2)
;ldi r1, 0x01aa
;stw 6(bp), r1
ldi r1, 0x48
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy

; Send CMD55
;
; Send ACMD41 with argument 0x40000000 (default checksum 0x95)
ldi r1, 0x77
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy
brk
la16 r1, 0x4000
stw 4(bp), r1
stw 5(bp), r0
ldi r1, 0x69
addi sp, pc, 2
br wait_while_busy
brk
; Send CMD16 with argument 512 for block length
la16 r1, 512
stw 6(bp), r1
ldi r1, 0x50
stw 2(bp), r1
addi sp, pc, 2
br wait_while_busy
brk
; Send CMD59 to disable CRC
ldi r1, 0x7b
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