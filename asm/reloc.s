; relocation test
.code 0x1000

_main:
  la16 r1, _memdata
	ldw.b r2, r0, r1




_memdata:
  defw 0xbabe