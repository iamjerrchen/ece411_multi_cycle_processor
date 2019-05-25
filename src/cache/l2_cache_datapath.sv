import rv32i_types::*;

module l2_cache_datapath #(
    parameter s_offset = 5,
    parameter s_index  = 3, parameter s_tag    = 32 - s_offset - s_index,
    parameter s_mask   = 2**s_offset,
    parameter s_line   = 8*s_mask,
    parameter num_sets = 2**s_index,
	parameter ways     = 4
)
(
	input clk,	
	input rv32i_word address,
	
	// From Cache Control
	input data_read,	
	input data_write,
	input force_data_write,
	input force_data_read,
	input lru_load,
	input tag_load,
	input tag_read,
	input valid_load,
	input valid_read,
	input dirty_in,
	input dirty_read,
	input dirty_load,
	input dirty_load_sel,
	
	// From Physical Memory
	input logic [s_line-1:0] pmem_rdata,
	
	// From Arbiter
	input logic [31:0] mem_byte_enable256,
	input logic [s_line-1:0] mem_wdata256,
	
	// To Cache Control
	output logic hit_control,
	output logic [s_tag-1:0] tag_array_out,
	output logic dirty_bit,
	
	// To Physical Memory
	output logic [s_line-1:0] pmem_wdata,
	
	// To Arbiter
	output logic [s_line-1:0] mem_rdata256
);

//  Address
logic [s_index-1:0] set_field;
logic [s_tag-1:0] tag_field;

assign set_field = address[7:5];
assign tag_field = address[31:8];

// Data Array
logic [s_line-1:0] dataout0, dataout1, dataout2, dataout3, dataout_mux_out, datain_mux_out;
logic [31:0] write_en_mux_out0, write_en_mux_out1, write_en_mux_out2, write_en_mux_out3;
logic write_en_mux_sel0, write_en_mux_sel1, write_en_mux_sel2, write_en_mux_sel3;
logic [1:0] dataout_mux_sel;

// LRU
logic [1:0] lru_out;
logic lru0, lru1, lru2, lru3;
assign lru0 = (lru_out == 2'd0);
assign lru1 = (lru_out == 2'd1);
assign lru2 = (lru_out == 2'd2);
assign lru3 = (lru_out == 2'd3);

// Tag Array
logic intl_tag_load0, intl_tag_load1, intl_tag_load2, intl_tag_load3;
logic [s_tag-1:0] tag_out [ways];

// CMP
logic cmp_out [ways];
logic hit0, hit1, hit2, hit3;

// Valid Array
logic intl_valid_load0, intl_valid_load1, intl_valid_load2, intl_valid_load3;
logic valid_out [ways];

// Dirty
logic intl_dirty_load0, intl_dirty_load1, intl_dirty_load2, intl_dirty_load3;
logic dirty_load_mux_out0, dirty_load_mux_out1, dirty_load_mux_out2, dirty_load_mux_out3;
logic dirty_out [ways];

/*
 * Data Array
 */
data_array line [ways]
(
    .clk(clk),
	.read(data_read || force_data_read),
    .write_en(
		{write_en_mux_out0, 
			write_en_mux_out1, 
			write_en_mux_out2, 
			write_en_mux_out3}),
    .index(set_field),
    .datain(datain_mux_out),
    // output
	 .dataout(
		 {dataout0, 
			dataout1,
		 	dataout2,
		 	dataout3})
);

mux2 #(.width(s_line)) datain_mux
(
	.sel(force_data_write),
	.a(mem_wdata256),
	.b(pmem_rdata),
	// output
	.c(datain_mux_out)
);

assign write_en_mux_sel0 = (data_write && hit0) || (lru0 && force_data_write);
assign write_en_mux_sel1 = (data_write && hit1) || (lru1 && force_data_write);
assign write_en_mux_sel2 = (data_write && hit2) || (lru2 && force_data_write);
assign write_en_mux_sel3 = (data_write && hit3) || (lru3 && force_data_write);

mux2 #(.width(s_mask)) write_en_mux [ways]
(
	.sel(
		{write_en_mux_sel0, 
			write_en_mux_sel1,
			write_en_mux_sel2,
			write_en_mux_sel3}),
	.a(32'd0),
	.b(32'hffffffff),
	// output
	.c(
		{write_en_mux_out0, 
			write_en_mux_out1,
			write_en_mux_out2,
			write_en_mux_out3})
);

always_comb
begin
	if (hit0 || (force_data_read && lru0))
	begin
		dataout_mux_sel = 2'd0;
	end
	else if (hit1 || (force_data_read && lru1))
	begin
		dataout_mux_sel = 2'd1;
	end
	else if (hit2 || (force_data_read && lru2))
	begin
		dataout_mux_sel = 2'd2;
	end
	else
	begin
		dataout_mux_sel = 2'd3;
	end
end

mux4 #(.width(s_line)) dataout_mux
(
	.sel(dataout_mux_sel),
	.a(dataout0),
	.b(dataout1),
	.c(dataout2),
	.d(dataout3),
	// output
	.e(dataout_mux_out)
);

//assign mem_rdata256 = hit_control ? dataout_mux_out : 256'd0;
//assign pmem_wdata = force_data_read ? dataout_mux_out : 256'd0;
assign mem_rdata256 = dataout_mux_out;
assign pmem_wdata = dataout_mux_out;

/*
 * 	LRU
 */

lru4 lru
(
	.clk(clk),
	.hit0(hit0),
	.hit1(hit1),
	.hit2(hit2),
	.hit3(hit3),
	.lru_load(lru_load),
	.index(set_field),
	.lru_select(lru_out)
);

/*
 * Tag Array
 */
assign intl_tag_load0 = tag_load && lru0;
assign intl_tag_load1 = tag_load && lru1;
assign intl_tag_load2 = tag_load && lru2;
assign intl_tag_load3 = tag_load && lru3;

array #(.width(s_tag)) tag [ways]
(
	.clk(clk),
	.read(tag_read),
   	.load(
	   {intl_tag_load0,
		   intl_tag_load1,
		   intl_tag_load2,
		   intl_tag_load3}),
   	.index(set_field),
   	.datain(tag_field),
	// output
	.dataout(tag_out)
);

mux4 #(.width(s_tag)) tag_out_mux
(
	.sel(lru_out),
	.a(tag_out[0]),
	.b(tag_out[1]),
	.c(tag_out[2]),
	.d(tag_out[3]),
	// output
	.e(tag_array_out)
);

/*
 * Tag Compare
 */
assign hit0 = cmp_out[0] && valid_out[0];
assign hit1 = cmp_out[1] && valid_out[1];
assign hit2 = cmp_out[2] && valid_out[2];
assign hit3 = cmp_out[3] && valid_out[3];
assign hit_control = hit0 || hit1 || hit2 || hit3;

tag_cmp cmp [ways]
(
	.addr_tag(tag_field),
	.tag_out(tag_out),
	// output
	.out(cmp_out)
);

/*
 * Valid Array
 */
assign intl_valid_load0 = valid_load && lru0;
assign intl_valid_load1 = valid_load && lru1;
assign intl_valid_load2 = valid_load && lru2;
assign intl_valid_load3 = valid_load && lru3;

array #(.width(1)) valid [ways]
(
	.clk(clk),
	.read(valid_read),
	.load(
		{intl_valid_load0,
			intl_valid_load1,
			intl_valid_load2,
			intl_valid_load3}),
	.index(set_field),
	.datain(1'd1),
	// output
	.dataout(valid_out)
);

/*
 * Dirty Array
 */
assign intl_dirty_load0 = dirty_load_mux_out0 && dirty_load;
assign intl_dirty_load1 = dirty_load_mux_out1 && dirty_load;
assign intl_dirty_load2 = dirty_load_mux_out2 && dirty_load;
assign intl_dirty_load3 = dirty_load_mux_out3 && dirty_load;

array #(.width(1)) dirty [ways]
(
	.clk(clk),
	.read(dirty_read),
	.load(
		{intl_dirty_load0,
			intl_dirty_load1,
			intl_dirty_load2,
			intl_dirty_load3}),
	.index(set_field),
	.datain(dirty_in),
	// output
	.dataout(dirty_out)
);

mux2 #(.width(1)) dirty_load_mux_out [ways]
(
	.sel(dirty_load_sel),
	.a({hit0, hit1, hit2, hit3}),
	.b({lru0, lru1, lru2, lru3}),
	// output
	.c(
		{dirty_load_mux_out0,
			dirty_load_mux_out1,
			dirty_load_mux_out2,
			dirty_load_mux_out3})
);

mux4 #(.width(1)) dirty_mux_out
(
	.sel(lru_out),
	.a(dirty_out[0]),
	.b(dirty_out[1]),
	.c(dirty_out[2]),
	.d(dirty_out[3]),
	// output
	.e(dirty_bit)
);

endmodule : l2_cache_datapath
