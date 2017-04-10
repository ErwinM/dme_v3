; lets test a signed less than

.code 0x100

d1:
defw    0x7000
defw    0x8400

	la16	r4, d1
	mov r5,r4
	ldw r1, 0(bp)
	ldw r2, 2(bp)
	skip.ult r1, r2
	br onwaar
	ldi r5, 0xaa
	hlt


onwaar:
	ldi r5, 0xff
	hlt