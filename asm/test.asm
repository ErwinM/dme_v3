;	DME assembly file, generated by lcc 4.2

;  temp boiler plate puts SP at 0x64 and branches to main
	ldi	sp, 0x64
	br	_main


	.dseg
	.global _result
_result:
	defw 0x0
	.global _foo
	.cseg
_foo:
	push	bp
	mov	bp, sp
	ldi	r4, 2
	sub	sp, r4, sp
	ldw	r4,4(bp)
	addi	r4,r4,4
	stw	r4,-2(bp)
	ldw	r1,-2(bp)
L1:
	mov	sp, bp
	pop	bp
	pop	pc

	.global _main
_main:
	push	bp
	mov	bp, sp
	ldi	r4, 2
	sub	sp, r4, sp
	ldi	r4, 2
	push	r4
  ldi r4, 4
	add	r1,pc, r4
	push	r1
	br	_foo
	stw	r1,-2(bp)
	ldw	r4,-2(bp)
	addi	r4,r4,1
	stw	r4,-2(bp)
	lda	r4,_result
	ldw	r3,-2(bp)
	stwb	r3,r4,r0
	ldi	r0, 0
	mov	r1,r0
L2:
	hlt

	.end
