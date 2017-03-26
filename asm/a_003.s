;
; group_a, test 3
;
; Basic coverage for test boilerplate.  Because this test is designed
; to validate enough capabilities to run boilerplate code, it does not
; use the boilerplate as-is.
;
; Covers:
;
;	>>ld.8	a,0(B)
;	ldw	a,0(B)
;	>>st.8	0(B),a
;	stw	0(B), a
;	addskp.z tgt, r1, r2
;	addskp.
;	cmpb.eq.8  a,imm,tgt
;	cmpb.ne.8  a,imm,tgt
;
; NOTE: subtest number is set statically (don't have stores yet)
;	SP is not set
;	calls not performed
;
; NOTE: This code should not be included in composed tests, as it doesn't
;	follow normal conventions.
;
_start:
    br	_start_tests	; Go run stuff.

    ; Data sections to report group, test and subtest number

test_group:
    defb    0x61	; group 'a'
test_num:
    defb    0x02	; test 2
subtest:
    defb    0x01A ; subtest 1 (only 1 subtest here)

    ; Literal section for useful memory constants (should not be modified)
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


_start_tests:

; Begin test here

    ; Run though some combos for byte loads and compares.
    ; Be a bit redundant to make sure the sign extension
    ; circuitry isn't turning on when inappropriate.

    ; Run though some combos for word loads and compares.
		la16	r1, MEM0x8000_16 ; we are loading an address, which for the cpu will be a constant
		ldw.b	r2, 0(r1)
		ld16 r3, 0x8000
		addskp.z r1, r2, r3
		br fail
    br next1
    hlt

next1:
		ldi r4, 1
    ld16    r2,0x0000
		addskp.z r2, r2, r0
		br fail
		br next2
		hlt

next2:
	 ldi r4, 2

	 la16	  r2,MEM0x00_8
   ldb.b 	r1,0(r2)
	 addskp.z r2, r1, r0
   br	fail
	 br next3
	 hlt

next3:
    ldi r4, 3
		la16   r2,MEM0x7F_8
    ldb.b    r1,0(r2)
		ldi 	r3, 0x7f
    addskp.z r3, r1, r3
		br	fail
 	 	br next4
 	 	hlt

next4:
		ldi r4, 4
		la16   r1, MEM0x7FFF_16
    ldw.b  r2, 0(r1)
  	ld16 r3, 0x7fff
    addskp.z r3, r2, r3
    br	fail
		br next5
		hlt


    ; Try a couple of simple stores
next5:
		ldi r4, 5
		la16   	r2, b1
    ldi	    r1, 12
    stb.b   0(r2), r1
    ld16   	r1, 0xfdca
		ldi			r3, 12
		addskp.nz r5, r1, r3
		br fail
		ldb.b		r1, 0(r2)
    addskp.z r5, r1, r3
		br fail
		br success
		hlt

;    ; And again with a word
;next13:
;    ld.16   b,w1
;    ld.16   a,0x4321
;    st.16   0(B),a
;    ld.16   a,0x3333
;    cmpb.ne.16	a,0x3333,fail
;    ld.16   a,0(B)
;    cmpb.ne.16	a,0x4321,fail
;
;    ; That's enough for now.
;    br	pass
;

  ; tests complete
success:
	ldi r5, 0xAA
  hlt

fail:
  ldi r5, 0xFF
  hlt