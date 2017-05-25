;
; group 3, test 3
;
; 16-bit load immediate using signed extended 8-bit immediate
;

include(tmacros.h)

INIT_TEST(b,0x03)

; declare symbols here
;SYM(next0, b_003)
;SYM(next1, b_003)
;SYM(next2, b_003)
;SYM(next3, b_003)
;SYM(next4, b_003)

SUBTEST(1)

; Now, put actual test code here....

    ; zero extended
    ld16   		r1,0x1234
    ld16   		r1,0x34
    ld16			r2,0x34
		addskp.z r1, r1, r2
    PASS(next0)

    ; 1 extended
next0:
    ld16 		  r1,0x1284
    ld16   		r1,-1
		ld16			r2, 0xffff
		addskp.z	r1, r2, r1
		PASS(next1)

next1:
		; signed arithmetic from registers
   	ld16  r1 , 1
   	ld16  r2 , -1
   	addskp.nz	r4, r1, r2
   	PASS(next2)

		; signed arithmetic from IR immediate
next2:
		ld16 r1, -1
		addskpi.z r4, r1, -1
		PASS(next3)

next3:
		; zero extended to reg
   	ld16  r1 ,0x1234
   	ld16  r1 ,0x34
		ld16	r2, 0x0034
   	addskp.z	r4, r1, r2
   	PASS(next4)

		; sign extension copied correctly
next4:
    ld16  r3 ,-1
    mov   r1, r3
   	addskp.z	r4, r1, r3
   	PASS(pass)


;   Finally, when done branch to pass
END_TEST
