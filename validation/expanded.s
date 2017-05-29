;
; group f, test 1
;
; push/pop
;





.code 0x100


ldi r2, 0x11
ldi r1, char @f
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x01
stb.b 0(r2), r1


; declare symbols here
;SYM(next0)
;SYM(next1)
;SYM(next2)

; setup stack pointer
		ld16 	r1, 0x2000
		mov 	r6, r1


; Begin test here


; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

; Push/pop

    ld16    r1,0x1234
    push    r1
		; track sp change
		ld16   	r3, 0x1ffe
		addskp.z r2, sp, r3
		br fail
br next0
hlt


next0:
		; value is in the right spot
		mov 		r2, sp
		ldw			r3, 0(r2)
    addskp.z r3, r3, r1
    br fail
br next1
hlt


; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

next1:
		pop	    r2
		; pop produces the right value
		addskp.z	r3, r2, r1
    br fail
br next2
hlt

next2:
		ld16 r3, 0x2000
		addskp.z r3, r3, sp
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

