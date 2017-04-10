;
; group s, test 2
;
; skip.c - ult, ulte

include(tmacros.h)

INIT_TEST(s,0x03)

; declare symbols here
SYM(hop, s_003)
SYM(d1, s_003)
SYM(d2, s_003)
SYM(d3, s_003)
SYM(next0, s_003)
SYM(next1, s_003)
SYM(next2, s_003)
SYM(next3, s_003)
SYM(next4, s_003)
SYM(next5, s_003)

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

;   ult both "pos"
		la16   	r1, d1
		mov			r5, r1
		ldw	r1, 8(bp)
		ldw r2, 10(bp)
		skip.ult r1, r2
		PASS(next0)

next0:
		skip.ult r2, r1
		br next1
		br fail

next1:
SUBTEST(2)
;   ult pos and neg
		la16   	r1, d1
		mov			r5, r1
		ldi r1, 110
		ldw	r2, 2(bp) ; 65280
		skip.ult r1, r2
		PASS(next2)

next2:
		skip.ult r2, r1
		br next3
		br fail

next3:
SUBTEST(3)
;   ult both 'neg'
		la16   	r1, d1
		mov			r5, r1
		ldw			r1, 4(bp) ; 32k
		ldw			r2, 0(bp) ; 61440
		skip.ult r1, r2
		PASS(next4)

next4:
		skip.ult r2, r1
		br next5
		br fail

next5:
SUBTEST(4)
;   ulte
		la16   	r1, d1
		mov			r5, r1
		ldw			r1, 2(bp) ; 65k 0xff00
		ldw			r2, 4(bp) ; 32k 0x8000
		skip.ulte r1, r1
		PASS(next6)

next6:
		skip.ulte r1, r2
		br next7
		br fail

next7:
		skip.ulte r2, r1
		PASS(pass)

;   Finally, when done branch to pass
    END_TEST
