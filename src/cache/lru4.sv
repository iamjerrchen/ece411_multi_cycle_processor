module lru4
(
	input clk,

	input logic hit0,
	input logic hit1,
	input logic hit2,
	input logic hit3,

	input logic lru_load,
	input logic [2:0] index,

	output logic [1:0] lru_select
);

logic hit;
assign hit = hit0 || hit1 || hit2 || hit3;

logic [2:0] l2l1l0_in;
logic [2:0] l2l1l0_out;

array #(.width(3)) lru_array
(
	.clk(clk),
	.read(1'd1),
	.load(lru_load || hit),
	.index(index),
	.datain(l2l1l0_in),
	.dataout(l2l1l0_out)
);

// Update decision
always_comb
begin
	l2l1l0_in = l2l1l0_out;
	if (hit) 
	begin
		if (hit0)
		begin
			l2l1l0_in[1] = 0;
			l2l1l0_in[0] = 0;
		end
		else if (hit1)
		begin
			l2l1l0_in[1] = 1;
			l2l1l0_in[0] = 0;
		end
		else if (hit2)
		begin
			l2l1l0_in[2] = 0;
			l2l1l0_in[0] = 1;
		end
		else if (hit3)
		begin
			l2l1l0_in[2] = 1;
			l2l1l0_in[0] = 1;
		end
	end
end

// Replacement decision
always_comb
begin
	lru_select = 2'd0;
	if (l2l1l0_out[1] == 1 && l2l1l0_out[0] == 1)
		lru_select = 2'd0;
	else if (l2l1l0_out[1] == 0 && l2l1l0_out[0] == 1)
		lru_select = 2'd1;
	else if (l2l1l0_out[2] == 1 && l2l1l0_out[0] == 0)
		lru_select = 2'd2;
	else if (l2l1l0_out[2] == 0 && l2l1l0_out[0] == 0)
		lru_select = 2'd3;
end

endmodule : lru4
