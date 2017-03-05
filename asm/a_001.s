pass:
  defw 0xbeef

fail:
  defw 0xdead


_start_tests:
  ldi 2, r1
  ldi 2, r2
  addskpi.z 1, r2, r3
  br fail
  br pass