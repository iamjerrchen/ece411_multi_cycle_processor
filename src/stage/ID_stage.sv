import rv32i_types::*;

module ID_stage
(
	input clk,
	input branch_recovery,

	// Data Forwarding
	input overwrite_load,
	input rv32i_reg rs1_prev,
	input rv32i_reg rs2_prev,
	
	// To Regfile
	input logic regfile_load,
	input rv32i_word regfile_in,
	input rv32i_reg regfile_dest,
	
	// From IF/ID reg
	input rv32i_word pc_plus4,
	input rv32i_word instr,
	input logic is_branch,

	// To ID/EX reg
	output rv32i_word ID_EX_pc_plus4,
	output rv32i_control_word ID_EX_control_word,
	output rv32i_word ID_EX_imm,
	output rv32i_reg ID_EX_rs1,
	output rv32i_reg ID_EX_rs2,
	output rv32i_reg ID_EX_rd,
	output rv32i_word ID_EX_rs1_data,
	output rv32i_word ID_EX_rs2_data,
	output logic ID_EX_is_branch
);

// internal logic signals
rv32i_reg rs1, rs1_addr;
rv32i_reg rs2, rs2_addr;
rv32i_reg rd;
rv32i_control_word control_word;
rv32i_word i_imm, s_imm, b_imm, u_imm, j_imm;
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_opcode opcode;

assign ID_EX_rs1 = rs1;
assign ID_EX_rs2 = rs2;
assign ID_EX_pc_plus4 = pc_plus4;

instr_decoder instruction_decoder
(
	.data(instr),
	// output
	.funct3(funct3),
	.funct7(funct7),
	.opcode(opcode),
	.i_imm(i_imm),
	.s_imm(s_imm),
	.b_imm(b_imm),
	.u_imm(u_imm),
	.j_imm(j_imm),
	.rs1(rs1),
	.rs2(rs2),
	.rd(rd)
);

control_rom control_rom
(
	.opcode(opcode),
	.funct3(funct3),
	.funct7(funct7),
	.control_word(control_word)
);

mux8 imm_mux
(
	.sel(control_word.imm_mux_sel),
	.a(32'd0),
	.b(i_imm),
	.c(b_imm),
	.d(j_imm),
	.e(s_imm),
	.f(u_imm),
	// output
	.i(ID_EX_imm)
);

mux2 #(.width(5)) rd_mux
(
	.sel(branch_recovery),
	.a(rd),
	.b(5'd0),
	// output
	.c(ID_EX_rd)
);

mux2 #(.width($bits(rv32i_control_word))) control_word_mux 
(
	.sel(branch_recovery),
	.a(control_word),
	.b(36'd0),
	// output
	.c(ID_EX_control_word)
);

mux2 #(.width(5)) rs1_mux
(
	.sel(overwrite_load),
	.a(rs1),
	.b(rs1_prev),
	// output
	.c(rs1_addr)
);

mux2 #(.width(5)) rs2_mux
(
	.sel(overwrite_load),
	.a(rs2),
	.b(rs2_prev),
	// output
	.c(rs2_addr)
);

regfile regfile
(
	.clk(clk),
	// From WB
	.load(regfile_load),
	.in(regfile_in),
	.dest(regfile_dest),
	// From decode
	.src_a(rs1_addr),
	.src_b(rs2_addr),
	// output
	.reg_a(ID_EX_rs1_data),
	.reg_b(ID_EX_rs2_data)
);

mux2 #(.width(1)) is_branch_mux
(
	.sel(branch_recovery),
	.a(is_branch),
	.b(0),
	// output
	.c(ID_EX_is_branch)
);

endmodule : ID_stage
