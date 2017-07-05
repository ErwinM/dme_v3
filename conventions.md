syscall
-------
syscall number should be passed in a reg (not r1 cause this has the trapnr (=syscall))
should the syscall instruction take an argument and do this, or should programmer just do this?
(putting it in syscall would in practice come down to an extra register copy i think...)

e.g.
  ldi r1, 12
  syscall r1

or i could pass an immediate got 9 encoding bits..thats plenty -> this would save 1 cycle.. However, the number will
probably be in a reg already..


Paging
------
the syntax is: wpte logic PAGE [max32] -> physical PAGE [max256]
the physical page should be loaded into the high byte (shl 8), we should not do this in hardware because we also want to set the low byte as status.
wptb is always a multiple of 32 (0, 32, 64, 96).

		note: should writing page take into account ptb? if not, then its not max32

PTE
---



todo:
- error when page not present
- error when trying to access system page from user mode


Memory map
----------
// 0x0000 - 0xff6f -> RAM
// 0xff70 - 0xff7f -> Interrupt vector (16 instructions max, push fault_nr and branch_)
// 0xff80 - 0xff8f -> 7SEG display (and other onboard i/o later (e.g. switches and buttons))
// 0xff90 - 0xff9f -> UART 16450