;
; group l, test 1
;
; shl, shr, shl.r, shr.r
;

include(tmacros.h)

INIT_TEST(l,0x01)

; declare symbols here
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)

; Begin test here

SUBTEST(1)

;   shl, shr
    ld16   	r1,0x5555
    shl			r3, r1, 1
    ld16		r2, 0xaaaa
		addskp.z r2, r3, r2
    PASS(next0)
next0:
		shr			r3, r3, 1
		addskp.z r2, r3, r1
		PASS(next1)

next1:
SUBTEST(2)
;   shl, shr 16 bits
    ld16    r1,0xffff
    shr			r1, r1, 15
    addskpi.z r1, r1, 1
    PASS(next2)
next2:
;		shifting 0 src
		ldi 		r1, 1
    shl			r1, r1, 3
		addskpi.z r1, r1, 8
		PASS(next3)

next3:
SUBTEST(3)
;   shl - shifting in 0
    ld16   	r1,0x55
    shl			r1, r1, 8
		ld16 		r2, 0x5500
		addskp.z	r2, r1, r2
		PASS(next4)

next4:
SUBTEST(4)
; shl.r, shr,r
    ld16   	r1,0x5555
		ldi			r6, 1
    shl.r			r3, r1, r6
    ld16		r2, 0xaaaa
		addskp.z r2, r3, r2
    PASS(next5)
next5:
		ldi 		r6, 1
		shr.r		r3, r3, r6
		addskp.z r2, r3, r1
		PASS(pass)



;   Finally, when done branch to pass
    END_TEST
