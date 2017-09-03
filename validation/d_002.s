;
; group d, test 2
;
; 16-bit memory loads
;

include(tmacros.h)

INIT_TEST(d,0x02)

INIT_MEM

; declare labels here
;SYM(next0, d_002)
;SYM(next1, d_002)
;SYM(next2, d_002)
;SYM(next3, d_002)
;SYM(next4, d_002)
;
; Begin test here

SUBTEST(1)

;   BP w/ 16-bit positive offset

    la16   		r1, MEM0x8000_16
		ldi				r2, 45
    sub				bp, r1, r2
		ldw				r3, 45(bp)
   	ld16			r1, 0x8000
		skip.eq	  r1, r3
    PASS(next0)

next0:
		SUBTEST(2)

;   BP w/ 16-bit negative offset

    la16   		r1, MEM0x8000_16
		ldi				r2, 45
    add				bp, r1, r2
		ldw				r3, -45(bp)
   	ld16			r1, 0x8000
		skip.eq	  r1, r3
    PASS(next1)

next1:
		SUBTEST(3)
;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM0x7FFF_16
    ld16		r2, 250
		sub			r3,	r1, r2
		ldw			r3, r2(r3)
		ld16		r1, 0x7fff
		skip.eq	r1, r3
    PASS(next2)


next2:
		SUBTEST(4)
;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM0x7FFF_16
    ld16		r2, -250
		sub			r3,	r1, r2
		ldw			r3, r2(r3)
		ld16		r1, 0x7fff
		skip.eq r1, r3
    PASS(next3)

next3:
		SUBTEST(5)
;   idx(base) loading zero idx

    la16   	r1, MEM0x7FFF_16
		ldw			r3, 0(r1)
		ld16			r1, 0x7fff
		skip.eq  r1, r3
    PASS(pass)

;   Finally, when done branch to pass
END_TEST
