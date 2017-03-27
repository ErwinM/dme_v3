;
; group c, test 1
;
; lea/la16
;
; all 16-bit offsets using SP, A, B, DP and PC.  Targets both A and B
;
; FIXME: I do not have a lea instruction: an instruction that can calculate an offset from a base
; if I did, the offset would be max 7 bits (64) and you could do something like: addr = lea tgt, 64(base)
; in our ISA this requires:
; 	ldi idx, 64
;		add base, base, idx
; also if you are using it to load from mem
;		ldi idx, 64
;		ldw.b tgt, idx(base)
; or even if base is bp
;		ldw  tgt, 64(bp)
;
; CONCLUSION: (for now) - LEA instruction not worth it...

include(tmacros.h)

INIT_TEST(c,0x02)

; declare labels here
SYM(next0, c_002)
SYM(next1, c_002)
SYM(next2, c_002)
SYM(next3, c_002)
SYM(next4, c_002)
SYM(next5, c_002)
SYM(next6, c_002)
SYM(next7, c_002)
SYM(next8, c_002)
SYM(next9, c_002)
SYM(next10, c_002)
SYM(next11, c_002)

; Begin test here

SUBTEST(1)

    ld16   	r1,0x1010
    mov    	r5,r1
    lea	    a,0x0101(dp)
    cmpb.eq.16	a,0x1111,next0
    FAIL

next0:

SUBTEST(2)

    ld.16   a,0x1010
    copy    dp,a
    lea	    b,0x0202(dp)
    copy    a,b
    cmpb.eq.16	a,0x1212,next1
    FAIL

next1:

SUBTEST(3)

    ld.16   a,0x7000
    copy    sp,a
    lea	    a,0x0101(sp)
    cmpb.eq.16	a,0x7101,next2
    FAIL

next2:

SUBTEST(4)

    ld.16   a,0x7000
    copy    sp,a
    lea	    b,0x0202(sp)
    copy    a,b
    cmpb.eq.16	a,0x7202,next3
    FAIL

next3:

SUBTEST(5)

    ld.16   a,0xffff
    lea	    a,0x0002(a)
    cmpb.eq.16	a,1,next4
    FAIL

next4:

SUBTEST(6)

    ld.16   a,0xff00
    lea	    b,0x01ff(a)
    copy    a,b
    cmpb.eq.16	a,0xff,next5
    FAIL

next5:

SUBTEST(7)
    ld.16   b,0x7070
    lea	    a,0x0707(b)
    cmpb.eq.16	a,0x7777,next6
    FAIL

next6:

SUBTEST(8)
    ld.16   b,0x1234
    lea	    b,0x4321(b)
    copy    a,b
    cmpb.eq.16	a,0x5555,next7
    FAIL

next7:

SUBTEST(9)
    ld.16   b,next8+123
    lea	    a,123(pc)
next8:
    cmpb.eq.16	a,b,next9
    FAIL
next9:


SUBTEST(10)
    ld.16   a,next10+123
    lea	    b,123(pc)
next10:
    cmpb.eq.16	a,b,next11
    FAIL
next11:

;   Finally, when done branch to pass
    END_TEST