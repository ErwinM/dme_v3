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

    ; zero extended to r1
    ldi   r1, 0x1ff
    addhi r1 ,0x07f
