module mem_ready_reg
(
	input clk,

	input logic mem_resp,
	input logic global_load,

	output logic ready
);

logic mem_resp_prev_out;
logic global_load_prev_out;
logic ready_in;
logic ready_load;

register #(.width(1)) mem_resp_prev
(
	.clk(clk),
	.load(!(mem_resp === 1'bx)),
	.in(mem_resp),
	.out(mem_resp_prev_out)
);

register #(.width(1)) global_load_prev
(
	.clk(clk),
	.load(1'd1),
	.in(global_load),
	.out(global_load_prev_out)
);

register #(.width(1)) ready_reg
(
	.clk(clk),
	.load(ready_load),
	.in(ready_in),
	.out(ready)
);

always_comb
begin
	if (mem_resp == 1 && mem_resp_prev_out == 0)
	begin
		ready_load = 1;
		ready_in = 1;
	end
	else if (global_load == 1 && global_load_prev_out == 0)
	begin
		ready_load = 1;
		ready_in = 0;
	end
	else
	begin
		ready_load = 0;
		ready_in = 0;
	end
end

endmodule : mem_ready_reg
