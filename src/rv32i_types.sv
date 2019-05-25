package rv32i_types;

typedef enum bit [6:0] {
    op_lui   = 7'b0110111, //load upper immediate (U type)
    op_auipc = 7'b0010111, //add upper immediate PC (U type)
    op_jal   = 7'b1101111, //jump and link (J type)
    op_jalr  = 7'b1100111, //jump and link register (I type)
    op_br    = 7'b1100011, //branch (B type)
    op_load  = 7'b0000011, //load (I type)
	op_store = 7'b0100011, //store (S type)
    op_imm   = 7'b0010011, //arith ops with register/immediate operands (I type)
    op_reg   = 7'b0110011, //arith ops with register operands (R type)
    op_csr   = 7'b1110011  //control and status register (I type)
} rv32i_opcode;

typedef enum bit [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101,
    bltu = 3'b110,
    bgeu = 3'b111
} branch_funct3_t;

typedef enum bit [2:0] {
    lb  = 3'b000,
    lh  = 3'b001,
    lw  = 3'b010,
    lbu = 3'b100,
    lhu = 3'b101
} load_funct3_t;

typedef enum bit [2:0] {
    sb = 3'b000,
    sh = 3'b001,
    sw = 3'b010
} store_funct3_t;

typedef enum bit [2:0] {
    add  = 3'b000, //check bit30 for sub if op_reg opcode
    sll  = 3'b001,
    slt  = 3'b010,
    sltu = 3'b011,
    axor = 3'b100,
    sr   = 3'b101, //check bit30 for logical/arithmetic
    aor  = 3'b110,
    aand = 3'b111
} arith_funct3_t;

typedef enum bit [2:0] {
    alu_add = 3'b000,
    alu_sll = 3'b001,
    alu_sra = 3'b010,
    alu_sub = 3'b011,
    alu_xor = 3'b100,
    alu_srl = 3'b101,
    alu_or  = 3'b110,
    alu_and = 3'b111
} alu_ops;

typedef logic [31:0] rv32i_word;
typedef logic [4:0] rv32i_reg;
typedef logic [3:0] rv32i_mem_wmask;

typedef enum bit [2:0] {
	null_imm = 3'd0,
	i_imm = 3'd1,
	b_imm = 3'd2,
	j_imm = 3'd3,
	s_imm = 3'd4,
	u_imm = 3'd5
} imm_sel_t;

typedef enum bit [1:0] {
	null_op = 2'd0,
	jal_op = 2'd1,
	jalr_op = 2'd2,
	br_op = 2'd3
} pc_branch_target_ops;

typedef struct packed {
	rv32i_opcode opcode;//35:29

	// ID controls
	imm_sel_t imm_mux_sel;//28:26

	// EX controls
	logic [1:0] op1_mux_sel;//25:24
	logic op2_mux_sel;//23
	alu_ops alu_op;//22:20
	branch_funct3_t cmp_op;//19:17
	store_funct3_t store_formatter_op;//16:14
	logic logic_mux_sel;//13
	pc_branch_target_ops pc_branch_target_op;//12:11
	logic is_branch_instr;//10
	logic is_jump_instr;//9
	
	// MEM controls
	logic mem_write;//8
	logic mem_read;//7
	logic MEM_ready_mux_sel;//6
	
	// WB controls
	logic load_regfile;//5
	logic [1:0] regfile_mux_sel;//4:3
	load_funct3_t load_formatter_op;// 2:0

} rv32i_control_word;

endpackage : rv32i_types

