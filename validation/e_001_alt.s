;
; group e, test 1
;
; 8-bit memory stores
; Byte enable function

include(tmacros.h)


; declare symbols here
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)
;SYM(next4)
;SYM(next5)
;SYM(next6)
;SYM(next7)
;SYM(next8)
;SYM(next9)

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



;   bp w/ s7 offset
;		make sure byte enable is correctly preserving LOW byte
		;brk
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
