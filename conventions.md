syscall
-------
syscall number should be passed in a reg (r1?)
should the syscall instruction take an argument and do this, or should programmer just do this?
(putting it in syscall would in practice come down to an extra register copy i think...)

e.g.
  ldi r1, 12
  syscall r1

or i could pass an immediate got 9 encoding bits..thats plenty -> this would save 1 cycle.. However, the number will
probably be in a reg already..



Paging
------
the synthax is: wpte logic PAGE [max32] -> physical PAGE [max512]
the physical page should be loaded into the high byte (shl 8), we shouldnt do this in hardware because we also want to set the low byte as status.

todo:
- error when page not present
- error when trying to access system page from user mode
