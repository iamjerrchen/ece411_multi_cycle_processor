import rv32i_types::*;

module ID_EX_reg
(
	input clk,
	input load,
	input overwrite_load,

	input rv32i_word pc_plus4_in,
	output rv32i_word pc_plus4_out,

	input rv32i_control_word control_word_in,
	output rv32i_control_word control_word_out,

	input rv32i_word imm_in,
	output rv32i_word imm_out,

	input rv32i_reg rs1_in,
	output rv32i_reg rs1_out,

	input rv32i_reg rs2_in,
	output rv32i_reg rs2_out,

	input rv32i_reg rd_in,
	output rv32i_reg rd_out,

	input rv32i_word rs1_data_in,
	output rv32i_word rs1_data_out,

	input rv32i_word rs2_data_in,
	output rv32i_word rs2_data_out,

	input is_branch_in,
	output is_branch_out,

	input [3:0] pht_idx_in,
	output [3:0] pht_idx_out,

	input rv32i_word pc_taken_in,
	output rv32i_word pc_taken_out,

	input pht_prediction_in,
	output pht_prediction_out
);

register pc_plus4
(
	.clk,
	.load,
	.in(pc_plus4_in),
	.out(pc_plus4_out)
);

register #(.width($bits(rv32i_control_word))) control_word
(
	.clk,
	.load,
	.in(control_word_in),
	.out(control_word_out)
);

register imm
(
	.clk,
	.load,
	.in(imm_in),
	.out(imm_out)
);

register #(.width(5)) rs1
(
	.clk,
	.load,
	.in(rs1_in),
	.out(rs1_out)
);

register #(.width(5)) rs2
(
	.clk,
	.load,
	.in(rs2_in),
	.out(rs2_out)
);

register #(.width(5)) rd
(
	.clk,
	.load,
	.in(rd_in),
	.out(rd_out)
);

register rs1_data
(
	.clk,
	.load(load || overwrite_load),
	.in(rs1_data_in),
	.out(rs1_data_out)
);

register rs2_data
(
	.clk,
	.load(load || overwrite_load),
	.in(rs2_data_in),
	.out(rs2_data_out)
);

register #(.width(1)) is_branch
(
	.clk,
	.load,
	.in(is_branch_in),
	.out(is_branch_out)
);

register #(.width(4)) pht_idx
(
	.clk,
	.load,
	.in(pht_idx_in),
	.out(pht_idx_out)
);

register pc_taken
(
	.clk,
	.load,
	.in(pc_taken_in),
	.out(pc_taken_out)
);

register #(.width(1)) pht_prediction
(
	.clk,
	.load,
	.in(pht_prediction_in),
	.out(pht_prediction_out)
);

endmodule : ID_EX_reg
