store_test.s:
.align 4
.section .text
.globl _start

_start:
	# test store
	la x1, one # x1 has address of label one
	lw x2, 0(x1) # one # expect aabbccdd

	# test store, x2 = aabbccdd
	sw x2, 4(x1) # store aabbccdd into memory

	sh x2, 8(x1) # store ccdd into memory
	sh x2, 10(x1) # store ccdd into memory

	sb x2, 12(x1) # store dd into memory
	sb x2, 13(x1) # store dd into memory
	sb x2, 14(x1) # store dd into memory
	sb x2, 15(x1) # store dd into memory

	lw x3, 4(x1) # result_one # expect aabbccdd
	lw x4, 8(x1) # result_two # expect ccddccdd
	lw x5, 12(x1) # result_three # expect dddddddd

halt:
	beq x0, x0, halt

.section .rodata
one:			.word 0xaabbccdd # we want this address
result_one:		.word 0x00000000
result_two:		.word 0x00000000
result_three:	.word 0x00000000

