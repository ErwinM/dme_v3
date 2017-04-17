;
; group i, test 2
;
; and.16
;

include(tmacros.h)

.code 0x100

INIT_TEST(i,0x02)

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


    ; Declare data here.  Format is:
    ;	op1
    ;	op2
    ;	expected a result

data1:
    defw    0xff00
    defw    0x0100
    defw    0x0100
data2:
    defw    0x0000
    defw    0x0000
    defw    0x0000

data3:
    defw    0xf000
    defw    0x0f00
    defw    0x0000

data4:
    defw    0x8000
    defw    0x8100
    defw    0x8000

; Begin test here

SUBTEST(1)
;   ALU ops template (byte-sized ops)
    la16   	r1, data1
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next1)

next1:
SUBTEST(2)
;   ALU ops template (byte-sized ops)
    la16   	r1, data2
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next2)

next2:
SUBTEST(3)
;   ALU ops template (byte-sized ops)
    la16   	r1, data3
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next3)


next3:
SUBTEST(4)
;   ALU ops template (byte-sized ops)
    la16   	r1, data4
		mov			bp, r1
		ldw			r1, 0(bp)
		ldw			r2, 2(bp)
		and			r1, r1, r2
		ldw			r3, 4(bp)
		addskp.z r1, r1, r3
		PASS(next4)

next4:
SUBTEST(5)
;   Immediate version
    ld16			r1, 0xffff
		andi		r1, r1, 4
		ldi 		r3, 4
		addskp.z r1, r1, r3
		PASS(next5)

next5:
SUBTEST(6)
;   Immediate version
    ld16		r1, 0x88
		andi		r1, r1, 8
		ldi 		r3, 8
		addskp.z r1, r1, r3
		PASS(pass)

;   Finally, when done branch to pass
    END_TEST
