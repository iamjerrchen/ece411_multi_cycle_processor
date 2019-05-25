branch_test.s:
.align 4
.section .text
.globl _start

_start:
	addi x1, x0, 1
	beq x0, x0, dont
	addi x2, x0, -1
	addi x2, x0, -2
	addi x2, x0, -3
	addi x2, x0, -4

good:
	addi x3, x0, 1
	beq x0, x0, good
	addi x4, x0, -1
	addi x4, x0, -2
	addi x4, x0, -3
	addi x4, x0, -4

dont:
	beq x0, x1, bad
	bne x0, x0, bad
	blt x1, x0, bad
	bltu x1, x0, bad
	bge x0, x1, bad
	bgeu x0, x1, bad
	beq x0, x0, good
	addi x5, x0, -1
	addi x5, x0, -2
	addi x5, x0, -3
	addi x5, x0, -4

bad:
	addi x6, x0, -1
	beq x0, x0, bad
