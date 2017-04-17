;
; group i, test 1
;
; and.8, andi.8
;

include(tmacros.h)

.code 0x100

runall_1:
INIT_TEST(i,0x01)

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

SUBTEST(1)
;   ALU ops template (byte-sized ops)
    la16   	r1, data1_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next1_i_001)

next1_i_001:
SUBTEST(2)
;   ALU ops template (byte-sized ops)
    la16   	r1, data2_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next2_i_001)

next2_i_001:
SUBTEST(3)
;   ALU ops template (byte-sized ops)
    la16   	r1, data3_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next3_i_001)


next3_i_001:
SUBTEST(4)
;   ALU ops template (byte-sized ops)
    la16   	r1, data4_i_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		and			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next4_i_001)

next4_i_001:
SUBTEST(5)
;   Immediate version
    ldi			r1, 0xf
		andi		r1, r1, 4
		ldi 		r3, 4
		addskp.z r1, r1, r3
		PASS(next5_i_001)

next5_i_001:
SUBTEST(6)
;   Immediate version
    ldi			r1, 0x4
		andi		r1, r1, 8
		ldi 		r3, 0
		addskp.z r1, r1, r3
		PASS(next6_i_001)

next6_i_001:
SUBTEST(7)
;   Immediate version
    ldi			r1, 2
		andi		r1, r1, 2
		ldi 		r3, 2
		addskp.z r1, r1, r3
PASS(runall_2)

;   Finally, when done branch to pass
;
; group i, test 2
;
; and.16
;



runall_2:
INIT_TEST(i,0x02)

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

SUBTEST(1)
;   ALU ops template (byte-sized ops)
    la16   	r1, data1_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next1_i_002)

next1_i_002:
SUBTEST(2)
;   ALU ops template (byte-sized ops)
    la16   	r1, data2_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next2_i_002)

next2_i_002:
SUBTEST(3)
;   ALU ops template (byte-sized ops)
    la16   	r1, data3_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next3_i_002)


next3_i_002:
SUBTEST(4)
;   ALU ops template (byte-sized ops)
    la16   	r1, data4_i_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next4_i_002)

next4_i_002:
SUBTEST(5)
;   Immediate version
    ld16			r1, 0xffff
		andi		r1, r1, 4
		ldi 		r3, 4
		addskp.z r1, r1, r3
		PASS(next5_i_002)

next5_i_002:
SUBTEST(6)
;   Immediate version
    ld16		r1, 0x88
		andi		r1, r1, 8
		ldi 		r3, 8
		addskp.z r1, r1, r3
PASS(runall_3)
;   Finally, when done branch to pass
;
; group j, test 1
;
; or.8, ori.8
;



runall_3:
INIT_TEST(j,0x01)

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

SUBTEST(1)
;   ALU ops template (byte-sized ops)
    la16   	r1, data1_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next1_j_001)

next1_j_001:
SUBTEST(2)
;   ALU ops template (byte-sized ops)
    la16   	r1, data2_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next2_j_001)

next2_j_001:
SUBTEST(3)
;   ALU ops template (byte-sized ops)
    la16   	r1, data3_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next3_j_001)


next3_j_001:
SUBTEST(4)
;   ALU ops template (byte-sized ops)
    la16   	r1, data4_j_001
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next4_j_001)

next4_j_001:
SUBTEST(5)
;   Immediate version
    ldi			r1, 0x2
		ori		r1, r1, 4
		ldi 		r3, 6
		addskp.z r1, r1, r3
		PASS(next5_j_001)

next5_j_001:
SUBTEST(6)
;   Immediate version
    ldi			r1, 6
		ori		r1, r1, 2
		ldi 		r3, 6
		addskp.z r1, r1, r3
		PASS(next6_j_001)

next6_j_001:
SUBTEST(7)
;   Immediate version
    ldi			r1, 0
		ori		r1, r1, 2
		ldi 		r3, 2
		addskp.z r1, r1, r3
PASS(runall_4)

;   Finally, when done branch to pass
;
; group j, test 2
;
; or.16, ori.16
;



runall_4:
INIT_TEST(j,0x02)

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

SUBTEST(1)
;   ALU ops template (byte-sized ops)
    la16   	r1, data1_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next1_j_002)

next1_j_002:
SUBTEST(2)
;   ALU ops template (byte-sized ops)
    la16   	r1, data2_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next2_j_002)

next2_j_002:
SUBTEST(3)
;   ALU ops template (byte-sized ops)
    la16   	r1, data3_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next3_j_002)


next3_j_002:
SUBTEST(4)
;   ALU ops template (byte-sized ops)
    la16   	r1, data4_j_002
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		or			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next4_j_002)

next4_j_002:
SUBTEST(5)
;   Immediate version
    ldi			r1, 0x2
		ori		r1, r1, 4
		ldi 		r3, 6
		addskp.z r1, r1, r3
		PASS(next5_j_002)

next5_j_002:
SUBTEST(6)
;   Immediate version
    ld16	r1, 0xffff
		ori		r1, r1, 2
		ld16		r3, 0xffff
		addskp.z r1, r1, r3
		PASS(next6_j_002)

next6_j_002:
SUBTEST(7)
;   Immediate version
    ldi			r1, 0
		ori		r1, r1, 2
		ldi 		r3, 2
		addskp.z r1, r1, r3
		PASS(pass)


;   Finally, when done branch to pass
    END_TEST
