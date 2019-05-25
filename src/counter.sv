module counter
(
	input clk,
	input logic increment,
	input reset,

	output [31:0] out
);

logic [31:0] data;
logic [31:0] data_in;

assign out = data;

initial
begin
	data = 32'b0;
end

always_comb
begin
	if (reset) 
	begin
		data_in = 32'b0;
	end
	else if (increment) 
	begin
		data_in = data + 1;
	end
	else
	begin
		data_in = data;
	end
end

always_ff @(posedge clk)
begin
	data <= data_in;
end


endmodule : counter
