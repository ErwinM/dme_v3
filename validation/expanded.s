;
; group d, test 1
;
; 8-bit memory loads
;






.code 0x100
ldi r2, 0x10
ldi r1, char @d
stb.b 0(r2), r1
ldi r2, 0x12
ldi r1, 0x01
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
mov r6, r0


;   BP w/ 16-bit positive offset

    la16   		r1, MEM0x80_8
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0x80
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
mov r6, r0


;   BP w/ 16-bit negative offset

    la16   		r1, MEM0x80_8
		ldi				r2, 60
    add				bp, r1, r2
		ldb				r3, -60(bp)
   	ldi				r1, 0x80
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
mov r6, r0

;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM0x7F_8
    ld16		r2, 500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    br fail
br next2_d_001
hlt


next2_d_001:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0
mov r6, r0

;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM0x7F_8
    ld16		r2, 500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    br fail
br next3
hlt


next3:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0
mov r6, r0

;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM0x7F_8
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    br fail
br next4
hlt


next4:
		; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0
mov r6, r0

;   idx(base) loading zero idx

    la16   	r1, MEM0x7F_8
		ldb			r3, 0(r1)
		ldi			r1, 0x7f
		addskp.z	r1, r1, r3
    br fail
br pass
hlt


;   Finally, when done branch to pass
pass:
	ldi r3, 0x20
	ldi r5, 0xAA
	stw.b 0(r3), r5
  hlt

fail:
	ldi r3, 0x20
	ldi r5, 0xFF
	stw.b 0(r3), r5
  hlt

