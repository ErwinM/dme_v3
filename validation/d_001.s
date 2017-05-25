;
; group d, test 1
;
; 8-bit memory loads
;

include(tmacros.h)

INIT_TEST(d,0x01)

; declare labels here
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)
;SYM(next4)
;SYM(next5)
;SYM(next6)
;SYM(next7)
;SYM(next8)
;SYM(MEM_0xAA_8)
;SYM(MEM_0xABCD_16)
; set up data

MEM_0xAA_8:
	defw 0xaaff

MEM_0xABCD_16:
	defw 0xabcd


; Begin test here

SUBTEST(1)

;   BP w/ 7s positive offset

    la16   		r1, MEM_0xAA_8
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next0)

next0:
		SUBTEST(2)

;   BP w/ 7s negative offset

    la16   		r1, MEM_0xAA_8
		ldi				r2, 60
    add				bp, r1, r2
		ldb				r3, -60(bp)
   	ldi				r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next1)

next1:
		SUBTEST(3)
;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM_0xAA_8
    ld16		r2, 500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next3)


next3:
		SUBTEST(4)
;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM_0xAA_8
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next4)

next4:
		SUBTEST(5)
;   idx(base) loading zero idx

    la16   	r1, MEM_0xAA_8
		ldb			r3, 0(r1)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next5)


next5:
		SUBTEST(6)

;   BP w/ 7s positive offset
;		get high byte

    la16   		r1, MEM_0xABCD_16
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0xab
		addskp.z	r1, r1, r3
    PASS(next6)

next6:
		SUBTEST(7)

;   BP w/ 7s positive offset
;		get low byte

    la16   		r1, MEM_0xABCD_16
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 61(bp)
   	ldi				r1, 0xcd
		addskp.z	r1, r1, r3
    PASS(next7)

next7:
		SUBTEST(8)
;   idx(base) loading with negative 16-bit idx
;		get high byte

    la16   	r1, MEM_0xABCD_16
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xab
		addskp.z	r1, r1, r3
    PASS(next8)

next8:
		SUBTEST(9)
;   idx(base) loading with negative 16-bit idx
;		get low byte

    la16   	r1, MEM_0xABCD_16
    ld16		r2, 500
		sub			r3,	r1, r2
		addi		r2, r2, 1
		ldb			r3, r2(r3)
		ldi			r1, 0xcd
		addskp.z	r1, r1, r3
    PASS(next9)

next9:
		SUBTEST(10)
;   storing a word, loading a byte...
; 	storing a byte with a word instruction stores the byte
;   in the low byte -> essentially 1 address higher

    la16   	r1, MEM_0xABCD_16
    ldi			r2, 0xee
		stw			r0(r1), r2
		addi		r1, r1, 1
		ldb			r3, r0(r1)
		addskp.z	r1, r2, r3
    PASS(pass)


;   Finally, when done branch to pass
END_TEST
