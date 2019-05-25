module cache_organization
(
	input clk,

	// imem
	input logic imem_read,
	input logic [31:0] imem_addr,

	output logic imem_resp,
	output logic [31:0] imem_rdata,

	// dmem
	input logic dmem_read,
	input logic dmem_write,
	input logic [31:0] dmem_addr,
	input logic [31:0] dmem_wdata,
	input logic [3:0] dmem_wmask,

	output logic dmem_resp,
	output logic [31:0] dmem_rdata,

	// mem
	input logic pmem_resp,
	input logic [255:0] pmem_rdata,

	output logic [31:0] pmem_addr,
	output logic [255:0] pmem_wdata,
	output logic pmem_read,
	output logic pmem_write,
	
	// perf
	output performance_cache_hit,
	output performance_cache_miss,
	output performance_cache_writeback
);

logic imem_arbiter_resp;
logic imem_arbiter_read;
logic [255:0] imem_arbiter_rdata;
logic [31:0] imem_arbiter_address;

logic dmem_arbiter_resp;
logic dmem_arbiter_read;
logic dmem_arbiter_write;
logic [255:0] dmem_arbiter_rdata;
logic [255:0] dmem_arbiter_wdata;
logic [31:0] dmem_arbiter_address;

logic l2_arbiter_resp;
logic l2_arbiter_read;
logic l2_arbiter_write;
logic [255:0] l2_arbiter_rdata;
logic [255:0] l2_arbiter_wdata;
logic [31:0] l2_arbiter_address;

cache imem_cache
(
	.clk(clk),
	.pmem_rdata(imem_arbiter_rdata),
	.pmem_resp(imem_arbiter_resp),
	.mem_read(imem_read),
	.address(imem_addr),
	.mem_write(1'd0),
	.mem_wdata(32'd0),
	.mem_byte_enable(4'd0),
	// Output
	.pmem_read(imem_arbiter_read),
	.pmem_address(imem_arbiter_address),
	.mem_resp(imem_resp),
	.mem_rdata(imem_rdata)
);

cache dmem_cache
(
	.clk(clk),
	.pmem_rdata(dmem_arbiter_rdata),
	.pmem_resp(dmem_arbiter_resp),
	.mem_read(dmem_read),
	.mem_write(dmem_write),
	.address(dmem_addr),
	.mem_wdata(dmem_wdata),
	.mem_byte_enable(dmem_wmask),
	// Output
	.pmem_wdata(dmem_arbiter_wdata),
	.pmem_write(dmem_arbiter_write),
	.pmem_read(dmem_arbiter_read),
	.pmem_address(dmem_arbiter_address),
	.mem_resp(dmem_resp),
	.mem_rdata(dmem_rdata)
);

arbiter arbiter
(
	.clk(clk),
	.imem_read(imem_arbiter_read),
	.imem_addr(imem_arbiter_address),
	.imem_resp(imem_arbiter_resp),
	.imem_rdata(imem_arbiter_rdata),
	.dmem_read(dmem_arbiter_read),
	.dmem_write(dmem_arbiter_write),
	.dmem_addr(dmem_arbiter_address),
	.dmem_wdata(dmem_arbiter_wdata),
	.dmem_resp(dmem_arbiter_resp),
	.dmem_rdata(dmem_arbiter_rdata),
	.mem_resp(l2_arbiter_resp),
	.mem_rdata(l2_arbiter_rdata),
	.mem_read(l2_arbiter_read),
	.mem_write(l2_arbiter_write),
	.mem_addr(l2_arbiter_address),
	.mem_wdata(l2_arbiter_wdata)
);

l2_cache l2_cache
(
	.clk(clk),
	.pmem_rdata(pmem_rdata),
	.pmem_resp(pmem_resp),
	.mem_read(l2_arbiter_read),
	.mem_write(l2_arbiter_write),
	.address(l2_arbiter_address),
	.mem_wdata(l2_arbiter_wdata),
	.pmem_wdata(pmem_wdata),
	.pmem_write(pmem_write),
	.pmem_read(pmem_read),
	.pmem_address(pmem_addr),
	.mem_resp(l2_arbiter_resp),
	.mem_rdata(l2_arbiter_rdata),
	.performance_cache_hit(performance_cache_hit),
	.performance_cache_miss(performance_cache_miss),
	.performance_cache_writeback(performance_cache_writeback)
);

endmodule : cache_organization
