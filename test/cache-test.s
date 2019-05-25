cache_test.s:
.align 4
.section .text
.globl _start

# every address is a word
_start: # start is line aligned
	lw x2, %lo(one)(x0) 		# clean read miss
	lh x3, %lo(onea)(x0)  		# read hit
	lb x4, %lo(oneb)(x0)  		# read hit
	lb x5, %lo(onec)(x0)  		# read hit

	lw x6, %lo(nine)(x0) 		# expect eeeeeeee, clean read miss into way1
	lbu x7, %lo(ninea)(x0) 		# expect 000000ee, hit read

	lw x8, %lo(seventeen)(x0) 	# expect the nice number, clean read miss, eject way 0
	lb x9, %lo(seventeena)(x0)  # expect nice, hit read

	addi x10, x2, 0 			# move aabbccdd into x10
	sw x10, %lo(two)(x0) 		# write miss
	not x10, x10
	sw x10, %lo(twoa)(x0) 		# write hit
	lw x11, %lo(two)(x0) 		# read hit, should be aabbccdd
	lw x12, %lo(twoa)(x0) 		# read hit, should be ~aabbccdd = 55443322

	lw x13, %lo(ten)(x0) 		# read into other way
	lw x14, %lo(eighteen)(x0) 	# don't care about value, flush original way, dirty write

	lw x15, %lo(two)(x0)		# should be aabbccdd
	lw x16, %lo(twoa)(x0) 		# should be ~aabbccdd = 55443322

halt:
	beq x0, x0, halt

.section .rodata
.balign 256

# one cache line
one:		.word 0xaabbccdd
onea:		.word 0x1a1a1a1a
oneb:		.word 0x1b1b1b1b
onec:		.word 0x1c1c1c1c
			.word 0x11111111
			.word 0x11111111
			.word 0x11111111
			.word 0x11111111

two:		.word 0x22222222
twoa:		.word 0x22222222
			.word 0x22222222
			.word 0x22222222
			.word 0x22222222
			.word 0x22222222
			.word 0x22222222
			.word 0x22222222

three:		.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

four:		.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

five:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

six:		.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

seven:		.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

eight:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

nine:		.word 0xeeeeeeee
ninea: 		.word 0xeeeeeeee
			.word 0x99999999
			.word 0x99999999
			.word 0x99999999
			.word 0x99999999
			.word 0x99999999
			.word 0x99999999

ten:		.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

eleven:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

twelve:	
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

thirteen:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

fourteen:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

fifteen:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

sixteen:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

seventeen:		.word 0x69696969
seventeena: .word 0x69696969
			.word 0x17171717
			.word 0x17171717
			.word 0x17171717
			.word 0x17171717
			.word 0x17171717
			.word 0x17171717

eighteen:	.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

nineteen:	.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

twenty:		.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

twentyone:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

twentytwo:	
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

twentythree:
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

twentyfour:	
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000

