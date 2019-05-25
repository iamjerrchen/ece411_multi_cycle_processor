import rv32i_types::*;

module MEM_WB_reg
(
	input clk,
	input load,
	
	input rv32i_word pc_plus4_in,
	output rv32i_word pc_plus4_out,

	input rv32i_control_word control_word_in,
	output rv32i_control_word control_word_out,

	input rv32i_word logic_out_in,
	output rv32i_word logic_out_out,

	input rv32i_reg rd_in,
	output rv32i_reg rd_out,

	input rv32i_word MDR_in,
	output rv32i_word MDR_out
);

register pc_plus4
(
	.clk(clk),
	.load(load),
	.in(pc_plus4_in),
	.out(pc_plus4_out)
);

register #(.width($bits(rv32i_control_word))) control_word
(
	.clk(clk),
	.load(load),
	.in(control_word_in),
	.out(control_word_out)
);

register logic_out
(
	.clk(clk),
	.load(load),
	.in(logic_out_in),
	.out(logic_out_out)
);

register #(.width(5)) rd
(
	.clk(clk),
	.load(load),
	.in(rd_in),
	.out(rd_out)
);


register MDR
(
	.clk(clk),
	.load(load),
	.in(MDR_in),
	.out(MDR_out)
);

endmodule : MEM_WB_reg
