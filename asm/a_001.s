fail:
  defw 0xdead

pass:
  defw 0xbabe

  ; convention is:
  ; - test group in R3
  ; - test num in R5


  ; lets see if we can branch
_start:
  br next1
  hlt
  hlt
  hlt

  ; perform immediate tests
next1:

  ldi r1, 2
  addskpi.z r3, r1, 2   ; equal so skip next instr
  br fail
  addskpi.nz r3, r1, 2  ; still equal so should NOT skip
  br next2
  br fail
  hlt
  hlt

  ; lets try register move and compares
next2:

  ldi r1, 3
  add r2, r1, r0        ; move r1 to r2
  addskp.z r3, r1, r2   ; equal so skip next instr
  br fail
  addskp.nz r3, r1, r2  ; still equal so should NOT skip
  br next3
  br fail
  hlt
  hlt

  ; Check register copies
next3:
  ldi r1, 0x8080
  ldi r2, 0x0808
  addskp.nz r3, r1, r2    ; should  skip next instruction
  br fail
  add r2, r1, r0          ; copy r1 to r2
  addskp.z r3, r1, r2     ; should skip next instruction
  br fail
  addskp.z r3, r3, r0     ; r3 holds 0 from last compare - should skip
  br fail
  ldi r4, 0x8888
  addskp.nz r3, r1, r4    ; should skip next instruction
  br fail
  add r4, r1, r0
  addskip.z r3, r4, r1    ; equal - should skip
  br fail

  ; tests complete
  br pass