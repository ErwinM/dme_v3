;
; group f, test 2
;
; lcr, scr

include(tmacros.h)

; declare symbols here

;SYM(next1)
;SYM(next2)

; load control register into R1
; only mode 1 bit should be set (trap mode)

	lcr r1
	ldi r2, 1
	skip.eq r1, r2
	PASS(next1)

next1:
; enable IRQ (in reality this should not be done in trap mode)
	ldi r2, 9
	wcr r2
	lcr r1
	skip.eq r1, r2
	PASS(next2)


next2:
; read the user space CR, its default value is 8
; THIS WILL FAIL ON THE GATE LEVEL SIMULATOR!!
; it does work in the iverlog simulation
	lcr.u r1
	ldi r2, 8
	skip.eq r1, r2
	PASS(next3)

next3:
; write a value to it
	wcr.u r0
	lcr.u r1
	skip.eq r1, r0
	PASS(pass)


;   Finally, when done branch to pass
  END_TEST
