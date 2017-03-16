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
#
# stack will be at 0x1000 (going down)
#
