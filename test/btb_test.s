btb_test.s:
.align 4
.section .text
.globl _start

# every address is a word
_start: 

	andi x1, x0, 0
	andi x2, x0, 0
	addi x2, x2, 5 # initialize x2 to 5
	jal x10, SPOT_TWO # this pc --> BTB --> spot_two

SPOT_ONE:

	jal x10, SPOT_THREE

SPOT_TWO:

	addi x1, x1, 1 # x1 + 1 --> x1
	bne x2, x1, SPOT_TWO
	jal x10, SPOT_ONE

SPOT_THREE:

	addi x1, x1, -1 # x1 - 1 --> x1
	bne x1, x0, SPOT_ONE

halt:
	beq x0, x0, halt




