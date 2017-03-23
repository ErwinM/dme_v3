;
; Group a - basic testing
;
; test 2 - basic branching forward / backward, using LD16 and LA16 and reloc
; (testing assembler more than hardware)

.code 0x1000

; basic forward branch
_start:
	ldi r4, 1
	br next2
	br fail
	hlt

	; use la16 (leading to assembler readdressing)
next3:
	ldi r4, 3
	la16 r1, 0xbabe
	la16 r1, 0x10
	la16 r1, 0xbeef
	la16 r1, 0x12
	la16 r1, 0x1
	br next4
	br fail
	hlt


	; basic backward branch
next2:
	ldi r4, 2
	br next3
	br fail
	hlt

	; now load the value of _variable
next5:
	ldi r4, 5
	br success
	hlt

	; load address of _variable
next4:
	ldi r4, 4
	la16 r1, _variable ; this loads 0x2000 in l1 NOT 0xbabe!!
	br next5
	br fail
	hlt


  ; tests complete
success:
	ldi r5, 0xAA
  hlt

fail:
  ldi r5, 0xFF
  hlt

.data 0x2000

_variable:
	defw 0xbabe