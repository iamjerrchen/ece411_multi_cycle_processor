import rv32i_types::*;

module instr_decoder
(
    input [31:0] data,
    output [2:0] funct3,
    output [6:0] funct7,
    output rv32i_opcode opcode,
    output [31:0] i_imm,
    output [31:0] s_imm,
    output [31:0] b_imm,
    output [31:0] u_imm,
    output [31:0] j_imm,
    output rv32i_reg rs1,
    output rv32i_reg rs2,
    output rv32i_reg rd
);

assign funct3 = data[14:12];
assign funct7 = data[31:25];
assign opcode = rv32i_opcode'(data[6:0]);
assign i_imm = {{21{data[31]}}, data[30:20]};
assign s_imm = {{21{data[31]}}, data[30:25], data[11:7]};
assign b_imm = {{20{data[31]}}, data[7], data[30:25], data[11:8], 1'b0};
assign u_imm = {data[31:12], 12'h000};
assign j_imm = {{12{data[31]}}, data[19:12], data[20], data[30:21], 1'b0};

// All instructions that don't write to a register, set rd = 5'd0
always_comb
begin
	case(opcode)
		op_lui, op_auipc, op_jal, op_jalr, op_load, op_imm, op_reg: rd = data[11:7];
		default: rd = 5'd0;
	endcase
end

// All instructions that don't use rs1, set rs1 to 5'd0
always_comb
begin
	case(opcode)
		op_jalr, op_br, op_load, op_store, op_imm, op_reg: rs1 = data[19:15];
		default: rs1 = 5'd0;
	endcase
end

// All instructions that don't use rs2, set rs2 to 5'd0
always_comb
begin
	case(opcode)
		op_br, op_store, op_reg: rs2 = data[24:20];
		default: rs2 = 5'd0;
	endcase
end

endmodule : instr_decoder
