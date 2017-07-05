;
; group s, test 5
;
; skip.c - eq/ne

include(tmacros.h)

.code 0x100

INIT_TEST(s,0x05)

; declare symbols here
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)
;SYM(next4)
;SYM(next5)
;SYM(next6)


; Begin test here

SUBTEST(1)

;   skip.eq
		ldi		r1, 0xaa
		skip.eq r1, r1
		PASS(next0)

next0:
		skip.eq r1, r0
		br next1
		br fail

next1:
SUBTEST(2)

;   skip.eq with 0
		ldi r1, 0xaa
		mov	r2, r0
		skip.eq r2, r0
		PASS(next2)

next2:
		skip.eq r2, r1
		br next3
		br fail

next3:
SUBTEST(3)

;   skip.ne
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		skip.ne r2, r1
		PASS(next4)

next4:
		skip.ne r1, r1
		br next5
		br fail

next5:
SUBTEST(4)

;   skip.ne with 0
		ldi 	r1, 0xaa
		mov		r2, r0
		skip.ne r1, r2
		PASS(next6)

next6:
		skip.ne r2, r2
		br pass
		br fail

;   Finally, when done branch to pass
    END_TEST
