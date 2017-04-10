.code 0x100

;
; group d, test 1
;
; 8-bit memory loads
;





runall_1:

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
br runall_2
hlt

;   Finally, when done branch to pass





;
; group d, test 2
;
; 16-bit memory loads
;


runall_2:

ldi r2, 0x11
ldi r1, char @d
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x02
stb.b 0(r2), r1



MEM0x00_8:
	defb    0x00
MEM0x01_8:
  defb    0x01
MEM0xFF_8:
  defb    0xff
MEM0x0000_16:
  defw    0x0000
MEM0x0001_16:
  defw    0x0001
MEM0xFFFF_16:
  defw    0xffff
MEM0x7F_8:
  defb    0x7f
MEM0x80_8:
  defb    0x80
MEM0x7FFF_16:
  defw    0x7fff
MEM0x8000_16:
  defw    0x8000

b1:
  defb    0x00
w1:
  defw    0x0000


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


;   BP w/ 16-bit positive offset

    la16   		r1, MEM0x8000_16
		ldi				r2, 45
    sub				bp, r1, r2
		ldw				r3, 45(bp)
   	ld16			r1, 0x8000
		addskp.z	r1, r1, r3
    br fail
br next0_d_001_d_002
hlt


next0_d_001_d_002:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   BP w/ 16-bit negative offset

    la16   		r1, MEM0x8000_16
		ldi				r2, 45
    add				bp, r1, r2
		ldw				r3, -45(bp)
   	ld16			r1, 0x8000
		addskp.z	r1, r1, r3
    br fail
br next1_d_001_d_002
hlt


next1_d_001_d_002:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM0x7FFF_16
    ld16		r2, 250
		sub			r3,	r1, r2
		ldw			r3, r2(r3)
		ld16		r1, 0x7fff
		addskp.z	r1, r1, r3
    br fail
br next2_d_001_d_002
hlt



next2_d_001_d_002:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM0x7FFF_16
    ld16		r2, -250
		sub			r3,	r1, r2
		ldw			r3, r2(r3)
		ld16		r1, 0x7fff
		addskp.z	r1, r1, r3
    br fail
br next3_d_001_d_002
hlt


next3_d_001_d_002:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   idx(base) loading zero idx

    la16   	r1, MEM0x7FFF_16
		ldw			r3, 0(r1)
		ld16			r1, 0x7fff
		addskp.z	r1, r1, r3
br fail
br runall_3
hlt

;   Finally, when done branch to pass





;
; group e, test 1
;
; 8-bit memory stores
; Byte enable function


runall_3:

ldi r2, 0x11
ldi r1, char @e
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x01
stb.b 0(r2), r1


; declare symbols here











; set up data

MEM_0xAAAA:
	defw 0xaaaa
MEM_0xBBBB:
	defw 0xbbbb
MEM_0xCCCC:
	defw 0xcccc
MEM_0xDDDD:
	defw 0xdddd

; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   bp w/ s7 offset

    la16   	r1, 0x800
    ld16		r2, 48
		sub	    bp, r1, r2
    ldi	    r1, 0x80
    stb	    48(bp), r1
    ldb    	r2, 48(bp)
    addskp.z r2, r1, r2
    br fail
br next0_d_001_d_002_e_001
hlt


next0_d_001_d_002_e_001:

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   bp w/ base, idx

		la16   	r1, 0x800
		ld16		r2, 513
		sub	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    r2(bp), r1
		ldb    	r3, r2(bp)
		addskp.z r2, r1, r3
		br fail
br next1_d_001_d_002_e_001
hlt



next1_d_001_d_002_e_001:

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   bp w/ s7 offset
;		make sure byte enable is correctly preserving LOW byte

		la16   	r1, MEM_0xAAAA
		ld16		r2, 32
		add	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    -32(bp), r1
		ldb    	r3, -32(bp)
		addskp.z r2, r1, r3
		br fail
br next2_d_001_d_002_e_001
hlt


		; check if the low byte is preserved
next2_d_001_d_002_e_001:
		ldb r3, -31(bp)
		ldi r1, 0xaa
		addskp.z r1, r1, r3
		br fail
br next3_d_001_d_002_e_001
hlt



next3_d_001_d_002_e_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   bp w/ s7 offset
;		make sure byte enable is correctly preserving HIGH byte

		la16   	r1, MEM_0xBBBB
		ld16		r2, 32
		add	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    -31(bp), r1
		ldb    	r3, -31(bp)
		addskp.z r2, r1, r3
		br fail
br next4_d_001_d_002_e_001
hlt


		; check if the high byte is preserved
next4_d_001_d_002_e_001:
		ldb r3, -32(bp)
		ldi r1, 0xbb
		addskp.z r1, r1, r3
		br fail
br next5_e_001
hlt


next5_e_001:

		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   bp w/ index base
;		make sure byte enable is correctly preserving LOW byte

		la16   	r1, MEM_0xCCCC
		ld16		r2, 0x200
		sub	    bp, r1, r2
		ldi	    r1, 0x80
		stb	    r2(bp), r1
		ldb    	r3, r2(bp)
		addskp.z r3, r1, r3
		br fail
br next6_e_001
hlt


		; check if the low byte is preserved
next6_e_001:
		addi	r2, r2, 1
		ldb r3, r2(bp)
		ldi r1, 0xcc
		addskp.z r1, r1, r3
		br fail
br next7_e_001
hlt



next7_e_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0


;   bp w/ index base
;		make sure byte enable is correctly preserving HIGH byte

		la16   	r1, MEM_0xDDDD
		ld16		r2, 0x200
		sub	    bp, r1, r2
		addi		r4, r2, 1
		ldi	    r1, 0x80
		stb	    r4(bp), r1
		ldb    	r3, r4(bp)
		addskp.z r3, r1, r3
		br fail
br next8_e_001
hlt


		; check if the high byte is preserved
next8_e_001:
		ldb r3, r2(bp)
		ldi r1, 0xdd
		addskp.z r1, r1, r3
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

