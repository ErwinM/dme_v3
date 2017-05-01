;
; group s, test 1
;
; skip.c - lt, lte





.code 0x100

runall_1:

ldi r2, 0x11
ldi r1, char @s
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x01
stb.b 0(r2), r1


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

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   lt both pos
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw	r1, 6(bp)
		ldw r2, 8(bp)
		skip.lt r1, r2
		br fail
br next0_s_001
hlt


next0_s_001:
		skip.lt r2, r1
		br next1_s_001
		br fail

next1_s_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   lt pos and neg
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw	r1, 2(bp) ; -256
		ldi r2, 110
		skip.lt r1, r2
		br fail
br next2_s_001
hlt


next2_s_001:
		skip.lt r2, r1
		br next3_s_001
		br fail

next3_s_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   lt both neg
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw			r1, 4(bp) ; -32k
		ldw			r2, 0(bp) ; -4096
		skip.lt r1, r2
		br fail
br next4_s_001
hlt


next4_s_001:
		skip.lt r2, r1
		br next5_s_001
		br fail

next5_s_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   lte
		la16   	r1, d1_s_001
		mov			r5, r1
		ldw			r1, 4(bp) ; -32k
		ldw			r2, 2(bp) ; -4096
		skip.lte r1, r1
		br fail
br next6_s_001
hlt


next6_s_001:
		skip.lte r2, r1
		br next7_s_001
		br fail

next7_s_001:
		skip.lte r1, r2
br fail
br runall_2
hlt

;   Finally, when done branch to pass
;
; group s, test 2
;
; skip.c - gt, gte



runall_2:

ldi r2, 0x11
ldi r1, char @s
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x02
stb.b 0(r2), r1


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

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   gt both pos
		la16   	r1, d1_s_002
		mov			r5, r1
		ldw	r1, 8(bp)
		ldw r2, 6(bp)
		skip.gt r1, r2
		br fail
br next0_s_002
hlt


next0_s_002:
		skip.gt r2, r1
		br next1_s_002
		br fail

next1_s_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   gt pos and neg
		la16   	r1, d1_s_002
		mov			r5, r1
		ldi r1, 110
		ldw	r2, 2(bp) ; -256
		skip.gt r1, r2
		br fail
br next2_s_002
hlt


next2_s_002:
		skip.gt r2, r1
		br next3_s_002
		br fail

next3_s_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   gt both neg
		la16   	r1, d1_s_002
		mov			r5, r1
		ldw			r1, 0(bp) ; -4096
		ldw			r2, 4(bp) ; -32k
		skip.gt r1, r2
		br fail
br next4_s_002
hlt


next4_s_002:
		skip.gt r2, r1
		br next5_s_002
		br fail

next5_s_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   gte
		la16   	r1, d1_s_002
		mov			r5, r1
		ldw			r1, 2(bp) ; -32k
		ldw			r2, 4(bp) ; -4096
		skip.gte r1, r1
		br fail
br next6_s_002
hlt


next6_s_002:
		skip.gte r2, r1
		br next7_s_002
		br fail

next7_s_002:
		skip.gte r1, r2
br fail
br runall_3
hlt

;   Finally, when done branch to pass
;
; group s, test 3
;
; skip.c - ult, ulte



runall_3:

ldi r2, 0x11
ldi r1, char @s
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x03
stb.b 0(r2), r1


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

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   ult both "pos"
		la16   	r1, d1_s_003
		mov			r5, r1
		ldw	r1, 8(bp) ; 0x7000
		ldw r2, 10(bp) ; 0x8400
		skip.ult r1, r2
		br fail
br next0_s_003
hlt


next0_s_003:
		skip.ult r2, r1
		br next1_s_003
		br fail

next1_s_003:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ult pos and neg
		la16   	r1, d1_s_003
		mov			r5, r1
		ldi r1, 110
		ldw	r2, 2(bp) ; 65280
		skip.ult r1, r2
		br fail
br next2_s_003
hlt


next2_s_003:
		skip.ult r2, r1
		br next3_s_003
		br fail

next3_s_003:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ult both 'neg'
		la16   	r1, d1_s_003
		mov			r5, r1
		ldw			r1, 4(bp) ; 32k
		ldw			r2, 0(bp) ; 61440
		skip.ult r1, r2
		br fail
br next4_s_003
hlt


next4_s_003:
		skip.ult r2, r1
		br next5_s_003
		br fail

next5_s_003:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ulte
		la16   	r1, d1_s_003
		mov			r5, r1
		ldw			r1, 2(bp) ; 65k 0xff00
		ldw			r2, 4(bp) ; 32k 0x8000
		skip.ulte r1, r1
		br fail
br next6_s_003
hlt


next6_s_003:
		skip.ulte r1, r2
		br next7_s_003
		br fail

next7_s_003:
		skip.ulte r2, r1
br fail
br runall_4
hlt

;   Finally, when done branch to pass
;
; group s, test 4
;
; skip.c - addskp(i).(n)z



runall_4:

ldi r2, 0x11
ldi r1, char @s
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x04
stb.b 0(r2), r1


; declare symbols here


; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   addskp.z, addskp.nz - 0 result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r1, r1
		br fail
br next0_s_004
hlt


next0_s_004:
		addskp.nz r3, r1, r1
		br next1_s_004
		br fail

next1_s_004:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   addskp.z, addskp.nz - neg result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r1, r2
		br next2_s_004
		br fail

next2_s_004:
		addskp.nz r3, r1, r2
		br fail
br next3_s_004
hlt


next3_s_004:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   addskp.z, addskp.nz - pos result
		ldi		r1, 0xaa
		ldi 	r2, 0xbb
		addskp.z r3, r2, r1
		br next4_s_004
		br fail

next4_s_004:
		addskp.nz r3, r2, r1
		br fail
br next5_s_004
hlt


next5_s_004:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   addskpi.z, addskpi.nz - zero result
		ldi		r1, 2
		addskpi.z r3, r1, 2
		br fail
br next6_s_004
hlt


next6_s_004:
		addskpi.nz r3, r1, 2
		br next7_s_004
		br fail

next7_s_004:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   addskp.z, addskp.nz - neg result
		ldi		r1, 2
		addskpi.z r3, r1, 4
		br next8_s_004
		br fail

next8_s_004:
		addskpi.nz r3, r1, 4
		br fail
br next9_s_004
hlt


next9_s_004:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   addskp.z, addskp.nz - pos result
		ldi		r1, 2
		addskpi.z r3, r2, 1
		br next1_s_0040
		br fail

next1_s_0040:
		addskpi.nz r3, r2, 1
		br fail
br pass
hlt



;   Finally, when done branch to pass
    pass:
	ld16 r3, 0xff80
	ldi r5, 0xAA
	stw 0(r3), r5
  hlt

fail:
	ld16 r3, 0xff80
	ldi r5, 0xFF
	stw 0(r3), r5
  hlt

