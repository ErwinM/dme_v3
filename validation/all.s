;
; group b, test 1
;
; Load immediate - 8 bit, no sign extend
; nops
;
include(tmacros.h)

runall_1:
INIT_TEST(b,0x01)

; declare symbols here

		SUBTEST(1)

		; Begin test here
    ; basic 8-bit load immediate for A and B
    ldi	    	r1,0x00
		addskp.z  r1, r1, r0
		PASS(next0)

next0:
    ldi	    r2,0x3f
    mov	    r1,r2
		addskp.z r1, r1, r2
PASS(runall_2)
next1:
    ; now, make sure we don't mess with upper byte
		; FIXME: DME always loads an 8-bit immediate as a 16-bit imm: e.g. flushing the high bits
    ;ld.16   a,0x1234
    ;ld.8    a,0x11
    ;cmpb.eq.16	a,0x1211,next2
    ;FAIL
next2:

    ; same, but with sign bit hit
    ;ld.16   a,0x3333
    ;ld.8    a,0xff
    ;cmpb.eq.16	a,0x33ff,next3
    ;FAIL

next3:
;   Finally, when done branch to pass
;
; group b, test 2
;
; 16-bit load immediate
;


runall_2:
INIT_TEST(a, 0x2)

SUBTEST(1)


;   Mostly tested already in group_a, but go ahead and do some more

		ld16   		r1,0x1234
    ld16   		r2,0x1235
		subi			r2, r2, 1
		addskp.z 	r1, r1, r2
		PASS(next1)

next1:
		ldi r4, 1
		ld16   		r2,0x4433
    mov    		r1,r2
    addskp.z	r1, r1, r2
		PASS(next2)

next2:
    ldi r4, 2
		ld16   		r3,0x4321
    mov 	   	r5,r3
    addskp.z	r1, r3, r5
PASS(runall_3)
;next2:


;   Finally, when done branch to pass
;
; group 3, test 3
;
; 16-bit load immediate using signed extended 8-bit immediate
;


runall_3:
INIT_TEST(b,0x03)

; declare symbols here

SUBTEST(1)

; Now, put actual test code here....

    ; zero extended
    ld16   		r1,0x1234
    ld16   		r1,0x34
    ld16			r2,0x34
		addskp.z r1, r1, r2
    PASS(next0)

    ; 1 extended
next0:
    ld16 		  r1,0x1284
    ld16   		r1,-1
		ld16			r2, 0xffff
		addskp.z	r1, r2, r1
		PASS(next1)

next1:
		; signed arithmetic from registers
   	ld16  r1 , 1
   	ld16  r2 , -1
   	addskp.nz	r4, r1, r2
   	PASS(next2)

		; signed arithmetic from IR immediate
next2:
		ld16 r1, -1
		addskpi.z r4, r1, -1
		PASS(next3)

next3:
		; zero extended to reg
   	ld16  r1 ,0x1234
   	ld16  r1 ,0x34
		ld16	r2, 0x0034
   	addskp.z	r4, r1, r2
   	PASS(next4)

		; sign extension copied correctly
next4:
    ld16  r3 ,-1
    mov   r1, r3
   	addskp.z	r4, r1, r3
PASS(runall_4)

;   Finally, when done branch to pass
;
; group d, test 1
;
; 8-bit memory loads
;


runall_4:
INIT_TEST(d,0x01)

; declare labels here
; set up data

MEM_0xAA_8_d_001:
	defw 0xaaff

MEM_0xABCD_16_d_001:
	defw 0xabcd


; Begin test here

SUBTEST(1)

;   BP w/ 7s positive offset

    la16   		r1, MEM_0xAA_8_d_001
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next0_d_001)

next0_d_001:
		SUBTEST(2)

;   BP w/ 7s negative offset

    la16   		r1, MEM_0xAA_8_d_001
		ldi				r2, 60
    add				bp, r1, r2
		ldb				r3, -60(bp)
   	ldi				r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next1_d_001)

next1_d_001:
		SUBTEST(3)
;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM_0xAA_8_d_001
    ld16		r2, 500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next3_d_001)


next3_d_001:
		SUBTEST(4)
;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM_0xAA_8_d_001
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next4_d_001)

next4_d_001:
		SUBTEST(5)
;   idx(base) loading zero idx

    la16   	r1, MEM_0xAA_8_d_001
		ldb			r3, 0(r1)
		ldi			r1, 0xaa
		addskp.z	r1, r1, r3
    PASS(next5_d_001)


next5_d_001:
		SUBTEST(6)

;   BP w/ 7s positive offset
;		get high byte

    la16   		r1, MEM_0xABCD_16_d_001
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 60(bp)
   	ldi				r1, 0xab
		addskp.z	r1, r1, r3
    PASS(next6_d_001)

next6_d_001:
		SUBTEST(7)

;   BP w/ 7s positive offset
;		get low byte

    la16   		r1, MEM_0xABCD_16_d_001
		ldi				r2, 60
    sub				bp, r1, r2
		ldb				r3, 61(bp)
   	ldi				r1, 0xcd
		addskp.z	r1, r1, r3
    PASS(next7_d_001)

next7_d_001:
		SUBTEST(8)
;   idx(base) loading with negative 16-bit idx
;		get high byte

    la16   	r1, MEM_0xABCD_16_d_001
    ld16		r2, -500
		sub			r3,	r1, r2
		ldb			r3, r2(r3)
		ldi			r1, 0xab
		addskp.z	r1, r1, r3
    PASS(next8_d_001)

next8_d_001:
		SUBTEST(9)
;   idx(base) loading with negative 16-bit idx
;		get low byte

    la16   	r1, MEM_0xABCD_16_d_001
    ld16		r2, 500
		sub			r3,	r1, r2
		addi		r2, r2, 1
		ldb			r3, r2(r3)
		ldi			r1, 0xcd
		addskp.z	r1, r1, r3
    PASS(next9)

next9:
		SUBTEST(10)
;   storing a word, loading a byte...
; 	storing a byte with a word instruction stores the byte
;   in the low byte -> essentially 1 address higher

    la16   	r1, MEM_0xABCD_16_d_001
    ldi			r2, 0xee
		stw			r0(r1), r2
		addi		r1, r1, 1
		ldb			r3, r0(r1)
		addskp.z	r1, r2, r3
PASS(runall_5)

;   Finally, when done branch to pass
;
; group d, test 2
;
; 16-bit memory loads
;


runall_5:
INIT_TEST(d,0x02)

INIT_MEM

; declare labels here
;
; Begin test here

SUBTEST(1)

;   BP w/ 16-bit positive offset

    la16   		r1, MEM0x8000_16
		ldi				r2, 45
    sub				bp, r1, r2
		ldw				r3, 45(bp)
   	ld16			r1, 0x8000
		addskp.z	r1, r1, r3
    PASS(next0)

next0:
		SUBTEST(2)

;   BP w/ 16-bit negative offset

    la16   		r1, MEM0x8000_16
		ldi				r2, 45
    add				bp, r1, r2
		ldw				r3, -45(bp)
   	ld16			r1, 0x8000
		addskp.z	r1, r1, r3
    PASS(next1)

next1:
		SUBTEST(3)
;   idx(base) loading with positive 16-bit idx

    la16   	r1, MEM0x7FFF_16
    ld16		r2, 250
		sub			r3,	r1, r2
		ldw			r3, r2(r3)
		ld16		r1, 0x7fff
		addskp.z	r1, r1, r3
    PASS(next2)


next2:
		SUBTEST(4)
;   idx(base) loading with negative 16-bit idx

    la16   	r1, MEM0x7FFF_16
    ld16		r2, -250
		sub			r3,	r1, r2
		ldw			r3, r2(r3)
		ld16		r1, 0x7fff
		addskp.z	r1, r1, r3
    PASS(next3)

next3:
		SUBTEST(5)
;   idx(base) loading zero idx

    la16   	r1, MEM0x7FFF_16
		ldw			r3, 0(r1)
		ld16			r1, 0x7fff
		addskp.z	r1, r1, r3
    PASS(pass)

;   Finally, when done branch to pass
END_TEST
