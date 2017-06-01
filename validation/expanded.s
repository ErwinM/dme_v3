;
; group l, test 1
;
; shl, shr, shl.r, shr.r
;






ldi r2, 0x11
ldi r1, char @l
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x01
stb.b 0(r2), r1


; declare symbols here
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)

; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   shl, shr
    ld16   	r1,0x5555
    shl			r3, r1, 1
    ld16		r2, 0xaaaa
		addskp.z r2, r3, r2
    br fail
br next0
hlt

next0:
		shr			r3, r3, 1
		addskp.z r2, r3, r1
		br fail
br next1
hlt


next1:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   shl, shr 16 bits
    ld16    r1,0xffff
    shr			r1, r1, 15
    addskpi.z r1, r1, 1
    br fail
br next2
hlt

next2:
;		shifting 0 src
		ldi 		r1, 1
    shl			r1, r1, 3
		addskpi.z r1, r1, 8
		br fail
br next3
hlt


next3:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   shl - shifting in 0
    ld16   	r1,0x55
    shl			r1, r1, 8
		ld16 		r2, 0x5500
		addskp.z	r2, r1, r2
		br fail
br next4
hlt


next4:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

; shl.r, shr,r
    ld16   	r1,0x5555
		ldi			r6, 1
    shl.r			r3, r1, r6
    ld16		r2, 0xaaaa
		addskp.z r2, r3, r2
    br fail
br next5
hlt

next5:
		ldi 		r6, 1
		shr.r		r3, r3, r6
		addskp.z r2, r3, r1
		br fail
br pass
hlt




;   Finally, when done branch to pass
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

