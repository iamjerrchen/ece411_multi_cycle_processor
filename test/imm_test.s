basic_test.s:
.align 4
.section .text
.globl _start

_start:
	# Immediate tests
	addi x1, x1, 64 # x1 = 64
	nop
	nop

	# Test set less than
	slti x2, x1, 69 # expect 1 bc 64 < 69
	slti x3, x1, -20 # expect 0 bc 64 !< -20
	slti x4, x1, 20 # expect 0 bc 64 !< -20
	sltiu x5, x1, -20 # expect 1

	# and
	andi x6, x1, 0 # expect 0
	andi x7, x1, 0xFFFFFFFF # expect 64

	# or
	ori x8, x1, 0xFFFFFFFF # expect 0xFFFFFFFF
	ori x9, x1, 0 # expect 64

	# xor
	xori x10, x1, -1 # expect 0xFFFFFFBF

	# slli
	slli x11, x1, 1 # expect 128
	slli x12, x1, 2 # expect 256

	# srli
	srli x13, x1, 1 # expect 32

	# srai
	addi x31, x31, -1
	nop
	nop
	srai x14, x31, 1 # should get -1

	# lui
	lui x15, 0xAAAAA # expect 0xAAAAA000

	# auipc
	auipc x16, 0xAAAAA # expect 0xAAAAA000 + some pc value

halt:
	beq x0, x0, halt

.section .rodata
one:		.word 0xaaaaaaaa
two:		.word 0xbbbbbbbb
three:		.word 0xcccccccc
result:		.word 0x00000000
