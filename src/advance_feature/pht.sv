module pht
(
	input clk,

	input [3:0] pht_idx,

	input EX_branch_flag,
	input [3:0] EX_pht_idx,
	input load,

	output pht_prediction
);

logic [1:0] counter_out [16];
logic counter_load [16];

two_bit_counter counters [16]
(
	.clk,
	.load(counter_load),
	.up_or_down(EX_branch_flag),
	.out(counter_out)
);

assign counter_load[0] = load && (EX_pht_idx == 4'd0);
assign counter_load[1] = load && (EX_pht_idx == 4'd1);
assign counter_load[2] = load && (EX_pht_idx == 4'd2);
assign counter_load[3] = load && (EX_pht_idx == 4'd3);
assign counter_load[4] = load && (EX_pht_idx == 4'd4);
assign counter_load[5] = load && (EX_pht_idx == 4'd5);
assign counter_load[6] = load && (EX_pht_idx == 4'd6);
assign counter_load[7] = load && (EX_pht_idx == 4'd7);
assign counter_load[8] = load && (EX_pht_idx == 4'd8);
assign counter_load[9] = load && (EX_pht_idx == 4'd9);
assign counter_load[10] = load && (EX_pht_idx == 4'd10);
assign counter_load[11] = load && (EX_pht_idx == 4'd11);
assign counter_load[12] = load && (EX_pht_idx == 4'd12);
assign counter_load[13] = load && (EX_pht_idx == 4'd13);
assign counter_load[14] = load && (EX_pht_idx == 4'd14);
assign counter_load[15] = load && (EX_pht_idx == 4'd15);

assign pht_prediction = counter_out[pht_idx] > 2'd1;

endmodule : pht
