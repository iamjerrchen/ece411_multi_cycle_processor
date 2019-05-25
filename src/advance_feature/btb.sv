import rv32i_types::*;

module btb
(
	input clk,

	input load,
	// Write values
	input rv32i_word EX_pc_branch_target,
	input rv32i_word EX_pc,

	// Read value
	input rv32i_word IF_pc,

	output logic btb_hit,
	output rv32i_word predicted_pc
);

logic [3:0] rindex;
logic [3:0] windex;

assign rindex = IF_pc[5:2];
assign windex = EX_pc[5:2];

logic data_load [4];
logic [31:0] data_out [4];
logic [1:0] data_out_mux_sel;

logic data_tag_valid_load [4];
logic [25:0] tag_bits [4];
logic valid_bits [4];
logic cmp_out [4];

logic [1:0] evicted_way;

logic hits [4];

assign btb_hit = hits[0] || hits[1] || hits[2] || hits[3];

// Eviction logic
btb_eviction eviction
(
	.clk(clk),
	.load(load),
	.index(windex),
	.evicted_way(evicted_way)
);
	
// Tag
assign data_tag_valid_load[0] = evicted_way == 4'd0 && load;
assign data_tag_valid_load[1] = evicted_way == 4'd1 && load;
assign data_tag_valid_load[2] = evicted_way == 4'd2 && load;
assign data_tag_valid_load[3] = evicted_way == 4'd3 && load;

btb_array #(.width(26)) tag [4]
(
	.clk(clk),
	.load(data_tag_valid_load),
	.rindex(rindex),
	.windex(windex),
	.datain(EX_pc[31:6]),
	.dataout(tag_bits)
);

tag_cmp #(.s_tag(26)) compare [4]
(
	.addr_tag(IF_pc[31:6]),
	.tag_out(tag_bits),
	.out(cmp_out)
);

// Valid
btb_array #(.width(1)) valid [4]
(
	.clk(clk),
	.load(data_tag_valid_load),
	.rindex(rindex),
	.windex(windex),
	.datain(1'b1),
	.dataout(valid_bits)
);

assign hits[0] = valid_bits[0] && cmp_out[0];
assign hits[1] = valid_bits[1] && cmp_out[1];
assign hits[2] = valid_bits[2] && cmp_out[2];
assign hits[3] = valid_bits[3] && cmp_out[3];

// Data
btb_data_array line [4]
(
    .clk(clk),
    .load(data_tag_valid_load),
	.rindex(rindex),
    .windex(windex),
    .datain(EX_pc_branch_target),
    // output
	.dataout(data_out)
);

always_comb
begin
	if (hits[0]) 
	begin
		data_out_mux_sel = 2'd0;
	end
	else if (hits[1]) 
	begin
		data_out_mux_sel = 2'd1;
	end
	else if (hits[2]) 
	begin
		data_out_mux_sel = 2'd2;
	end
	else
	begin
		data_out_mux_sel = 2'd3;
	end
end

mux4 data_out_mux
(
	.sel(data_out_mux_sel),
	.a(data_out[0]),
	.b(data_out[1]),
	.c(data_out[2]),
	.d(data_out[3]),
	// Output
	.e(predicted_pc)
);

endmodule : btb
