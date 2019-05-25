module arbiter_control
(
	input clk,

	input logic imem_read,
	input logic dmem_read,
	input logic dmem_write,

	input logic mem_resp,

	output logic [1:0] read_mux_sel,
	output logic write_mux_sel,
	output logic [1:0] addr_mux_sel,
	output logic wdata_mux_sel,
	output logic dmem_resp_mux_sel,
	output logic imem_resp_mux_sel,
	output logic dmem_rdata_mux_sel,
	output logic imem_rdata_mux_sel
);

logic imem_op;
logic dmem_op;
assign imem_op = imem_read;
assign dmem_op = dmem_read || dmem_write;

enum bit [2:0] {
	s_idle,
	s_serve_imem,
	s_serve_imem_queue_dmem,
	s_serve_dmem,
	s_serve_dmem_queue_imem
} state, next_state;

always_comb
begin: state_actions
	read_mux_sel = 2'd0;
	write_mux_sel = 1'd0;
	addr_mux_sel = 2'd0;
	wdata_mux_sel = 1'd0;
	dmem_resp_mux_sel = 1'd0;
	imem_resp_mux_sel = 1'd0;
	dmem_rdata_mux_sel = 1'd0;
	imem_rdata_mux_sel = 1'd0;
	case(state)
		s_idle:;

		s_serve_imem, s_serve_imem_queue_dmem:
		begin
			read_mux_sel = 2'd2;
			addr_mux_sel = 2'd2;
			imem_resp_mux_sel = 1'd1;
			imem_rdata_mux_sel = 1'd1;
		end

		s_serve_dmem, s_serve_dmem_queue_imem:
		begin
			read_mux_sel = 2'd1;
			write_mux_sel = 1'd1;
			addr_mux_sel = 2'd1;
			wdata_mux_sel = 1'd1;
			dmem_resp_mux_sel = 1'd1;
			dmem_rdata_mux_sel = 1'd1;
		end

		default:;
	endcase
end

always_comb
begin: next_state_logic
	next_state = state;
	case(state)
		s_idle:
		begin
			// Prioritize imem over dmem
			if (imem_op) next_state = s_serve_imem;
			else if (dmem_op) next_state = s_serve_dmem;
		end

		s_serve_imem:
		begin
			// Prioritize mem_resp over dmem_op
			if (mem_resp) next_state = s_idle;
			else if (dmem_op) next_state = s_serve_imem_queue_dmem;
		end

		s_serve_imem_queue_dmem:
		begin
			if (mem_resp) next_state = s_serve_dmem;
		end

		s_serve_dmem:
		begin
			// Prioritize mem_resp over imem_op
			if (mem_resp) next_state = s_idle;
			else if (imem_op) next_state = s_serve_dmem_queue_imem;
		end

		s_serve_dmem_queue_imem:
		begin
			if (mem_resp) next_state = s_serve_imem;
		end

		default:;
	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
	state <= next_state;
end

endmodule : arbiter_control
