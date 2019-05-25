jal_jalr_test.s:
.align 4
.section .text
.globl _start

_start:
	jal x1, jump_one	

badloop_one:
	addi x3, x0, -1 
	beq x0, x0, badloop_one

jump_two:
	addi x2, x2, 1 # x2 = 2

halt:
	beq x0, x0, halt

jump_one:
	addi x2, x2, 1 # x2 = 1
	nop
	nop
	jalr x1, x1, 8 # 3 instructions after initial jump 

badloop_two:
	addi x4, x0, -1 
	beq x0, x0, badloop_two

