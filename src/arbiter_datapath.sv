module arbiter_datapath
(
	input logic [1:0] read_mux_sel,
	input logic dmem_read,
	input logic imem_read,
	output logic mem_read,

	input logic write_mux_sel,
	input logic dmem_write,
	output logic mem_write,

	input logic [1:0] addr_mux_sel,
	input logic [31:0] dmem_addr,
	input logic [31:0] imem_addr,
	output logic [31:0] mem_addr,

	input logic wdata_mux_sel,
	input logic [255:0] dmem_wdata,
	output logic [255:0] mem_wdata,

	input logic dmem_resp_mux_sel,
	input logic imem_resp_mux_sel,
	input logic mem_resp,
	output logic dmem_resp,
	output logic imem_resp,

	input logic dmem_rdata_mux_sel,
	input logic imem_rdata_mux_sel,
	input logic [255:0] mem_rdata,
	output logic [255:0] imem_rdata,
	output logic [255:0] dmem_rdata
);

mux4 #(.width(1)) read_mux
(
	.sel(read_mux_sel),
	.a(1'd0),
	.b(dmem_read),
	.c(imem_read),
	.d(1'd0),
	// Output
	.e(mem_read)
);

mux2 #(.width(1)) write_mux
(
	.sel(write_mux_sel),
	.a(1'd0),
	.b(dmem_write),
	// Output
	.c(mem_write)
);

mux4 addr_mux
(
	.sel(addr_mux_sel),
	.a(32'd0),
	.b(dmem_addr),
	.c(imem_addr),
	.d(32'd0),
	// Output
	.e(mem_addr)
);

mux2 #(.width(256)) wdata_mux
(
	.sel(wdata_mux_sel),
	.a(256'd0),
	.b(dmem_wdata),
	// Output
	.c(mem_wdata)
);

mux2 #(.width(1)) dmem_resp_mux
(
	.sel(dmem_resp_mux_sel),
	.a(1'd0),
	.b(mem_resp),
	// Output
	.c(dmem_resp)
);

mux2 #(.width(1)) imem_resp_mux
(
	.sel(imem_resp_mux_sel),
	.a(1'd0),
	.b(mem_resp),
	// Output
	.c(imem_resp)
);

mux2 #(.width(256)) dmem_rdata_mux
(
	.sel(dmem_rdata_mux_sel),
	.a(256'd0),
	.b(mem_rdata),
	// Output
	.c(dmem_rdata)
);

mux2 #(.width(256)) imem_rdata_mux
(
	.sel(imem_rdata_mux_sel),
	.a(256'd0),
	.b(mem_rdata),
	// Output
	.c(imem_rdata)
);

endmodule : arbiter_datapath

