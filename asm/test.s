fail:
  defw 0xdead

pass:
  defw 0xbabe

_start_tests:
  ldi 2, r1
  addskp.z r1, r1, r3  ; equal so skip next instr
  br fail
  addskp.nz r1, r1, r3 ; still equal so should NOT skip
  br pass
  br fail
  hlt
  hlt