;
; group s, test 1
;
; skip.c - lt, lte

include(tmacros.h)

runall_1:

; declare symbols here

		br hop_s_001

; these are all negative
d1_s_001:
    defw    0xf000 ; -4k
    defw    0xff00 ;
    defw    0x8000 ; -32k
; 3rd is negative
d2_s_001:
    defw    0x0000
    defw    0x7000
    defw    0x8400
; last is negative
d3_s_001:
    defw    0x0f00
    defw    0x1700
    defw    0xf000

hop_s_001:
; Begin test here

SUBTEST(1)
;   lt both pos
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw	r1, 6(bp)
		ldw r2, 8(bp)
		skip.lt r1, r2
		PASS(next0_s_001)

next0_s_001:
		skip.lt r2, r1
		br next1_s_001
		br fail

next1_s_001:
SUBTEST(2)
;   lt pos and neg
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw	r1, 2(bp) ; -256
		ldi r2, 110
		skip.lt r1, r2
		PASS(next2_s_001)

next2_s_001:
		skip.lt r2, r1
		br next3_s_001
		br fail

next3_s_001:
SUBTEST(3)
;   lt both neg
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw			r1, 4(bp) ; -32k
		ldw			r2, 0(bp) ; -4096
		skip.lt r1, r2
		PASS(next4_s_001)

next4_s_001:
		skip.lt r2, r1
		br next5_s_001
		br fail

next5_s_001:
SUBTEST(4)
;   lte
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw			r1, 4(bp) ; -32k
		ldw			r2, 2(bp) ; -4096
		skip.lte r1, r1
		PASS(next6_s_001)

next6_s_001:
		skip.lte r2, r1
		br next7_s_001
		br fail

next7_s_001:
		skip.lte r1, r2
PASS(runall_2)
;   Finally, when done branch to pass
    END_TEST(s, 0x1)
;
; group s, test 2
;
; skip.c - gt, gte



runall_2:

; declare symbols here

		br hop_s_002

; these are all negative
d1_s_002:
    defw    0xf000 ; -4k
    defw    0xff00 ;
    defw    0x8000 ; -32k
; 3rd is negative
d2_s_002:
    defw    0x0000
    defw    0x7000
    defw    0x8400
; last is negative
d3_s_002:
    defw    0x0f00
    defw    0x1700
    defw    0xf000

hop_s_002:
; Begin test here

SUBTEST(1)

;   gt both pos
		la16   	r1, d1_s_002
		mov			r5, r1
		ldw	r1, 8(bp)
		ldw r2, 6(bp)
		skip.gt r1, r2
		PASS(next0_s_002)

next0_s_002:
		skip.gt r2, r1
		br next1_s_002
		br fail

next1_s_002:
SUBTEST(2)
;   gt pos and neg
		la16   	r1, d1_s_002
		mov			r5, r1
		ldi r1, 110
		ldw	r2, 2(bp) ; -256
		skip.gt r1, r2
		PASS(next2_s_002)

next2_s_002:
		skip.gt r2, r1
		br next3_s_002
		br fail

next3_s_002:
SUBTEST(3)
;   gt both neg
		la16   	r1, d1_s_002
		mov			r5, r1
		ldw			r1, 0(bp) ; -4096
		ldw			r2, 4(bp) ; -32k
		skip.gt r1, r2
		PASS(next4_s_002)

next4_s_002:
		skip.gt r2, r1
		br next5_s_002
		br fail

next5_s_002:
SUBTEST(4)
;   gte
		la16   	r1, d1_s_002
		mov			r5, r1
		ldw			r1, 2(bp) ; -32k
		ldw			r2, 4(bp) ; -4096
		skip.gte r1, r1
		PASS(next6_s_002)

next6_s_002:
		skip.gte r2, r1
		br next7_s_002
		br fail

next7_s_002:
		skip.gte r1, r2
PASS(runall_3)
;   Finally, when done branch to pass
    END_TEST(s, 0x2)
;
; group s, test 3
;
; skip.c - ult, ulte


runall_3:

; declare symbols here

		br hop_s_003

; these are all negative
d1_s_003:
    defw    0xf000 ; -4k
    defw    0xff00 ;
    defw    0x8000 ; -32k
; 3rd is negative
d2_s_003:
    defw    0x0000
    defw    0x7000
    defw    0x8400
; last is negative
d3_s_003:
    defw    0x0f00
    defw    0x1700
    defw    0xf000

hop_s_003:
; Begin test here

SUBTEST(1)

;   ult both "pos"
		la16   	r1, d1_s_003
		mov			r5, r1
		ldw	r1, 8(bp) ; 0x7000
		ldw r2, 10(bp) ; 0x8400
		skip.ult r1, r2
		PASS(next0_s_003)

next0_s_003:
		skip.ult r2, r1
		br next1_s_003
		br fail

next1_s_003:
SUBTEST(2)
;   ult pos and neg
		la16   	r1, d1_s_003
		mov			r5, r1
		ldi r1, 110
		ldw	r2, 2(bp) ; 65280
		skip.ult r1, r2
		PASS(next2_s_003)

next2_s_003:
		skip.ult r2, r1
		br next3_s_003
		br fail

next3_s_003:
SUBTEST(3)
;   ult both 'neg'
		la16   	r1, d1_s_003
		mov			r5, r1
		ldw			r1, 4(bp) ; 32k
		ldw			r2, 0(bp) ; 61440
		skip.ult r1, r2
		PASS(next4_s_003)

next4_s_003:
		skip.ult r2, r1
		br next5_s_003
		br fail

next5_s_003:
SUBTEST(4)
;   ulte
		la16   	r1, d1_s_003
		mov			r5, r1
		ldw			r1, 2(bp) ; 65k 0xff00
		ldw			r2, 4(bp) ; 32k 0x8000
		skip.ulte r1, r1
		PASS(next6_s_003)

next6_s_003:
		skip.ulte r1, r2
		br next7_s_003
		br fail

next7_s_003:
		skip.ulte r2, r1
PASS(runall_4)
;   Finally, when done branch to pass
		END_TEST(s, 0x3)
;
; group s, test 4
;
; skip.c - addskp(i).(n)z


runall_4:

; declare symbols here


; Begin test here

SUBTEST(1)

;   addskp.z, addskp.nz - 0 result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r1, r1
		PASS(next0_s_004)

next0_s_004:
		addskp.nz r3, r1, r1
		br next1_s_004
		br fail

next1_s_004:
SUBTEST(2)

;   addskp.z, addskp.nz - neg result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r1, r2
		br next2_s_004
		br fail

next2_s_004:
		addskp.nz r3, r1, r2
		PASS(next3_s_004)

next3_s_004:
SUBTEST(3)

;   addskp.z, addskp.nz - pos result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r2, r1
		br next4_s_004
		br fail

next4_s_004:
		addskp.nz r3, r2, r1
		PASS(next5_s_004)

next5_s_004:
SUBTEST(4)

;   addskpi.z, addskpi.nz - zero result
		ldi		r1, 2
		addskpi.z r3, r1, 2
		PASS(next6_s_004)

next6_s_004:
		addskpi.nz r3, r1, 2
		br next7_s_004
		br fail

next7_s_004:
SUBTEST(5)

;   addskp.z, addskp.nz - neg result
		ldi		r1, 2
		addskpi.z r3, r1, 4
		br next8_s_004
		br fail

next8_s_004:
		addskpi.nz r3, r1, 4
		PASS(next9_s_004)

next9_s_004:
SUBTEST(6)

;   addskp.z, addskp.nz - pos result
		ldi		r1, 2
		addskpi.z r3, r2, 1
		br next1_s_0040
		br fail

next1_s_0040:
		addskpi.nz r3, r2, 1
PASS(pass)

;   Finally, when done branch to pass
    END_TEST(s, 0x4)
;
; group s, test 5
;
; skip.c - eq/ne


;   Finally, when done branch to pass
