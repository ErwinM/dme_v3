;	DME assembly file, generated by lcc 4.2

;  temp boiler plate puts SP at 0x2000 and branches to main
	ld16	r1, 0x2000
	mov	sp, r1
	addi	r1, pc, 2
	br	_main
	hlt


	.data 0x1000
;	.global _result
_result:
	defw 0x5
;	.global _foo
;	.code
_foo:
	push	r1
	push	bp
	mov	bp, sp
	ldi	r4, 6
	sub	sp, sp, r4
	ld16	r4, 10
	stw	-6(bp),r4
	stw	-4(bp),r0
	ld16	r4, 12
	stw	-2(bp),r4
	ldw	r4,4(bp)
	shl	r4, r4, 1 ; [via index]
	la16	r3, -6
	add	r3, r3, bp
	ldw	r1,r4(r3)
L1:
	mov	sp, bp
	pop	bp
	pop	pc

;	.global _main
_main:
	push	r1
	push	bp
	mov	bp, sp
	ldi	r4, 2
	sub	sp, sp, r4
	ld16	r4, 2
	stw	-2(bp),r4
	ldw	r4,-2(bp)
	push	r4
	addi	r1,pc,2
	br	_foo ; jaddr
	la16	r3,_result
	stw	r0(r3),r1
	mov	r1,r0
L4:
	mov	sp, bp
	pop	bp
	pop	pc

;	.end
