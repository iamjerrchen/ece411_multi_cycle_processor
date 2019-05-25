module performance_counters
(
	input clk,

	// PHT data
	input pht_prediction,//0xFFE4
	input pht_misprediction,//0xFFE8

	// BTB data
	input btb_hit,//0xFFEC
	input btb_miss,//0xFFF0

	// 4 way cache data
	input cache_hit,//0xFFF4
	input cache_miss,//0xFFF8
	input cache_writeback,//0xFFFC

	input logic [31:0] cpu_dmem_addr,
	input logic cpu_dmem_read,
	input logic cpu_dmem_write,

	input logic [31:0] cache_dmem_rdata,
	input logic cache_dmem_resp,

	output logic [31:0] cpu_dmem_rdata,
	output logic cpu_dmem_resp,

	output logic [31:0] cache_dmem_addr,
	output logic cache_dmem_read,
	output logic cache_dmem_write
);

logic pht_prediction_op;
logic pht_misprediction_op;
logic btb_hit_op;
logic btb_miss_op;
logic cache_hit_op;
logic cache_miss_op;
logic cache_writeback_op;
logic performance_counter_op;

logic [31:0] pht_prediction_out;
logic [31:0] pht_misprediction_out;
logic [31:0] btb_hit_out;
logic [31:0] btb_miss_out;
logic [31:0] cache_hit_out;
logic [31:0] cache_miss_out;
logic [31:0] cache_writeback_out;

assign pht_prediction_op = cpu_dmem_addr == 32'hFFE4;
assign pht_misprediction_op = cpu_dmem_addr == 32'hFFE8;
assign btb_hit_op = cpu_dmem_addr == 32'hFFEC;
assign btb_miss_op = cpu_dmem_addr == 32'hFFF0;
assign cache_hit_op = cpu_dmem_addr == 32'hFFF4;
assign cache_miss_op = cpu_dmem_addr == 32'hFFF8;
assign cache_writeback_op = cpu_dmem_addr == 32'hFFFC;

assign performance_counter_op = 
	(pht_prediction_op || pht_misprediction_op || btb_hit_op || btb_miss_op || cache_hit_op || cache_miss_op || cache_writeback_op) && (cpu_dmem_read || cpu_dmem_write);

always_comb
begin
	if (performance_counter_op)
	begin
		cpu_dmem_resp = 1'b1;
		cache_dmem_addr = 32'b0;
		cache_dmem_read = 1'b0;
		cache_dmem_write = 1'b0;
		if (pht_prediction_op) cpu_dmem_rdata = pht_prediction_out;
		else if (pht_misprediction_op) cpu_dmem_rdata = pht_misprediction_out;
		else if (btb_hit_op) cpu_dmem_rdata = btb_hit_out;
		else if (btb_miss_op) cpu_dmem_rdata = btb_miss_out;
		else if (cache_hit_op) cpu_dmem_rdata = cache_hit_out;
		else if (cache_miss_op) cpu_dmem_rdata = cache_miss_out;
		else cpu_dmem_rdata = cache_writeback_out;
	end
	else
	begin
		cpu_dmem_rdata = cache_dmem_rdata;
		cpu_dmem_resp = cache_dmem_resp;
		cache_dmem_addr = cpu_dmem_addr;
		cache_dmem_read = cpu_dmem_read;
		cache_dmem_write = cpu_dmem_write;
	end
end

counter pht_prediction_counter
(
	.clk(clk),
	.increment(pht_prediction),
	.reset(cpu_dmem_write && pht_prediction_op),
	.out(pht_prediction_out)
);

counter pht_misprediction_counter
(
	.clk(clk),
	.increment(pht_misprediction),
	.reset(cpu_dmem_write && pht_misprediction_op),
	.out(pht_misprediction_out)
);

counter btb_hit_counter 
(
	.clk(clk),
	.increment(btb_hit),
	.reset(cpu_dmem_write && btb_hit_op),
	.out(btb_hit_out)
);

counter btb_miss_counter 
(
	.clk(clk),
	.increment(btb_miss),
	.reset(cpu_dmem_write && btb_miss_op),
	.out(btb_miss_out)
);

counter cache_hit_counter
(
	.clk(clk),
	.increment(cache_hit),
	.reset(cpu_dmem_write && cache_hit_op),
	.out(cache_hit_out)
);

counter cache_miss_counter
(
	.clk(clk),
	.increment(cache_miss),
	.reset(cpu_dmem_write && cache_miss_op),
	.out(cache_miss_out)
);

counter cache_writeback_counter
(
	.clk(clk),
	.increment(cache_writeback),
	.reset(cpu_dmem_write && cache_writeback_op),
	.out(cache_writeback_out)
);

endmodule : performance_counters
