runall_1:
;
; group f, test 1
;
; push/pop
;

include(tmacros.h)

.code 0x100

INIT_TEST(f,0x01)

; declare symbols here

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
		PASS(next0_f_001)

next0_f_001:
		; value is in the right spot
		mov 		r2, sp
		ldw			r3, 0(r2)
    skip.eq r3, r1
    PASS(next1_f_001)

SUBTEST(2)
next1_f_001:
		pop	    r2
		; pop produces the right value
		skip.eq	r2, r1
    PASS(next2_f_001)
next2_f_001:
		ld16 r3, 0x2000
		skip.eq r3, sp
PASS(runall_2)
;   Finally, when done branch to pass
runall_2:
;
; group f, test 2
;
; lcr, scr



INIT_TEST(f,0x02)

; declare symbols here


; load control register into R1
; only IRQ should be enabled (value 8)
brk
	lcr r1
	addskpi.z r2, r1, 8
	PASS(next1_f_002)

next1_f_002:
; disable IRQ by loading a new value into CR
	scr r0
	lcr r1
	addskp.z r2, r1, r0
	PASS(pass)

;   Finally, when done branch to pass
  END_TEST
