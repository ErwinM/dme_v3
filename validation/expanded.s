;
; group i, test 1
;
; and.8, andi.8
;





.code 0x100

runall_1:

ldi r2, 0x11
ldi r1, char @i
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x01
stb.b 0(r2), r1


; declare symbols here

    ; Declare data here.  Format is:
    ;	op1
    ;	op2
    ;	expected a result

data1_i_001:
    defb    0xff
    defb    0x01
    defb    0x01
data2_i_001:
    defb    0x00
    defb    0x00
    defb    0x00
data3_i_001:
    defb    0xf0
    defb    0x0f
    defb    0x00

data4_i_001:
    defb    0x80
    defb    0x81
    defb    0x80

; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data1_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next1_i_001
hlt


next1_i_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data2_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next2_i_001
hlt


next2_i_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data3_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next3_i_001
hlt



next3_i_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data4_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next4_i_001
hlt


next4_i_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 0xf
		andi		r1, r1, 4
		ldi 		r3, 4
		addskp.z r1, r1, r3
		br fail
br next5_i_001
hlt


next5_i_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 0x4
		andi		r1, r1, 8
		ldi 		r3, 0
		addskp.z r1, r1, r3
		br fail
br next6_i_001
hlt


next6_i_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 7
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 2
		andi		r1, r1, 2
		ldi 		r3, 2
		addskp.z r1, r1, r3
br fail
br runall_2
hlt


;   Finally, when done branch to pass
;
; group i, test 2
;
; and.16
;



runall_2:

ldi r2, 0x11
ldi r1, char @i
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x02
stb.b 0(r2), r1


; declare symbols here


    ; Declare data here.  Format is:
    ;	op1
    ;	op2
    ;	expected a result

data1_i_002:
    defw    0xff00
    defw    0x0100
    defw    0x0100
data2_i_002:
    defw    0x0000
    defw    0x0000
    defw    0x0000

data3_i_002:
    defw    0xf000
    defw    0x0f00
    defw    0x0000

data4_i_002:
    defw    0x8000
    defw    0x8100
    defw    0x8000

; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data1_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next1_i_002
hlt


next1_i_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data2_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next2_i_002
hlt


next2_i_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data3_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next3_i_002
hlt



next3_i_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data4_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next4_i_002
hlt


next4_i_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ld16			r1, 0xffff
		andi		r1, r1, 4
		ldi 		r3, 4
		addskp.z r1, r1, r3
		br fail
br next5_i_002
hlt


next5_i_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ld16		r1, 0x88
		andi		r1, r1, 8
		ldi 		r3, 8
		addskp.z r1, r1, r3
br fail
br runall_3
hlt

;   Finally, when done branch to pass
;
; group j, test 1
;
; or.8, ori.8
;



runall_3:

ldi r2, 0x11
ldi r1, char @j
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x01
stb.b 0(r2), r1


; declare symbols here

    ; Declare data here.  Format is:
    ;	op1
    ;	op2
    ;	expected a result

data1_j_001:
    defb    0xff
    defb    0x01
    defb    0xff

data2_j_001:
    defb    0x00
    defb    0x00
    defb    0x00
data3_j_001:
    defb    0xf0
    defb    0x0f
    defb    0xff
data4_j_001:
    defb    0x80
    defb    0x81
    defb    0x81

; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data1_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next1_j_001
hlt


next1_j_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data2_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next2_j_001
hlt


next2_j_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data3_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next3_j_001
hlt



next3_j_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data4_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		br fail
br next4_j_001
hlt


next4_j_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 0x2
		ori		r1, r1, 4
		ldi 		r3, 6
		addskp.z r1, r1, r3
		br fail
br next5_j_001
hlt


next5_j_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 6
		ori		r1, r1, 2
		ldi 		r3, 6
		addskp.z r1, r1, r3
		br fail
br next6_j_001
hlt


next6_j_001:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 7
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 0
		ori		r1, r1, 2
		ldi 		r3, 2
		addskp.z r1, r1, r3
br fail
br runall_4
hlt


;   Finally, when done branch to pass
;
; group j, test 2
;
; or.16, ori.16
;



runall_4:

ldi r2, 0x11
ldi r1, char @j
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x02
stb.b 0(r2), r1


; declare symbols here

    ; Declare data here.  Format is:
    ;	op1
    ;	op2
    ;	expected a result

data1_j_002:
    defw    0xff00
    defw    0x0100
    defw    0xff00

data2_j_002:
    defw    0x0000
    defw    0x0000
    defw    0x0000

data3_j_002:
    defw    0xf000
    defw    0x0f00
    defw    0xff00

data4_j_002:
    defw    0x8000
    defw    0x8100
    defw    0x8100


; Begin test here

; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data1_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next1_j_002
hlt


next1_j_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 2
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data2_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next2_j_002
hlt


next2_j_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 3
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data3_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next3_j_002
hlt



next3_j_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 4
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   ALU ops template (byte-sized ops)
    la16   	r1, data4_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		br fail
br next4_j_002
hlt


next4_j_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 5
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 0x2
		ori		r1, r1, 4
		ldi 		r3, 6
		addskp.z r1, r1, r3
		br fail
br next5_j_002
hlt


next5_j_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 6
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ld16	r1, 0xffff
		ori		r1, r1, 2
		ld16		r3, 0xffff
		addskp.z r1, r1, r3
		br fail
br next6_j_002
hlt


next6_j_002:
; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, 7
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0

;   Immediate version
    ldi			r1, 0
		ori		r1, r1, 2
		ldi 		r3, 2
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

