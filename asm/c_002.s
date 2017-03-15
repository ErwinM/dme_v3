;
; group 2, test 2
;
; signed arithmetic
;

; m4_include(..\tmacros.h)

; INIT_TEST(b,0x03)

; declare symbols here
;    SYM(next0)
;    SYM(next1)
;    SYM(next2)
;    SYM(next3)
;    SYM(next4)

; SUBTEST(1)

; Now, put actual test code here....

		; signed arithmetic from registers
   	ld16  r1 , 1
   	ld16  r2 , -1
   	addskp.nz	r4, r1, r2
   	br fail
		br next1
		hlt

		; signed arithmetic from IR immediate
next1:
		ld16 r1, -1
		addskpi.z r4, r1, -1
		br fail
		br pass
		hlt

fail:
	ldi r5, 0xff
	hlt

pass:
	ldi r5, 0xaa
	hlt
