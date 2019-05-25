import rv32i_types::*;

module cpu
(
	input clk,

	// Instruction Memory
	input logic imem_resp,
	input rv32i_word imem_rdata,

	output logic imem_read,
	output rv32i_word imem_addr,
	
	// Data Memory
	input logic dmem_resp,
	input rv32i_word dmem_rdata,

	output logic dmem_read,
	output logic dmem_write,
	output rv32i_word dmem_addr,
	output rv32i_word dmem_wdata,
	output logic [3:0] dmem_wmask,

	// Performance counters
	output performance_pht_prediction,
	output performance_pht_misprediction,
	output performance_btb_hit,
	output performance_btb_miss
);

logic global_load;
logic overwrite_load;
logic both_mem_resp;

logic branch_flag;
logic branch_recovery;
logic is_branch;
logic [3:0] pht_idx;
rv32i_word pc_branch_target;

logic IF_ready_out;
logic MEM_ready_out;

rv32i_word IF_ID_pc_plus4;
rv32i_word IF_ID_instruction;
logic [3:0] IF_ID_pht_idx;
logic IF_ID_is_branch;
rv32i_word IF_ID_pc_taken;
logic IF_ID_pht_prediction;

rv32i_word ID_pc_plus4;
rv32i_word ID_instruction;
logic ID_is_branch;

rv32i_word ID_EX_pc_plus4;
rv32i_control_word ID_EX_control_word;
rv32i_word ID_EX_imm;
rv32i_word ID_EX_rs1;
rv32i_reg ID_EX_rs2;
rv32i_reg ID_EX_rd;
rv32i_word ID_EX_rs1_data;
rv32i_word ID_EX_rs2_data;
logic [3:0] ID_EX_pht_idx;
logic ID_EX_is_branch;
rv32i_word ID_EX_pc_taken;
logic ID_EX_pht_prediction;

logic [1:0] fwd_unit_rs1_sel;
logic [1:0] fwd_unit_rs2_sel;

rv32i_word EX_pc_plus4;
rv32i_control_word EX_control_word;
rv32i_word EX_imm;
rv32i_word EX_rs1;
rv32i_reg EX_rs2;
rv32i_reg EX_rd;
rv32i_word EX_rs1_data;
rv32i_word EX_rs2_data;
rv32i_word EX_pc_taken;
rv32i_word EX_pc;
logic EX_pht_prediction;

rv32i_word EX_MEM_pc_plus4;
rv32i_control_word EX_MEM_control_word;
rv32i_word EX_MEM_logic_out;
rv32i_reg EX_MEM_rd;
rv32i_word EX_MEM_mem_data_out;
logic [3:0] EX_MEM_wmask;

rv32i_word MEM_pc_plus4;
rv32i_control_word MEM_control_word;
rv32i_word MEM_logic_out;
rv32i_reg MEM_rd;
rv32i_word MEM_mem_data_out;
logic [3:0] MEM_wmask;

rv32i_word MEM_WB_pc_plus4;
rv32i_control_word MEM_WB_control_word;
rv32i_word MEM_WB_logic_out;
rv32i_reg MEM_WB_rd;
rv32i_word MEM_WB_MDR;

rv32i_word WB_pc_plus4;
rv32i_control_word WB_control_word;
rv32i_word WB_logic_out;
rv32i_reg WB_rd;
rv32i_word WB_MDR;

rv32i_word regfile_in;

assign global_load = ((IF_ready_out && dmem_resp) || 
					 (imem_resp && MEM_ready_out) || 
					 (IF_ready_out && MEM_ready_out) ||
				     (imem_resp && dmem_resp))
					 && !overwrite_load;
assign overwrite_load = 
	(MEM_control_word.opcode == op_load) && 
	dmem_resp && 
	(MEM_rd == EX_rs1 || MEM_rd == EX_rs2);

IF_stage IF
(
	.clk,
	.global_load(global_load),
	.imem_data(imem_rdata),
	.imem_resp(imem_resp),
	.dmem_resp(dmem_resp),
	.MEM_ready_out(MEM_ready_out),
	.branch_flag(branch_flag),
	.branch_recovery(branch_recovery),
	.EX_is_branch(is_branch),
	.EX_pht_idx(pht_idx),
	.EX_pc(EX_pc),
	.pc_branch_target(pc_branch_target),
	// Outputs
	.imem_read(imem_read),
	.imem_addr(imem_addr),
	.IF_ID_pc_plus4(IF_ID_pc_plus4),
	.IF_ID_instruction(IF_ID_instruction),
	.IF_ID_pc_taken(IF_ID_pc_taken),
	.IF_ID_pht_idx(IF_ID_pht_idx),
	.IF_ID_is_branch(IF_ID_is_branch),
	.IF_ID_pht_prediction(IF_ID_pht_prediction),
	.performance_btb_hit(performance_btb_hit),
	.performance_btb_miss(performance_btb_miss),
	.IF_ready_out(IF_ready_out)
);

IF_ID_reg IF_ID_reg
(
	.clk,
	.load(global_load),
	.pc_plus4_in(IF_ID_pc_plus4),
	.instr_in(IF_ID_instruction),
	.is_branch_in(IF_ID_is_branch),
	.pht_idx_in(IF_ID_pht_idx),
	.pc_taken_in(IF_ID_pc_taken),
	.pht_prediction_in(IF_ID_pht_prediction),
	// Outputs
	.pc_plus4_out(ID_pc_plus4),
	.instr_out(ID_instruction),
	.is_branch_out(ID_is_branch),
	.pht_idx_out(ID_EX_pht_idx),
	.pc_taken_out(ID_EX_pc_taken),
	.pht_prediction_out(ID_EX_pht_prediction)
);

ID_stage ID
(
	.clk,
	.branch_recovery(branch_recovery),
	.overwrite_load(overwrite_load),
	.rs1_prev(EX_rs1),
	.rs2_prev(EX_rs2),
	.regfile_load(WB_control_word.load_regfile),
	.regfile_in(regfile_in),
	.regfile_dest(WB_rd),
	.pc_plus4(ID_pc_plus4),
	.instr(ID_instruction),
	.is_branch(ID_is_branch),
	// Outputs
	.ID_EX_pc_plus4(ID_EX_pc_plus4),
	.ID_EX_control_word(ID_EX_control_word),
	.ID_EX_imm(ID_EX_imm),
	.ID_EX_rs1(ID_EX_rs1),
	.ID_EX_rs2(ID_EX_rs2),
	.ID_EX_rd(ID_EX_rd),
	.ID_EX_rs1_data(ID_EX_rs1_data),
	.ID_EX_rs2_data(ID_EX_rs2_data),
	.ID_EX_is_branch(ID_EX_is_branch)
);

ID_EX_reg ID_EX_reg
(
	.clk,
	.load(global_load),
	.overwrite_load(overwrite_load),
	.pc_plus4_in(ID_EX_pc_plus4),
	.control_word_in(ID_EX_control_word),
	.imm_in(ID_EX_imm),
	.rs1_in(ID_EX_rs1),
	.rs2_in(ID_EX_rs2),
	.rd_in(ID_EX_rd),
	.rs1_data_in(ID_EX_rs1_data),
	.rs2_data_in(ID_EX_rs2_data),
	.is_branch_in(ID_EX_is_branch),
	.pht_idx_in(ID_EX_pht_idx),
	.pc_taken_in(ID_EX_pc_taken),
	.pht_prediction_in(ID_EX_pht_prediction),
	// Outputs
	.pc_plus4_out(EX_pc_plus4),
	.control_word_out(EX_control_word),
	.imm_out(EX_imm),
	.rs1_out(EX_rs1),
	.rs2_out(EX_rs2),
	.rd_out(EX_rd),
	.rs1_data_out(EX_rs1_data),
	.rs2_data_out(EX_rs2_data),
	.is_branch_out(is_branch),
	.pht_idx_out(pht_idx),
	.pc_taken_out(EX_pc_taken),
	.pht_prediction_out(EX_pht_prediction)
);

fwd_unit fwd_unit
(
	.EX_rs1(EX_rs1),
	.EX_rs2(EX_rs2),
	.MEM_rd(MEM_rd),
	.WB_rd(WB_rd),
	// Outputs
	.rs1_sel(fwd_unit_rs1_sel),
	.rs2_sel(fwd_unit_rs2_sel)
);

EX_stage EX
(
	.pc_plus4(EX_pc_plus4),
	.control_word(EX_control_word),
	.imm(EX_imm),
	.rs1(EX_rs1),
	.rs2(EX_rs2),
	.rd(EX_rd),
	.rs1_data(EX_rs1_data),
	.rs2_data(EX_rs2_data),
	.WB_regfile_in(regfile_in),
	.MEM_logic_out(MEM_logic_out),
	.fwd_unit_rs1_sel(fwd_unit_rs1_sel),
	.fwd_unit_rs2_sel(fwd_unit_rs2_sel),
	.overwrite_load(overwrite_load),
	.is_branch(is_branch),
	.pc_taken(EX_pc_taken),
	.pht_prediction(EX_pht_prediction),
	// Outputs
	.EX_MEM_pc_plus4(EX_MEM_pc_plus4),
	.EX_MEM_control_word(EX_MEM_control_word),
	.EX_MEM_logic_out(EX_MEM_logic_out),
	.EX_MEM_rd(EX_MEM_rd),
	.EX_MEM_mem_data_out(EX_MEM_mem_data_out),
	.EX_MEM_wmask(EX_MEM_wmask),
	.branch_flag(branch_flag),
	.branch_recovery(branch_recovery),
	.pc_branch_target(pc_branch_target),
	.source_pc(EX_pc),
	.performance_pht_prediction(performance_pht_prediction),
	.performance_pht_misprediction(performance_pht_misprediction)
);

EX_MEM_reg EX_MEM_reg
(
	.clk,
	.load(global_load || overwrite_load),
	.pc_plus4_in(EX_MEM_pc_plus4),
	.control_word_in(EX_MEM_control_word),
	.logic_out_in(EX_MEM_logic_out),
	.rd_in(EX_MEM_rd),
	.mem_data_out_in(EX_MEM_mem_data_out),
	.wmask_in(EX_MEM_wmask),
	// Outputs
	.pc_plus4_out(MEM_pc_plus4),
	.control_word_out(MEM_control_word),
	.logic_out_out(MEM_logic_out),
	.rd_out(MEM_rd),
	.mem_data_out_out(MEM_mem_data_out),
	.wmask_out(MEM_wmask)
);

MEM_stage MEM
(
	.clk,
	.load(global_load || overwrite_load),
	.pc_plus4(MEM_pc_plus4),
	.control_word(MEM_control_word),
	.logic_out(MEM_logic_out),
	.rd(MEM_rd),
	.mem_data_out(MEM_mem_data_out),
	.wmask(MEM_wmask),
	.dmem_resp(dmem_resp),
	.imem_resp(imem_resp),
	.IF_ready_out(IF_ready_out),
	.dmem_rdata(dmem_rdata),
	// Outputs
	.MEM_WB_pc_plus4(MEM_WB_pc_plus4),
	.MEM_WB_control_word(MEM_WB_control_word),
	.MEM_WB_logic_out(MEM_WB_logic_out),
	.MEM_WB_rd(MEM_WB_rd),
	.MEM_WB_MDR(MEM_WB_MDR),
	.dmem_wdata(dmem_wdata),
	.dmem_addr(dmem_addr),
	.dmem_write(dmem_write),
	.dmem_read(dmem_read),
	.dmem_wmask(dmem_wmask),
	.MEM_ready_out(MEM_ready_out)
);

MEM_WB_reg MEM_WB_reg
(
	.clk,
	.load(global_load || overwrite_load),
	.pc_plus4_in(MEM_WB_pc_plus4),
	.control_word_in(MEM_WB_control_word),
	.logic_out_in(MEM_WB_logic_out),
	.rd_in(MEM_WB_rd),
	.MDR_in(MEM_WB_MDR),
	// Outputs
	.pc_plus4_out(WB_pc_plus4), 
	.control_word_out(WB_control_word),
	.logic_out_out(WB_logic_out),
	.rd_out(WB_rd),
	.MDR_out(WB_MDR)
);

WB_stage WB
(
	.pc_plus4(WB_pc_plus4),
	.logic_out(WB_logic_out),
	.MDR(WB_MDR),
	.control_word(WB_control_word),
	// Outputs
	.regfile_in(regfile_in)
);

endmodule : cpu
