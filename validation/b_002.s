;
; group b, test 2
;
; 16-bit load immediate
;

include(tmacros.h)

INIT_TEST(a, 0x2)

SUBTEST(1)

SYM(next1, b_002)
SYM(next2, b_002)

;   Mostly tested already in group_a, but go ahead and do some more

		ld16   		r1,0x1234
    ld16   		r2,0x1235
		subi			r2, r2, 1
		addskp.z 	r1, r1, r2
		PASS(next1)

next1:
		ldi r4, 1
		ld16   		r2,0x4433
    mov    		r1,r2
    addskp.z	r1, r1, r2
		PASS(next2)

next2:
    ldi r4, 2
		ld16   		r3,0x4321
    mov 	   	r5,r3
    addskp.z	r1, r3, r5
		PASS(pass)

;next2:


;   Finally, when done branch to pass
    END_TEST
