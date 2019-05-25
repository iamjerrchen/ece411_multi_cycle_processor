import rv32i_types::*;

module load_formatter
(
	input rv32i_word in,
	input logic [1:0] mem_offset,
	input load_funct3_t funct3,

	output rv32i_word out 
);

rv32i_word lb_d;
rv32i_word lh_d;
rv32i_word lbu_d;
rv32i_word lhu_d;

logic [7:0] extract_byte;
logic [15:0] extract_half;

always_comb
begin
	// byte
	if(mem_offset == 2'b00) extract_byte = in[7:0];
	else if(mem_offset == 2'b01) extract_byte = in[15:8];
	else if(mem_offset == 2'b10) extract_byte = in[23:16];
	else extract_byte = in[31:24];
end

always_comb
begin
	// half
	if(mem_offset == 2'b10) extract_half = in[31:16]; // upper half
	else extract_half = in[15:0]; // lower half
end

sext #(.in_width(8)) sext_lb
(
	.in(extract_byte[7:0]),
	.out(lb_d)
);

sext #(.in_width(16)) sext_lh
(
	.in(extract_half[15:0]),
	.out(lh_d)
);

zext #(.in_width(8)) zext_lbu
(
	.in(extract_byte[7:0]),
	.out(lbu_d)
);

zext #(.in_width(16)) zext_lhu
(
	.in(extract_half[15:0]),
	.out(lhu_d)
);

always_comb
begin
	case(funct3)
		lb: out = lb_d;
		lh: out = lh_d;
		lw: out = in;
		lbu: out = lbu_d;
		lhu: out = lhu_d;
		default: out = 32'd0;
	endcase
end

endmodule : load_formatter
