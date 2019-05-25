import rv32i_types::*;

module EX_MEM_reg
(
	input logic clk,
	input logic load,
	
	input rv32i_word pc_plus4_in,
	output rv32i_word pc_plus4_out,
		
	input rv32i_control_word control_word_in,
	output rv32i_control_word control_word_out,
	
	input rv32i_word logic_out_in,
	output rv32i_word logic_out_out,
	
	input rv32i_reg rd_in,
	output rv32i_reg rd_out,
	
	input rv32i_word mem_data_out_in,
	output rv32i_word mem_data_out_out,

	input logic [3:0] wmask_in,
	output logic [3:0] wmask_out
);

register pc_plus4
(
	.clk(clk),
	.load(load),
	.in(pc_plus4_in),
	.out(pc_plus4_out)
);

// We believe its 36
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

register mem_data_out
(
	.clk(clk),
	.load(load),
	.in(mem_data_out_in),
	.out(mem_data_out_out)
);

register #(.width(4)) wmask
(
	.clk(clk),
	.load(load),
	.in(wmask_in),
	.out(wmask_out)
);

endmodule : EX_MEM_reg
