;
; group f, test 2
;
; lcr, scr





; declare symbols here

;SYM(next1)
;SYM(next2)

; load control register into R1
; only mode 1 bit should be set (trap mode)

	lcr r1
	ldi r2, 1
	skip.eq r1, r2
	br fail
br next1
hlt


next1:
; enable IRQ (in reality this should not be done in trap mode)
	ldi r2, 9
	wcr r2
	lcr r1
	skip.eq r1, r2
	br fail
br next2
hlt



next2:
; read the user space CR, its default value is 8
; THIS WILL FAIL ON THE GATE LEVEL SIMULATOR!!
	lcr.u r1
	ldi r2, 8
	skip.eq r1, r2
	br fail
br next3
hlt


next3:
; write a value to it
	wcr.u r0
	lcr.u r1
	skip.eq r1, r0
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

