;
; group s, test 1
;
; skip.c - lt, lte

include(tmacros.h)

.code 0x100

INIT_TEST(s,0x01)

; declare symbols here
;SYM(hop)
;SYM(d1)
;SYM(d2)
;SYM(d3)
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)
;SYM(next4)
;SYM(next5)
;SYM(next6)
;SYM(next7)

		br hop

; these are all negative
d1:
    defw    0xf000 ; -4k
    defw    0xff00 ;
    defw    0x8000 ; -32k
; 3rd is negative
d2:
    defw    0x0000
    defw    0x7000
    defw    0x8400
; last is negative
d3:
    defw    0x0f00
    defw    0x1700
    defw    0xf000

hop:
; Begin test here

SUBTEST(1)

;   lt both pos
		la16   	r1, d1
		mov			r5, r1
		ldw	r1, 6(bp)
		ldw r2, 8(bp)
		skip.lt r1, r2
		PASS(next0)

next0:
		skip.lt r2, r1
		br next1
		br fail

next1:
SUBTEST(2)
;   lt pos and neg
		la16   	r1, d1
		mov			r5, r1
		ldw	r1, 2(bp) ; -256
		ldi r2, 110
		skip.lt r1, r2
		PASS(next2)

next2:
		skip.lt r2, r1
		br next3
		br fail

next3:
SUBTEST(3)
;   lt both neg
		la16   	r1, d1
		mov			r5, r1
		ldw			r1, 4(bp) ; -32k
		ldw			r2, 0(bp) ; -4096
		skip.lt r1, r2
		PASS(next4)

next4:
		skip.lt r2, r1
		br next5
		br fail

next5:
SUBTEST(4)
;   lte
		la16   	r1, d1
		mov			r5, r1
		ldw			r1, 4(bp) ; -32k
		ldw			r2, 2(bp) ; -4096
		skip.lte r1, r1
		PASS(next6)

next6:
		skip.lte r2, r1
		br next7
		br fail

next7:
		skip.lte r1, r2
		PASS(pass)

;   Finally, when done branch to pass
    END_TEST
