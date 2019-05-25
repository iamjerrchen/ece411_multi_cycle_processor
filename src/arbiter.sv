module arbiter
(
	input clk,

	/* From imem */
	input imem_read,
	input [31:0] imem_addr,

	/* To imem */
	output imem_resp,
	output [255:0] imem_rdata,

	/* From dmem */
	input dmem_read,
	input dmem_write,
	input [31:0] dmem_addr,
	input [255:0] dmem_wdata,

	/* To dmem */
	output dmem_resp,
	output [255:0] dmem_rdata,

	/* From mem */
	input mem_resp,
	input [255:0] mem_rdata,

	/* To mem */
	output mem_read,
	output mem_write,
	output [31:0] mem_addr,
	output [255:0] mem_wdata
);

logic [1:0] read_mux_sel;
logic write_mux_sel;
logic [1:0] addr_mux_sel;
logic wdata_mux_sel;
logic dmem_resp_mux_sel;
logic imem_resp_mux_sel;
logic dmem_rdata_mux_sel;
logic imem_rdata_mux_sel;

arbiter_control control
(
	.clk(clk),
	.imem_read(imem_read),
	.dmem_read(dmem_read),
	.dmem_write(dmem_write),
	.mem_resp(mem_resp),
	// Output
	.read_mux_sel(read_mux_sel),
	.write_mux_sel(write_mux_sel),
	.addr_mux_sel(addr_mux_sel),
	.wdata_mux_sel(wdata_mux_sel),
	.dmem_resp_mux_sel(dmem_resp_mux_sel),
	.imem_resp_mux_sel(imem_resp_mux_sel),
	.dmem_rdata_mux_sel(dmem_rdata_mux_sel),
	.imem_rdata_mux_sel(imem_rdata_mux_sel)
);

arbiter_datapath datapath
(
	.read_mux_sel(read_mux_sel),
	.dmem_read(dmem_read),
	.imem_read(imem_read),
	.mem_read(mem_read),
	.write_mux_sel(write_mux_sel),
	.dmem_write(dmem_write),
	.mem_write(mem_write),
	.addr_mux_sel(addr_mux_sel),
	.dmem_addr(dmem_addr),
	.imem_addr(imem_addr),
	.mem_addr(mem_addr),
	.wdata_mux_sel(wdata_mux_sel),
	.dmem_wdata(dmem_wdata),
	.mem_wdata(mem_wdata),
	.dmem_resp_mux_sel(dmem_resp_mux_sel),
	.imem_resp_mux_sel(imem_resp_mux_sel),
	.mem_resp(mem_resp),
	.dmem_resp(dmem_resp),
	.imem_resp(imem_resp),
	.dmem_rdata_mux_sel(dmem_rdata_mux_sel),
	.imem_rdata_mux_sel(imem_rdata_mux_sel),
	.mem_rdata(mem_rdata),
	.imem_rdata(imem_rdata),
	.dmem_rdata(dmem_rdata)
);

endmodule : arbiter
