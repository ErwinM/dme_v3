; relocation test
.code

_main:
  la16 r1, _memdata
	ldwb r2, r0, r1

.data 0x1000

_memdata:
  defw 0xbabe