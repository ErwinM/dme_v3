;
; group j, test 1
;
; or.8, ori.8
;

include(tmacros.h)

.code 0x100

INIT_TEST(j,0x01)

; declare symbols here
;SYM(data1)
;SYM(data2)
;SYM(data3)
;SYM(data4)
;SYM(next0)
;SYM(next1)
;SYM(next2)
;SYM(next3)
;SYM(next4)
;SYM(next5)
;SYM(next6)

    ; Declare data here.  Format is:
    ;	op1
    ;	op2
    ;	expected a result

data1:
    defb    0xff
    defb    0x01
    defb    0xff

data2:
    defb    0x00
    defb    0x00
    defb    0x00
data3:
    defb    0xf0
    defb    0x0f
    defb    0xff
data4:
    defb    0x80
    defb    0x81
    defb    0x81

; Begin test here

SUBTEST(1)
;   ALU ops template (byte-sized ops)
    la16   	r1, data1
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next1)

next1:
SUBTEST(2)
;   ALU ops template (byte-sized ops)
    la16   	r1, data2
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next2)

next2:
SUBTEST(3)
;   ALU ops template (byte-sized ops)
    la16   	r1, data3
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next3)


next3:
SUBTEST(4)
;   ALU ops template (byte-sized ops)
    la16   	r1, data4
		mov			bp, r1
		ldb			r1, 0(bp)
		ldb			r2, 1(bp)
		or			r1, r1, r2
		ldb			r3, 2(bp)
		addskp.z r1, r1, r3
		PASS(next4)

next4:
SUBTEST(5)
;   Immediate version
    ldi			r1, 0x2
		ori		r1, r1, 4
		ldi 		r3, 6
		addskp.z r1, r1, r3
		PASS(next5)

next5:
SUBTEST(6)
;   Immediate version
    ldi			r1, 6
		ori		r1, r1, 2
		ldi 		r3, 6
		addskp.z r1, r1, r3
		PASS(next6)

next6:
SUBTEST(7)
;   Immediate version
    ldi			r1, 0
		ori		r1, r1, 2
		ldi 		r3, 2
		addskp.z r1, r1, r3
		PASS(pass)


;   Finally, when done branch to pass
    END_TEST
