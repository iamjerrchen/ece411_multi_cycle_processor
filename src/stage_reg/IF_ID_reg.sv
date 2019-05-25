import rv32i_types::*;

module IF_ID_reg
(
	input clk,
	input load,
	
	input rv32i_word pc_plus4_in,
	input rv32i_word instr_in,
	input logic is_branch_in,
	input [3:0] pht_idx_in,
	input rv32i_word pc_taken_in,
	input logic pht_prediction_in,
	
	output rv32i_word pc_plus4_out,
	output rv32i_word instr_out,
	output logic is_branch_out,
	output [3:0] pht_idx_out,
	output rv32i_word pc_taken_out,
	output logic pht_prediction_out
);

register pc_plus4
(
	.clk(clk),
	.load(load),
	.in(pc_plus4_in),
	.out(pc_plus4_out)
);

register #(.width(1)) is_branch
(
	.clk(clk),
	.load(load),
	.in(is_branch_in),
	.out(is_branch_out)
);

register #(.width(4)) pht_idx
(
	.clk(clk),
	.load(load),
	.in(pht_idx_in),
	.out(pht_idx_out)
);

register pc_taken
(
	.clk(clk),
	.load(load),
	.in(pc_taken_in),
	.out(pc_taken_out)
);

register instruction
(
	.clk(clk),
	.load(load),
	.in(instr_in),
	.out(instr_out)
);

register #(.width(1)) pht_prediction
(
	.clk(clk),
	.load(load),
	.in(pht_prediction_in),
	.out(pht_prediction_out)
);

endmodule : IF_ID_reg
