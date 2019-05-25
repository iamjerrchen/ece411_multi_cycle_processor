import rv32i_types::*;

module mp3
(
	input clk,

	input logic mem_resp,
	input logic [255:0] mem_rdata,
	
	output rv32i_word mem_addr,
	output logic [255:0] mem_wdata,
	output logic mem_read,
	output logic mem_write
);

// instruction memory
logic imem_resp;
rv32i_word imem_rdata;

logic imem_read;
rv32i_word imem_addr;

// data memory
logic cpu_dmem_resp;
rv32i_word cpu_dmem_rdata;
rv32i_word cpu_dmem_addr; 
logic cpu_dmem_read;
logic cpu_dmem_write;
logic cache_dmem_resp;
rv32i_word cache_dmem_rdata;
rv32i_word cache_dmem_addr; 
logic cache_dmem_read;
logic cache_dmem_write;

rv32i_word dmem_wdata;
logic [3:0] dmem_wmask;

logic pht_prediction;
logic pht_misprediction;
logic btb_hit;
logic btb_miss;
logic cache_hit;
logic cache_miss;
logic cache_writeback;

cpu cpu 
(
	.clk(clk),
	.imem_resp(imem_resp),
	.imem_rdata(imem_rdata),
	.imem_read(imem_read),
	.imem_addr(imem_addr),
	.dmem_resp(cpu_dmem_resp),
	.dmem_rdata(cpu_dmem_rdata),
	.dmem_read(cpu_dmem_read),
	.dmem_write(cpu_dmem_write),
	.dmem_addr(cpu_dmem_addr),
	.dmem_wdata(dmem_wdata),
	.dmem_wmask(dmem_wmask),
	.performance_pht_prediction(pht_prediction),
	.performance_pht_misprediction(pht_misprediction),
	.performance_btb_hit(btb_hit),
	.performance_btb_miss(btb_miss)
);

performance_counters performance_counters
(
	.clk(clk),
	.pht_prediction(pht_prediction),
	.pht_misprediction(pht_misprediction),
	.btb_hit(btb_hit),
	.btb_miss(btb_miss),
	.cache_hit(cache_hit),
	.cache_miss(cache_miss),
	.cache_writeback(cache_writeback),
	.cpu_dmem_addr(cpu_dmem_addr),
	.cpu_dmem_read(cpu_dmem_read),
	.cpu_dmem_write(cpu_dmem_write),
	.cache_dmem_rdata(cache_dmem_rdata),
	.cache_dmem_resp(cache_dmem_resp),
	.cpu_dmem_rdata(cpu_dmem_rdata),
	.cpu_dmem_resp(cpu_dmem_resp),
	.cache_dmem_addr(cache_dmem_addr),
	.cache_dmem_read(cache_dmem_read),
	.cache_dmem_write(cache_dmem_write)
);

cache_organization caches
(
	.clk(clk),
	.imem_read(imem_read),
	.imem_addr(imem_addr),
	.imem_resp(imem_resp),
	.imem_rdata(imem_rdata),
	.dmem_read(cache_dmem_read),
	.dmem_write(cache_dmem_write),
	.dmem_addr(cache_dmem_addr),
	.dmem_wdata(dmem_wdata),
	.dmem_wmask(dmem_wmask),
	.dmem_resp(cache_dmem_resp),
	.dmem_rdata(cache_dmem_rdata),
	.pmem_resp(mem_resp),
	.pmem_rdata(mem_rdata),
	.pmem_addr(mem_addr),
	.pmem_wdata(mem_wdata),
	.pmem_read(mem_read),
	.pmem_write(mem_write),
	.performance_cache_hit(cache_hit),
	.performance_cache_miss(cache_miss),
	.performance_cache_writeback(cache_writeback)
);

endmodule : mp3
