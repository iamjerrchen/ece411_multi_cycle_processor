module btb_eviction
(
	input clk,
	input load,
	input [3:0] index,
	output logic [1:0] evicted_way
);

logic [1:0] data [16];
logic [1:0] incremented_data;

assign incremented_data = data[index] + 1;
assign evicted_way = data[index];

initial
begin
	for (int i = 0; i < 16; i++)
	begin
		data[i] = 2'b0;
	end
end


always_ff @(posedge clk)
begin
	if (load)
	begin
		data[index] <= incremented_data;
	end
end

endmodule : btb_eviction
