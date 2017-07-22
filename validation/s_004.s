;
; group s, test 4
;
; skip.c - addskp(i).(n)z

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
;SYM(next10)


; Begin test here

SUBTEST(1)

;   addskp.z, addskp.nz - 0 result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r1, r1
		PASS(next0)

next0:
		addskp.nz r3, r1, r1
		br next1
		br fail

next1:
SUBTEST(2)

;   addskp.z, addskp.nz - neg result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r1, r2
		br next2
		br fail

next2:
		addskp.nz r3, r1, r2
		PASS(next3)

next3:
SUBTEST(3)

;   addskp.z, addskp.nz - pos result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r2, r1
		br next4
		br fail

next4:
		addskp.nz r3, r2, r1
		PASS(next5)

next5:
SUBTEST(4)

;   addskpi.z, addskpi.nz - zero result
		ldi		r1, 2
		addskpi.z r3, r1, 2
		PASS(next6)

next6:
		addskpi.nz r3, r1, 2
		br next7
		br fail

next7:
SUBTEST(5)

;   addskp.z, addskp.nz - neg result
		ldi		r1, 2
		addskpi.z r3, r1, 4
		br next8
		br fail

next8:
		addskpi.nz r3, r1, 4
		PASS(next9)

next9:
SUBTEST(6)

;   addskp.z, addskp.nz - pos result
		ldi		r1, 2
		addskpi.z r3, r2, 1
		br next10
		br fail

next10:
		addskpi.nz r3, r2, 1
		PASS(pass)


;   Finally, when done branch to pass
    END_TEST(s, 0x4)
