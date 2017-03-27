;
; group b, test 1
;
; Load immediate - 8 bit, no sign extend
; nops
;
include(tmacros.h)

INIT_TEST(b,0x01)

; declare symbols here
    SYM(next0, b_001)
    SYM(next1, b_001)
    SYM(next2, b_001)
    SYM(next3, b_001)
    SYM(next4, b_001)

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
		PASS(pass)

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
    END_TEST
