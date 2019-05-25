module two_bit_counter
(
	input clk,

	input load,
	input logic up_or_down,

	output logic [1:0] out
);

logic [1:0] data;
logic [1:0] next_data;
logic is_max;
logic is_min;

initial
begin
	data = 2'b01;
end

always_ff @(posedge clk)
begin
	if (load) 
	begin
		data <= next_data;
	end
end

always_comb
begin
	next_data = data;
	out = data;
	is_max = (next_data == 2'b11);
	is_min = (next_data == 2'b00);

	if (up_or_down == 1 && !is_max)
	begin
		next_data = next_data + 1;
	end
	else if (up_or_down == 0 && !is_min)
	begin
		next_data = next_data - 1;
	end
end

endmodule : two_bit_counter
