import rv32i_types::*;

module control_rom
(
	input rv32i_opcode opcode,
	input logic [2:0] funct3,
	input logic [6:0] funct7,

	output rv32i_control_word control_word
);

always_comb begin
	control_word.opcode = opcode;
	control_word.imm_mux_sel = null_imm;
	control_word.op1_mux_sel = 2'd0; // FIXME:? Potential bug, default isn't 0 but some arbtrary value
	control_word.op2_mux_sel = 0;
	control_word.alu_op = alu_ops'(3'd0);
	control_word.cmp_op = branch_funct3_t'(3'd0);
	control_word.store_formatter_op = store_funct3_t'(3'd0);
	control_word.logic_mux_sel = 0;
	control_word.pc_branch_target_op = null_op;
	control_word.is_branch_instr = 0;
	control_word.is_jump_instr = 0;
	control_word.mem_write = 0;
	control_word.mem_read = 0;
	control_word.MEM_ready_mux_sel = 0;
	control_word.load_regfile = 0;
	control_word.regfile_mux_sel = 0;
	control_word.load_formatter_op = load_funct3_t'(3'd0);

	case(opcode)
		op_lui: 
		begin
			// ID controls
			control_word.imm_mux_sel = u_imm;

			// EX controls
			control_word.op1_mux_sel = 2'd2;
			control_word.op2_mux_sel = 1;
			control_word.alu_op = alu_add;
			control_word.logic_mux_sel = 0;

			// WB controls
			control_word.load_regfile = 1;
			control_word.regfile_mux_sel = 2'd0;
		end

		op_auipc: 
		begin
			// ID controls
			control_word.imm_mux_sel = u_imm;

			// EX controls
			control_word.op1_mux_sel = 2'd1;
			control_word.op2_mux_sel = 1;
			control_word.alu_op = alu_add;
			control_word.logic_mux_sel = 0;

			// WB controls
			control_word.load_regfile = 1;
			control_word.regfile_mux_sel = 2'd0;
		end

		op_jal: 
		begin
			// ID controls
			control_word.imm_mux_sel = j_imm;

			// EX controls
			control_word.pc_branch_target_op = jal_op;
			control_word.is_jump_instr = 1;

			// WB controls
			control_word.load_regfile = 1;
			control_word.regfile_mux_sel = 2'd1;
		end

		op_jalr: 
		begin
			// ID controls
			control_word.imm_mux_sel = i_imm;

			// EX controls
			control_word.pc_branch_target_op = jalr_op;
			control_word.is_jump_instr = 1;

			// WB controls
			control_word.load_regfile = 1;
			control_word.regfile_mux_sel = 2'd1;
		end

		op_br: 
		begin
			// ID controls
			control_word.imm_mux_sel = b_imm;

			// EX controls
			control_word.op1_mux_sel = 2'd0;
			control_word.op2_mux_sel = 1'd0;
			control_word.cmp_op = branch_funct3_t'(funct3);
			control_word.is_branch_instr = 1;
			control_word.pc_branch_target_op = br_op;
		end

		op_load: 
		begin
			// ID controls
			control_word.imm_mux_sel = i_imm;

			// EX controls
			control_word.op1_mux_sel = 2'd0;
			control_word.op2_mux_sel = 1'd1;
			control_word.alu_op = alu_add;
			control_word.logic_mux_sel = 0;

			// MEM controls
			control_word.MEM_ready_mux_sel = 1;
			control_word.mem_read = 1;

			// WB controls
			control_word.load_regfile = 1;
			control_word.regfile_mux_sel = 2'd2;
			control_word.load_formatter_op = load_funct3_t'(funct3);
		end

		op_store: 
		begin
			// ID controls
			control_word.imm_mux_sel = s_imm;

			// EX controls
			control_word.op1_mux_sel = 2'd0;
			control_word.op2_mux_sel = 1'd1;
			control_word.logic_mux_sel = 0;
			control_word.store_formatter_op = store_funct3_t'(funct3);

			// MEM controls
			control_word.MEM_ready_mux_sel = 1;
			control_word.mem_write = 1;
		end

		op_imm: 
		begin
			// ID controls
			control_word.imm_mux_sel = i_imm;

			// EX controls
			control_word.op1_mux_sel = 2'd0;
			control_word.op2_mux_sel = 1'd1;
			case(arith_funct3_t'(funct3))
				sr:
				begin
					control_word.logic_mux_sel = 0;
					if (funct7[5] == 1) control_word.alu_op = alu_sra;
					else control_word.alu_op = alu_srl;
				end

				slt:
				begin
					control_word.logic_mux_sel = 1;
					control_word.cmp_op = blt;
				end

				sltu:
				begin
					control_word.logic_mux_sel = 1;
					control_word.cmp_op = bltu;
				end

				default:
				begin
					control_word.alu_op = alu_ops'(funct3);
					control_word.logic_mux_sel = 0;
				end
			endcase

			// WB controls
			control_word.load_regfile = 1;
			control_word.regfile_mux_sel = 2'd0;
		end

		op_reg: 
		begin
			// EX controls
			control_word.op1_mux_sel = 2'd0;
			control_word.op2_mux_sel = 1'd0;

			case(arith_funct3_t'(funct3))
				sr:
				begin
					control_word.logic_mux_sel = 0;
					if (funct7[5] == 1) control_word.alu_op = alu_sra;
					else control_word.alu_op = alu_srl;
				end

				slt:
				begin
					control_word.logic_mux_sel = 1;
					control_word.cmp_op = blt;
				end

				sltu:
				begin
					control_word.logic_mux_sel = 1;
					control_word.cmp_op = bltu;
				end

				add:
				begin
					control_word.logic_mux_sel = 0;
					if (funct7[5] == 1) control_word.alu_op = alu_sub;
					else control_word.alu_op = alu_add;
				end

				default:
				begin
					control_word.alu_op = alu_ops'(funct3);
					control_word.logic_mux_sel = 0;
				end
			endcase

			// WB controls
			control_word.load_regfile = 1;
			control_word.regfile_mux_sel = 2'd0;
		end

		default: $display("Unknown opcode: %b", opcode);
	endcase
end

endmodule : control_rom
