;
; group e, test 1
;
; 8-bit memory stores
; Byte enable function

include(tmacros.h)

INIT_TEST(e,0x01)

; declare symbols here
SYM(next0, e_001)
SYM(next1, e_001)
SYM(next2, e_001)
SYM(next3, e_001)
SYM(next4, e_001)
SYM(next5, e_001)
SYM(next6, e_001)
SYM(next7, e_001)
SYM(next8, e_001)
SYM(next9, e_001)

; set up data

MEM_0xAAAA:
	defw 0xaaaa
MEM_0xBBBB:
	defw 0xbbbb
MEM_0xCCCC:
	defw 0xcccc
MEM_0xDDDD:
	defw 0xdddd

; Begin test here

SUBTEST(1)

;   bp w/ s7 offset

    la16   	r1, 0x800
    ld16		r2, 48
		sub	    bp, r1, r2
    ldi	    r1, 0x80
    stb	    48(bp), r1
    ldb    	r2, 48(bp)
    addskp.z r2, r1, r2
    PASS(next0)

next0:

SUBTEST(2)

;   bp w/ base, idx

		la16   	r1, 0x800
		ld16		r2, 513
		sub	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    r2(bp), r1
		ldb    	r3, r2(bp)
		addskp.z r2, r1, r3
		PASS(next1)


next1:

SUBTEST(3)

;   bp w/ s7 offset
;		make sure byte enable is correctly preserving LOW byte

		la16   	r1, MEM_0xAAAA
		ld16		r2, 32
		add	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    -32(bp), r1
		ldb    	r3, -32(bp)
		addskp.z r2, r1, r3
		PASS(next2)

		; check if the low byte is preserved
next2:
		ldb r3, -31(bp)
		ldi r1, 0xaa
		addskp.z r1, r1, r3
		PASS(next3)


next3:
SUBTEST(4)

;   bp w/ s7 offset
;		make sure byte enable is correctly preserving HIGH byte

		la16   	r1, MEM_0xBBBB
		ld16		r2, 32
		add	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    -31(bp), r1
		ldb    	r3, -31(bp)
		addskp.z r2, r1, r3
		PASS(next4)

		; check if the high byte is preserved
next4:
		ldb r3, -32(bp)
		ldi r1, 0xbb
		addskp.z r1, r1, r3
		PASS(next5)

next5:

		SUBTEST(5)

;   bp w/ index base
;		make sure byte enable is correctly preserving LOW byte

		la16   	r1, MEM_0xCCCC
		ld16		r2, 0x200
		sub	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    r2(bp), r1
		ldb    	r3, r2(bp)
		addskp.z r3, r1, r3
		PASS(next6)

		; check if the low byte is preserved
next6:
		addi	r2, r2, 1
		ldb r3, r2(bp)
		ldi r1, 0xcc
		addskp.z r1, r1, r3
		PASS(next7)


next7:
SUBTEST(6)

;   bp w/ index base
;		make sure byte enable is correctly preserving HIGH byte

		la16   	r1, MEM_0xDDDD
		ld16		r2, 0x200
		sub	    bp, r1, r2
		addi		r4, r2, 1
		ldi	    r1, 0x80
		stb	    r4(bp), r1
		ldb    	r3, r4(bp)
		addskp.z r3, r1, r3
		PASS(next8)

		; check if the high byte is preserved
next8:
		ldb r3, r2(bp)
		ldi r1, 0xdd
		addskp.z r1, r1, r3
		PASS(pass)


;   Finally, when done branch to pass
    END_TEST
