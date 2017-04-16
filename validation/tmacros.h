
divert(-1)
#
# Test conventions:
#
# Memory location 0x0 to 0x100 are reserved for test framework
#
# pass will copy 0xaa into reg 5 and mem 0x20
# fail will copy 0xff into reg 5 and mem 0x20
#
# the test group will be in loc 0x10
# and the subgroup will be in 0x12
# test number will be in 0x14 and r4
#
# stack will be at 0x1000 (going down)
#


# literal constant used for all tests
define(INIT_TEST,
`
ldi r2, 0x11
ldi r1, char @$1
stb.b 0(r2), r1
ldi r2, 0x13
ldi r1, $2
stb.b 0(r2), r1
')

# mem stubs
define(INIT_MEM,
`
MEM0x00_8:
	defb    0x00
MEM0x01_8:
  defb    0x01
MEM0xFF_8:
  defb    0xff
MEM0x0000_16:
  defw    0x0000
MEM0x0001_16:
  defw    0x0001
MEM0xFFFF_16:
  defw    0xffff
MEM0x7F_8:
  defb    0x7f
MEM0x80_8:
  defb    0x80
MEM0x7FFF_16:
  defw    0x7fff
MEM0x8000_16:
  defw    0x8000

b1:
  defb    0x00
w1:
  defw    0x0000
')

# set subtest and reinit regs
define(SUBTEST,
`; subtest definition (tmacros)
ldi r2, 0x14
ldi r4, $1
stb.b 0(r2), r4
mov r1, r0
mov r2, r0
mov r3, r0
mov r5, r0
')


# end of test
define(END_TEST,
`pass:
	ld16 r3, 0xff80
	ldi r5, 0xAA
	stw 0(r3), r5
  hlt

fail:
	ld16 r3, 0xff80
	ldi r5, 0xFF
	stw 0(r3), r5
  hlt
')


# set test/fail code that ends most tests
define(PASS,
`br fail
br $1
hlt
')

divert
