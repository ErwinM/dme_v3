;
; group f, test 1
;
; push/pop
;
; Note: Will not test machine control bits of MSW here - just ccodes
;

include(tmacros.h)

INIT_TEST(f,0x01)

; declare symbols here
SYM(next0)
SYM(next1)
SYM(next2)

; setup stack pointer
		ld16 	r1, 0x1000
		mov 	r6, r1


; Begin test here


SUBTEST(1)
; Push/pop

    ld16    r1,0x1234
    push    r1
		; track sp change
		ld16   	r3, 0xffe
		addskp.z r2, sp, r3
		PASS(next0)

next0:
		; value is in the right spot
		mov 		r2, sp
		ldw			r3, 0(r2)
    addskp.z r3, r3, r1
    PASS(next1)

SUBTEST(2)
next1:
		pop	    r2
		; pop produces the right value
		addskp.z	r3, r2, r1
    PASS(next2)
next2:
		ld16 r3, 0x1000
		addskp.z r3, r3, sp
		PASS(pass)

;next1:
;
;SUBTEST(2)
;; push/pop b
;
;    ld.16   b,0x1234
;    push    b
;    copy	    a,sp
;    cmpb.eq.16	a,0x6ffe,next2
;    FAIL
;next2:
;    pop	    a
;    cmpb.eq.16	a,0x1234,next3
;next3:
;
;SUBTEST(3)
;; push/pop dp
;
;    ld.16   a,0x1234
;    copy    dp,a
;    push    dp
;    copy	    a,sp
;    cmpb.eq.16	a,0x6ffe,next4
;    FAIL
;next4:
;    pop	    a
;    cmpb.eq.16	a,0x1234,next5
;next5:
;
;SUBTEST(4)
;; push/pop a
;
;    ld.16   a,0x1234
;    push    a
;    copy	    a,sp
;    cmpb.eq.16	a,0x6ffe,next6
;    FAIL
;next6:
;    pop	    a
;    cmpb.eq.16	a,0x1234,next7
;next7:
;
;SUBTEST(5)
;; push/pop sp (tracking test)
;    copy    a,sp
;    cmpb.eq.16	a,0x7000,next8
;    FAIL
;next8:
;    ld.16   a,0x1234
;    push   a
;    copy	    a,sp
;    cmpb.eq.16	a,0x6ffe,next9
;    FAIL
;next9:
;    pop	    a
;    cmpb.eq.16	a,0x1234,next10
;next10:
;    copy    a,sp
;    cmpb.eq.16	a,0x7000,next11
;    FAIL
;next11:
;
;SUBTEST(6)
;; push/pop sp (value test)
;
;    push    sp
;    copy    a,sp
;    cmpb.eq.16	a,0x6ffe,next12
;    FAIL
;next12:
;    pop	    a
;    cmpb.eq.16	a,0x7000,next12
;next12:
;
;SUBTEST(12)
;; push pc
;next14:
;    push    pc
;    ld.16	    b,next14
;    pop	    a
;    cmpb.eq.16	a,b,next15
;    FAIL
;next15:
;
;SUBTEST(13)
;; pop pc
;    ld.16   a,next16
;    push    a
;    pop	    pc
;    FAIL
;next16:
;
;SUBTEST(14)
;;   pop	c
;    ld.16   a,0x1234
;    push    a
;    ld.16   a,0x0000
;    pop	    c
;    copy    a,c
;    cmpb.eq.16	a,0x1234,next17
;    FAIL
;next17:
;
;SUBTEST(15)
;;   pop	dp
;    ld.16   a,0x4321
;    push    a
;    ld.16   a,0x0000
;    pop	    dp
;    copy    a,dp
;    cmpb.eq.16	a,0x4321,next18
;    FAIL
;next18:
;
;SUBTEST(16)
;;   pop	b
;    ld.16   a,0x4444
;    push    a
;    ld.16   a,0x0000
;    pop	    b
;    copy    a,b
;    cmpb.eq.16	a,0x4444,next19
;    FAIL
;next19:
;
;SUBTEST(17)
;;   pop	msw
;    copy    a,msw
;    and.16  a,0xfff0
;    copy    msw,a
;    copy    a,msw
;    or.16   a,0xf
;    push    a
;    pop	    msw
;    copy    a,msw
;    and.16  a,0xf
;    cmpb.eq.16	a,0xf,next20
;    FAIL
;next20:

;   Finally, when done branch to pass
    END_TEST
