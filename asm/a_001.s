fail:
  defw 0xdead

pass:
  defw 0xbeef

  ; lets see if we can branch
_start:
  br _start_tests
  hlt
  hlt
  hlt

  ; perform immediate tests
_start_tests:
  ldi 2, r1
  addskpi.z 2, r1, r3  ; equal so skip next instr
  br fail
  addskpi.nz 2, r1, r3 ; still equal so should NOT skip
  br pass
  br fail
  hlt
  hlt

