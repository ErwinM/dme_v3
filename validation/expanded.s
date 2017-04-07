;
; group d, test 1
;
; 8-bit memory loads
;






.code 0x100
ldi r2, 0x11
ldi r1, char @d
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x01
stb.b 0(r2), r1


; set up data

MEM_0xAA_8:
	defw 0xaaff

MEM_0xABCD_16:
	defw 0xabcd

; declare labels here







; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   BP w/ 7s positive offset

    la16   		r1, MEM_0xAA_8
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0xaa
		addskp.z	r1, r1, r3
    br fail
br next0_d_001
hlt


next0_d_001:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   BP w/ 7s negative offset

    la16   		r1, MEM_0xAA_8
		ldi				r2, 60
    add				bp, r1, r2
		ldb				r3, -60(bp)
   	ldi				r1, 0xaa
		addskp.z	r1, r1, r3
    br fail
br next1_d_001
hlt


next1_d_001:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM_0xAA_8
    ld16		r2, 500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    br fail
br next3_d_001
hlt



next3_d_001:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM_0xAA_8
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    br fail
br next4_d_001
hlt


next4_d_001:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading zero idx

    la16   	r1, MEM_0xAA_8
		ldb			r3, 0(r1)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    br fail
br next5
hlt



next5:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   BP w/ 7s positive offset
;		get high byte

    la16   		r1, MEM_0xABCD_16
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0xab
		addskp.z	r1, r1, r3
    br fail
br next6
hlt


next6:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 7
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   BP w/ 7s positive offset
;		get low byte

    la16   		r1, MEM_0xABCD_16
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 61(bp)
   	ldi				r1, 0xcd
		addskp.z	r1, r1, r3
    br fail
br next7
hlt


next7:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 8
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading with negative 16-bit idx
;		get high byte

    la16   	r1, MEM_0xABCD_16
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xab
		addskp.z	r1, r1, r3
    br fail
br next8
hlt


next8:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 9
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading with negative 16-bit idx
;		get low byte

    la16   	r1, MEM_0xABCD_16
    ld16		r2, 500
		sub			r3,	r1, r2
		addi		r2, r2, 1
		ldb			r3, r2(r3)
		ldi			r1, 0xcd
		addskp.z	r1, r1, r3
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

