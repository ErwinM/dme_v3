;
; group s, test 5
;
; skip.c - eq/ne





; declare symbols here
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)
;SYM(next4)
;SYM(next5)
;SYM(next6)


; Begin test here

; subtest definition (tmacros)
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   skip.eq
		ldi		r1, 0xaa
		skip.eq r1, r1
		br fail
br next0
hlt


next0:
		skip.eq r1, r0
		br next1
		br fail

next1:
; subtest definition (tmacros)
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   skip.eq with 0
		ldi r1, 0xaa
		mov	r2, r0
		skip.eq r2, r0
		br fail
br next2
hlt


next2:
		skip.eq r2, r1
		br next3
		br fail

next3:
; subtest definition (tmacros)
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   skip.ne
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		skip.ne r2, r1
		br fail
br next4
hlt


next4:
		skip.ne r1, r1
		br next5
		br fail

next5:
; subtest definition (tmacros)
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   skip.ne with 0
		ldi 	r1, 0xaa
		mov		r2, r0
		skip.ne r1, r2
		br fail
br next6
hlt


next6:
		skip.ne r2, r2
		br pass
		br fail

;   Finally, when done branch to pass
    pass:
	ld16 r3, 0xff80
	ldi r5, 0xAA
	stw 0(r3), r5
  hlt

fail:
	ldi r1, char @s
	ldi r2, 0x5
	ld16 r3, 0xff80
	ldi r5, 0xFF
	stw 0(r3), r5
  hlt

