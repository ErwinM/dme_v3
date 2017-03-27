;
; group d, test 1
;
; 8-bit memory loads
;

include(tmacros.h)

INIT_TEST(d,0x01)

INIT_MEM

; declare labels here
SYM(next0, d_001)
SYM(next1, d_001)
SYM(next2, d_001)
SYM(next3, d_001)
SYM(next4, d_001)


; Begin test here

SUBTEST(1)

;   BP w/ 16-bit positive offset

    la16   		r1, MEM0x80_8
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0x80
		addskp.z	r1, r1, r3
    PASS(next0)

next0:
		SUBTEST(2)

;   BP w/ 16-bit negative offset

    la16   		r1, MEM0x80_8
		ldi				r2, 60
    add				bp, r1, r2
		ldb				r3, -60(bp)
   	ldi				r1, 0x80
		addskp.z	r1, r1, r3
    PASS(next1)

next1:
		SUBTEST(3)
;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM0x7F_8
    ld16		r2, 500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    PASS(next2)

next2:
		SUBTEST(4)
;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM0x7F_8
    ld16		r2, 500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    PASS(next3)

next3:
		SUBTEST(5)
;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM0x7F_8
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    PASS(next4)

next4:
		SUBTEST(6)
;   idx(base) loading zero idx

    la16   	r1, MEM0x7F_8
		ldb			r3, 0(r1)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    PASS(pass)

;   Finally, when done branch to pass
END_TEST
