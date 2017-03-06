fail:
  defw 0xdead

pass:
  defw 0xbabe

_start_tests:
  ldi r1, 0x1ff
  addhi r1, 0x7f
  hlt