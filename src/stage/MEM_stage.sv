import rv32i_types::*;

module MEM_stage
(
	input logic clk,
	input logic load,
	
	input rv32i_word pc_plus4,
	output rv32i_word MEM_WB_pc_plus4,
	
	input rv32i_control_word control_word,
	output rv32i_control_word MEM_WB_control_word,
	
	input rv32i_word logic_out,
	output rv32i_word MEM_WB_logic_out,
	
	input rv32i_reg rd,
	output rv32i_reg MEM_WB_rd,
	
	input rv32i_word mem_data_out,
	input logic [3:0] wmask,
	
	output rv32i_word MEM_WB_MDR,
	
	input logic dmem_resp,
	input logic imem_resp,
	input logic IF_ready_out,
	input rv32i_word dmem_rdata,
	
	output rv32i_word dmem_wdata,
	output rv32i_word dmem_addr,
	output logic dmem_write, 
	output logic dmem_read,
	output logic [3:0] dmem_wmask,

	output logic MEM_ready_out
	
);

logic dmem_ready_out;
rv32i_word mdr_out;

assign MEM_WB_pc_plus4 = pc_plus4;
assign MEM_WB_control_word = control_word;
assign MEM_WB_logic_out = logic_out;
assign MEM_WB_rd = rd;

assign dmem_wdata = mem_data_out;

assign dmem_addr = {logic_out[31:2],2'b00};
assign dmem_read = !dmem_ready_out && control_word.mem_read;
assign dmem_write = !dmem_ready_out && control_word.mem_write;
assign dmem_wmask = wmask;

mem_ready_reg dmem_ready
(
	.clk(clk),
	.mem_resp(dmem_resp && (!imem_resp && !IF_ready_out)),
	.global_load(load),
	// Output
	.ready(dmem_ready_out)
);

register mdr
(
	.clk(clk),
	.load(dmem_resp),
	.in(dmem_rdata),
	.out(mdr_out)
);

mux2 reg_or_mem_mux
(
	.sel(dmem_resp),
	.a(mdr_out),
	.b(dmem_rdata),
	// Output
	.c(MEM_WB_MDR)
);

mux2 #(.width(1)) MEM_ready_mux
(
	.sel(control_word.MEM_ready_mux_sel),
	.a(1'd1),
	.b(dmem_ready_out),
	.c(MEM_ready_out)
);

endmodule : MEM_stage
