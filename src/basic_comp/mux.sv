
/* 
 * 2:1 mux
 */
module mux2 #(parameter width = 32)
(
	input sel,
	input [width-1:0] a, b,
	output logic [width-1:0] c
);

always_comb
begin
	case(sel)
		1'd0: c = a;
		1'd1: c = b; 
	endcase
end

endmodule : mux2

/*
 * 4:1 mux
 */
module mux4 #(parameter width = 32)
(
	input [1:0] sel,
	input [width-1:0] a, b, c, d,
	output logic [width-1:0] e
);

always_comb
begin
	case(sel)
		2'd0: e = a;
		2'd1: e = b;
		2'd2: e = c;
		2'd3: e = d;
	endcase
end

endmodule : mux4

/*
 * 8:1 mux
 */
module mux8 #(parameter width = 32)
(
	input [2:0] sel,
	input [width-1:0] a, b, c, d, e, f, g, h,
	output logic [width-1:0] i
);

always_comb
begin
	case(sel)
		3'd0: i = a;
		3'd1: i = b;
		3'd2: i = c;
		3'd3: i = d;
		3'd4: i = e;
		3'd5: i = f;
		3'd6: i = g;
		3'd7: i = h;
	endcase
end

endmodule : mux8

