module btb_data_array #(
    parameter s_offset = 2,
    parameter s_index = 4,
	 parameter s_mask   = 2**s_offset,
	 parameter s_line   = 8*s_mask,
	 parameter num_sets = 2**s_index
)
(
    input clk,
	input load,
    input [s_index-1:0] rindex,
    input [s_index-1:0] windex,
    input [s_line-1:0] datain,
    output logic [s_line-1:0] dataout
);

logic [s_line-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;

/* Initialize array */
initial
begin
    for (int i = 0; i < num_sets; i++)
    begin
        data[i] = 1'b0;
    end
end

always_comb
begin
	if (load && rindex == windex)
		dataout = datain;
	else
		dataout = data[rindex];
end

always_ff @(posedge clk)
begin
	if (load)
	begin
		data[windex] <= datain;
	end
end

endmodule : btb_data_array

