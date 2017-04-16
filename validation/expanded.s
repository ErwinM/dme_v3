;
; group f, test 2
;
; lcr, scr





.code 0x100


ldi r2, 0x11
ldi r1, char @f
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, 0x02
stb.b 0(r2), r1


; declare symbols here

;SYM(next1)

; load control register into R1
; only IRQ should be enabled (value 8)
brk
	lcr r1
	addskpi.z r2, r1, 8
	br fail
br next1
hlt


next1:
; disable IRQ by loading a new value into CR
	scr r0
	lcr r1
	addskp.z r2, r1, r0
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

