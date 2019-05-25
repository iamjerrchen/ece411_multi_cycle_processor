load_test.s:
.align 4
.section .text
.globl _start

_start:
	# test load
	lw x2, FOUR # four # expect aabbccdd

	lh x3, TWO # two # expect ffffaabb
	lh x4, FOUR # four # expect ffffccdd

	lhu x5, TWO # two # expect 0000aabb
	lhu x6, FOUR # four # expect 0000ccdd

	lb x7, ONE # one # expect ffffffaa
	lbu x8, ONE # one # expect 000000aa
	lb x9, TWO # two # expect ffffffbb
	lbu x10, TWO # two # expect 000000bb
	lb x11, THREE # three # expect ffffffcc
	lbu x12, THREE # three # expect 000000cc
	lb x13, FOUR # four # expect ffffffdd
	lbu x14, FOUR # four # expect 000000dd
	add x15, x14, 0 # expect 000000dd in x15

	lhu x16, FOUR
	lhu x16, TWO # WAW, expect 0000aabb

halt:
	beq x0, x0, halt # 16 instructions away

.section .rodata
FOUR:			.byte 0xdd # we want this address
THREE: 			.byte 0xcc
TWO:			.byte 0xbb
ONE:			.byte 0xaa 

