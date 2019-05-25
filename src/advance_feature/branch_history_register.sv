module branch_history_register
(
	input clk,

	input EX_branch_flag,
	input load,

	output logic [3:0] bhr_out
);

// data[3] holds oldest data
// data[0] holds newest data
logic [3:0] data;

initial
begin
	data = 4'b0;
end

always_ff @(posedge clk)
begin
	if (load)
	begin
		data = data << 1;
		data[0] = EX_branch_flag;
	end
end

always_comb
begin
	bhr_out = data;
end

endmodule : branch_history_register
