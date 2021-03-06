;
; group f, test 1
;
; push/pop
;

include(tmacros.h)

; declare symbols here
;SYM(next0)
;SYM(next1)
;SYM(next2)

; setup stack pointer
		ld16 	r1, 0x2000
		mov 	r6, r1


; Begin test here


SUBTEST(1)
; Push/pop

    ld16    r1,0x1234
    push    r1
		; track sp change
		ld16   	r3, 0x1ffe
		skip.eq sp, r3
		PASS(next0)

next0:
		; value is in the right spot
		mov 		r2, sp
		ldw			r3, 0(r2)
    skip.eq r3, r1
    PASS(next1)

SUBTEST(2)
next1:
		pop	    r2
		; pop produces the right value
		skip.eq	r2, r1
    PASS(next2)
next2:
		ld16 r3, 0x2000
		skip.eq r3, sp
		PASS(pass)

;   Finally, when done branch to pass
    END_TEST
