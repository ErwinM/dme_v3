  ; This test group tests if the basics are in place that allow all the other tests to function
	; convention is:
  ; - test num in R4


  ; lets see if we can branch
_start:
  br next1
  hlt
  hlt
  hlt

  ; perform immediate tests
next2:
  ldi r4, 2
  ldi r1, 2
  addskpi.z r3, r1, 2   ; equal so skip next instr
  br fail
  addskpi.nz r3,r1, 2 	; still equal so should NOT skip
  br next3
  br fail
  hlt
  hlt

	; backward branching
next1:
	ldi r4, 1
	br next2
	br fail
	hlt


  ; lets try register move(copies) and compares
next3:
  ldi r4, 3

  ldi r1, 3
  add r2, r1, r0        ; move r1 to r2
  addskp.z r3, r1, r2   ; equal so skip next instr
  br fail
  addskp.nz r3, r1, r2  ; still equal so should NOT skip
  br next4
  br fail
  hlt


  ; Check 16b immediate loads
next4:
  ldi r4, 4

  ldi r1, 0x1ff         ; max value for s10
  addhi r1, 0x7f        ; together should make 0xffff
  ldi r2, 1
  add r3, r1, r2        ; r1 (0xffff) and r2 (0x1) should add to 0
  addskp.z r3, r0, r3   ; 0 -> skip!
  br fail
  br next5
  hlt


  ; Check register copies
next5:
  ldi r4, 5

  ldi r1, 0x0080
  ldi r2, 0x0008
  addskp.nz r3, r1, r2    ; should  skip next instruction
  br fail
  add r2, r1, r0          ; copy r1 to r2
  addskp.z r3, r1, r2     ; should skip next instruction
  br fail
  addskp.z r3, r3, r0     ; r3 holds 0 from last compare - should skip
  br fail
  ldi r4, 0x0088
  addskp.nz r3, r1, r4    ; should skip next instruction
  br fail
  add r4, r1, r0
  addskp.z r3, r4, r1    ; equal - should skip
  br fail

  ; tests complete
  ldi r5, 0xAA
  hlt

fail:
  ldi r5, 0xFF
  hlt