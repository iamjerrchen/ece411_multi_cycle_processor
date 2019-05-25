import rv32i_types::*;

module pc_branch_target_calc
(
	input pc_branch_target_ops op,
	input rv32i_word pc,
	input rv32i_word imm,
	input rv32i_word rs1_data,

	output rv32i_word branch_target
);

always_comb
begin
	case(op)
		null_op: branch_target = 32'd0;
		jal_op: branch_target = pc + imm;
		jalr_op: branch_target = (rs1_data + imm) & 32'hFFFFFFFE;
		br_op: branch_target = pc + imm;
	endcase
end

endmodule : pc_branch_target_calc
