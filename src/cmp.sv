import rv32i_types::*;

module cmp 
(
	input branch_funct3_t cmpop,
	input rv32i_word a, b,
	output logic cmp_out
);

always_comb
begin
	case(cmpop)
		beq: begin
			if (a == b)
				cmp_out = 1;
			else
				cmp_out = 0;
		end

		bne: begin
			if (a != b)
				cmp_out = 1;
			else
				cmp_out = 0;
		end

		blt: begin
			if ($signed(a) < $signed(b))
				cmp_out = 1;
			else
				cmp_out = 0;
		end

		bge: begin
			if ($signed(a) >= $signed(b))
				cmp_out = 1;
			else 
				cmp_out = 0;
		end

		bltu: begin
			if (a < b)
				cmp_out = 1;
			else
				cmp_out = 0;
		end

		bgeu: begin
			if (a >= b)
				cmp_out = 1;
			else 
				cmp_out = 0;
		end

		/* Arbitrary, should never happen */
		default: cmp_out = 0;
	endcase
end

endmodule : cmp
