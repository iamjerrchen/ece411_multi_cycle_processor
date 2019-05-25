module l2_cache #(
    parameter s_offset = 5,
    parameter s_index  = 3,
    parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index
)
(
	input clk,
	
	/* Physical Memory to Cache Datapath */
	input logic [s_line-1:0] pmem_rdata,
	
	/* Physical Memory to Cache Control */
	input pmem_resp,
		
	/* Processor to Cache Control */
	input mem_read,
	input mem_write,
	
	/* Processor to Cache Datapath */
	input logic [31:0] address,
	input logic [s_line-1:0] mem_wdata,

	/* Cache Datapath to Physical Memory */
	output logic [s_line-1:0] pmem_wdata,
	
	/* Cache Control to Physical Memory */
	output logic pmem_write,
	output logic pmem_read,
	output logic [31:0] pmem_address,
	
	/* Cache Control to CPU Control */
	output logic mem_resp,
	
	/* Cache Datapath to Processor */
	output logic [s_line-1:0] mem_rdata,

	output performance_cache_hit,
	output performance_cache_miss,
	output performance_cache_writeback
);

/* Datapath to Control */
logic hit_control, dirty_bit;
logic [s_tag-1:0] tag_array_out;
	
/* Control to Datapath */
logic data_read, data_write;
logic force_data_write, force_data_read;
logic lru_load;
logic tag_load, tag_read;
logic valid_load, valid_read;
logic dirty_in, dirty_read, dirty_load, dirty_load_sel;

cache_control control
(
	.clk(clk),
	.address(address),
	
	// From Processor
	.mem_read(mem_read),
	.mem_write(mem_write),
	
	// From Cache Datapath
	.hit_control(hit_control),
	.tag_array_out(tag_array_out),
	.dirty_bit(dirty_bit),
	
	// From Physical Memory
	.pmem_resp(pmem_resp),

	// To Cache Datapath
	.data_read(data_read),	
	.data_write(data_write),
	.force_data_write(force_data_write),
	.force_data_read(force_data_read),
	.lru_load(lru_load),
	.tag_load(tag_load),
	.tag_read(tag_read),
	.valid_load(valid_load),
	.valid_read(valid_read),
	.dirty_in(dirty_in),
	.dirty_read(dirty_read),
	.dirty_load(dirty_load),
	.dirty_load_sel(dirty_load_sel),
	
	// To Physical Memory
	.pmem_write(pmem_write),
	.pmem_read(pmem_read),
	.pmem_address(pmem_address),
	
	// To CPU Control
	.mem_resp(mem_resp),

	// Performance counter
	.performance_cache_hit(performance_cache_hit),
	.performance_cache_miss(performance_cache_miss),
	.performance_cache_writeback(performance_cache_writeback)
);

l2_cache_datapath datapath
(
	.clk(clk),	
	.address(address),
	
	// From Cache Control
	.data_read(data_read),	
	.data_write(data_write),
	.force_data_write(force_data_write),
	.force_data_read(force_data_read),
	.lru_load(lru_load),
	.tag_load(tag_load),
	.tag_read(tag_read),
	.valid_load(valid_load),
	.valid_read(valid_read),
	.dirty_in(dirty_in),
	.dirty_read(dirty_read),
	.dirty_load(dirty_load),
	.dirty_load_sel(dirty_load_sel),
	
	// From Physical Memory
	.pmem_rdata(pmem_rdata),
	
	// From Arbiter
	.mem_wdata256(mem_wdata),
	
	// To Cache Control
	.hit_control(hit_control),
	.tag_array_out(tag_array_out),
	.dirty_bit(dirty_bit),
	
	// To Physical Memory
	.pmem_wdata(pmem_wdata),
	
	// To Arbiter
	.mem_rdata256(mem_rdata)
);

endmodule : l2_cache
