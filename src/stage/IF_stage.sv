import rv32i_types::*;

module IF_stage
(
	input clk,

	input logic global_load,

	// From IM
	input rv32i_word imem_data,
	input logic imem_resp,

	// MEM read
	input logic dmem_resp,
	input logic MEM_ready_out,

	// From EX
	input logic branch_flag,
	input logic branch_recovery,
	input EX_is_branch,
	input [3:0] EX_pht_idx,
	input rv32i_word EX_pc,
	input rv32i_word pc_branch_target,

	output logic imem_read,
	output rv32i_word imem_addr,

	output rv32i_word IF_ID_pc_plus4,
	output rv32i_word IF_ID_instruction,
	output rv32i_word IF_ID_pc_taken,
	output [3:0] IF_ID_pht_idx,
	output IF_ID_is_branch,
	output IF_ID_pht_prediction,

	output performance_btb_hit,
	output performance_btb_miss,

	output logic IF_ready_out
);

rv32i_word ir_out;
rv32i_word pc_out;
rv32i_word pc_mux_out;
rv32i_word pc_plus4;
rv32i_word reg_or_mem_out;
rv32i_opcode opcode;
rv32i_word btb_pc;

logic btb_hit;
logic pht_prediction;
logic is_jump;
logic is_branch;
logic [1:0] pc_mux_sel;
logic [3:0] bhr_out;

assign opcode = rv32i_opcode'(reg_or_mem_out[6:0]);
assign is_jump = (opcode == op_jal) || (opcode == op_jalr);
assign is_branch = (opcode == op_br);
assign IF_ID_is_branch = (is_jump || is_branch) && !branch_recovery;
assign IF_ID_pht_idx = pc_out[3:0] ^ bhr_out;
assign IF_ID_pc_taken = pc_mux_out;
assign IF_ID_pht_prediction = pht_prediction;
assign performance_btb_hit = btb_hit && (is_jump || (pht_prediction && is_branch));
assign performance_btb_miss = !btb_hit && (is_jump || (pht_prediction && is_branch));

assign pc_mux_sel[0] = btb_hit &&
	((pht_prediction && is_branch) || is_jump);
assign pc_mux_sel[1] = branch_recovery;

assign imem_read = !IF_ready_out; 
assign imem_addr = pc_out;
assign pc_plus4 = pc_out + 32'd4;
assign IF_ID_pc_plus4 = pc_plus4;

mem_ready_reg imem_ready
(
	.clk(clk),
	.mem_resp(imem_resp && (!dmem_resp && !MEM_ready_out)),
	.global_load(global_load),
	// Output
	.ready(IF_ready_out)
);

register ir
(
	.clk,
	.load(imem_resp),
	.in(imem_data),
	.out(ir_out)
);

mux2 reg_or_mem_mux
(
	.sel(imem_resp),
	.a(ir_out),
	.b(imem_data),
	// Output
	.c(reg_or_mem_out)
);

mux2 instruction_mux
(
	.sel(branch_recovery),
	.a(reg_or_mem_out),
	.b(32'd0),
	.c(IF_ID_instruction)
);

pc_register pc
(
	.clk(clk),
	.load(global_load),
	.in(pc_mux_out),
	.out(pc_out)
);

mux4 pc_mux
(
	.sel(pc_mux_sel),
	.a(pc_plus4),
	.b(btb_pc),
	.c(pc_branch_target),
	.d(pc_branch_target),
	// Output
	.e(pc_mux_out)
);

branch_history_register bhr
(
	.clk,
	.EX_branch_flag(branch_flag),
	.load(EX_is_branch && global_load),
	.bhr_out(bhr_out)
);

pht pht
(
	.clk,
	.pht_idx(IF_ID_pht_idx),
	.EX_branch_flag(branch_flag),
	.EX_pht_idx(EX_pht_idx),
	.load(EX_is_branch && global_load),
	.pht_prediction(pht_prediction)
);

btb btb
(
	.clk,
	.load(EX_is_branch && global_load),
	.EX_pc_branch_target(pc_branch_target),
	.EX_pc(EX_pc),
	.IF_pc(pc_out),
	.btb_hit(btb_hit),
	.predicted_pc(btb_pc)
);

endmodule : IF_stage
