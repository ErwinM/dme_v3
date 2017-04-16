;
; group f, test 2
;
; lcr, scr

include(tmacros.h)

.code 0x100

INIT_TEST(f,0x02)

; declare symbols here

;SYM(next1)

; load control register into R1
; only IRQ should be enabled (value 8)
brk
	lcr r1
	addskpi.z r2, r1, 8
	PASS(next1)

next1:
; disable IRQ by loading a new value into CR
	scr r0
	lcr r1
	addskp.z r2, r1, r0
	PASS(pass)

;   Finally, when done branch to pass
  END_TEST
