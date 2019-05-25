basic_test.s:
.align 4
.section .text
.globl _start

_start:
	addi x1, x1, 1 # load x1 with constant 1

	# Test add
	add x2, x1, x1 # expect 2 in x2

	# Test slt[u]
	slt x3, x1, x2 # expect 1 in x3
	sltu x3, x2, x1 # expect 0 in x3

	# Test or and and
	or x4, x1, x4 # expect 1 in x4
	and x4, x0, x4 # expect 0 in x4

	# Test xor
	addi x5, x0, 25 
	xor x5, x5, x5 # expect 0 in x5

	# sll, srl 
	addi x6, x1, 0
	sll x6, x6, x1 # expect 2 in x6
	srl x6, x6, x1 # expect 1 in x6

	# test sub
	sub x7, x6, x1 # subtract x6-x1, expect 0
	sub x7, x7, x1 # expect -1
	sub x7, x7, x1 # expect -2

	# test sra
	sra x7, x7, x1 # expect -1
	
halt:
	beq x0, x0, halt
