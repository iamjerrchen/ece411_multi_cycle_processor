pht_test.s:
.align 4
.section .text
.globl _start

# every address is a word
_start: 

	andi x1, x0, 0	# clear x1
	addi x2, x0, 10 # 10 --> x2
	addi x3, x0, 5 # 5 --> x3

LOOP_ONE:
	
	addi x1, x1, 1
	bne x1, x2, LOOP_ONE

LOOP_TWO:

	addi x1, x1, -1
	bne x1, x3, LOOP_TWO
	
LOOP_THREE:
	
	bne x0, x0, halt

LOOP_FOUR:
	
	addi x1, x1, -1
	bne x0, x1, LOOP_THREE

halt:
	beq x0, x0, halt




