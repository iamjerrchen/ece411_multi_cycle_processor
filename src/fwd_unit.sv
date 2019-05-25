import rv32i_types::*;

module fwd_unit
(
	input rv32i_reg EX_rs1,
	input rv32i_reg EX_rs2,

	input rv32i_reg MEM_rd,
	input rv32i_reg WB_rd,

	output logic [1:0] rs1_sel,
	output logic [1:0] rs2_sel
);

always_comb
begin
	if (MEM_rd == EX_rs1 && EX_rs1 != 0)
	begin
		rs1_sel = 2'd2;
	end
	else if (WB_rd == EX_rs1 && EX_rs1 != 0 && MEM_rd != EX_rs1)
	begin
		rs1_sel = 2'd1;
	end
	else
	begin
		rs1_sel = 2'd0;
	end

	if (MEM_rd == EX_rs2 && EX_rs2 != 0)
	begin
		rs2_sel = 2'd2;
	end
	else if (WB_rd == EX_rs2 && EX_rs2 != 0 && MEM_rd != EX_rs2)
	begin
		rs2_sel = 2'd1;
	end
	else
	begin
		rs2_sel = 2'd0;
	end
end

endmodule : fwd_unit
