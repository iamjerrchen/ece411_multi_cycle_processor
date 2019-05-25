import rv32i_types::*;

module WB_stage
(
	input rv32i_word pc_plus4,
	input rv32i_word logic_out,
	input rv32i_word MDR,
	input rv32i_control_word control_word,

	output rv32i_word regfile_in
);

rv32i_word load_data;

load_formatter load_formatter
(
	.in(MDR),
	.mem_offset(logic_out[1:0]),
	.funct3(control_word.load_formatter_op),
	// output
	.out(load_data)
);

mux4 regfile_mux
(
	.sel(control_word.regfile_mux_sel),
	.a(logic_out),
	.b(pc_plus4),
	.c(load_data),
	.d(32'd0),
	.e(regfile_in)
);

endmodule : WB_stage

