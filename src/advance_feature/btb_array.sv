
module btb_array #(
	parameter s_index = 4,
	parameter width = 1,
	parameter num_sets = 2**s_index
)
(
    input clk,
    input load,
    input [s_index-1:0] rindex,
    input [s_index-1:0] windex,
    input [width-1:0] datain,
    output logic [width-1:0] dataout
);

logic [width-1:0] data [num_sets-1:0] /* synthesis ramstyle = "logic" */;

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
    if(load)
        data[windex] <= datain;
end

endmodule : btb_array

