;
; group 3, test 3
;
; 16-bit load signed immediates
;

; m4_include(..\tmacros.h)

; INIT_TEST(b,0x03)

; declare symbols here
;    SYM(next0)
;    SYM(next1)
;    SYM(next2)
;    SYM(next3)
;    SYM(next4)

;SUBTEST(1)

; Now, put actual test code here....

		; zero extended to reg
   	ld16  r1 ,0x1234
   	ld16  r1 ,0x34
		ld16	r2, 0x0034
   	addskp.z	r4, r1, r2
   	br fail
		br next1
		hlt

		; 1 extended to reg
next1:
    ld16  r1,0x1284
    ld16  r1, -1
		ld16	r2, -1
   	addskp.z	r4, r1, r2
   	br fail
		br pass
		hlt

		; sign extension copied correctly
next3:
    ld16  r3 ,0x1
    mov   r1, r3
   	addskp.z	r4, r1, r3
   	br fail
		br pass
		hlt

fail:
	ldi r5, 0xff
	hlt
	hlt

pass:
	ldi r5, 0xaa
	hlt