import rv32i_types::*;

module EX_stage
(
	input rv32i_word pc_plus4,
	input rv32i_control_word control_word,
	input rv32i_word imm,

	input rv32i_reg rs1,
	input rv32i_reg rs2,
	input rv32i_reg rd,

	input rv32i_word rs1_data,
	input rv32i_word rs2_data,

	input rv32i_word WB_regfile_in,
	input rv32i_word MEM_logic_out,

	input logic [1:0] fwd_unit_rs1_sel,
	input logic [1:0] fwd_unit_rs2_sel,

	input logic overwrite_load,

	input is_branch,
	input rv32i_word pc_taken,
	input pht_prediction,

	output rv32i_word EX_MEM_pc_plus4,
	output rv32i_control_word EX_MEM_control_word,
	output rv32i_word EX_MEM_logic_out,
	output rv32i_reg EX_MEM_rd,
	output rv32i_word EX_MEM_mem_data_out,
	output logic [3:0] EX_MEM_wmask,

	output logic branch_flag,
	output branch_recovery,
	output rv32i_word pc_branch_target,
	output rv32i_word source_pc,
	output performance_pht_prediction,
	output performance_pht_misprediction
);

rv32i_word valid_rs1_data;
rv32i_word valid_rs2_data;
rv32i_word op1_mux_out;
rv32i_word op2_mux_out;
rv32i_word alu_out;
rv32i_word cmp_out;
rv32i_word pc;
rv32i_word pc_branch_target_in;
logic branch_recovery_in;

assign pc = pc_plus4 - 4;
assign source_pc = pc;

assign branch_flag = (cmp_out && control_word.is_branch_instr) || control_word.is_jump_instr;
assign performance_pht_prediction = is_branch && (pht_prediction == branch_flag);
assign performance_pht_misprediction = is_branch && (pht_prediction != branch_flag);

assign EX_MEM_pc_plus4 = pc_plus4;

mux4 valid_rs1_mux
(
	.sel(fwd_unit_rs1_sel),
	.a(rs1_data),
	.b(WB_regfile_in),
	.c(MEM_logic_out),
	.d(),
	//output
	.e(valid_rs1_data)
);

mux4 valid_rs2_mux
(
	.sel(fwd_unit_rs2_sel),
	.a(rs2_data),
	.b(WB_regfile_in),
	.c(MEM_logic_out),
	.d(),
	//output
	.e(valid_rs2_data)
);

mux4 op1_mux
(
	.sel(control_word.op1_mux_sel),
	.a(valid_rs1_data),
	.b(pc),
	.c(32'd0),
	//output
	.e(op1_mux_out)
);

mux2 op2_mux
(
	.sel(control_word.op2_mux_sel),
	.a(valid_rs2_data),
	.b(imm),
	//output
	.c(op2_mux_out)
);

alu alu
(
	.aluop(control_word.alu_op),
	.a(op1_mux_out),
	.b(op2_mux_out),
	.f(alu_out)
);

cmp cmp
(
	.cmpop(control_word.cmp_op),
	.a(op1_mux_out),
	.b(op2_mux_out),
	.cmp_out(cmp_out)
);

mux2 logic_mux
(
	.sel(control_word.logic_mux_sel),
	.a(alu_out),
	.b(cmp_out),
	.c(EX_MEM_logic_out)
);

store_formatter store_formatter
(
	.in(valid_rs2_data),
	.mem_offset(alu_out[1:0]),
	.funct3(control_word.store_formatter_op),
	// Outputs
	.out(EX_MEM_mem_data_out),
	.wmask(EX_MEM_wmask)
);

pc_branch_target_calc bt_calc
(
	.op(control_word.pc_branch_target_op),
	.pc(pc),
	.imm(imm),
	.rs1_data(valid_rs1_data),
	.branch_target(pc_branch_target_in)
);

mux2 #(.width(36)) control_word_mux
(
	.sel(overwrite_load),
	.a(control_word),
	.b(36'd0),
	// Output
	.c(EX_MEM_control_word)
);

mux2 #(.width(5)) rd_mux
(
	.sel(overwrite_load),
	.a(rd),
	.b(5'd0),
	// Output
	.c(EX_MEM_rd)
);

mux2 pc_branch_target_mux
(
	.sel(branch_flag),
	.a(pc_plus4),
	.b(pc_branch_target_in),
	// Output
	.c(pc_branch_target)
);

assign branch_recovery_in = pc_taken != pc_branch_target;
mux2 #(.width(1)) branch_recovery_mux
(
	.sel(is_branch),
	.a(1'd0),
	.b(branch_recovery_in),
	// Output
	.c(branch_recovery)
);

endmodule : EX_stage

