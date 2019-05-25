import rv32i_types::*;

module store_formatter
(
	input rv32i_word in, 
	input logic [1:0] mem_offset,
	input store_funct3_t funct3,
	
	output rv32i_word out,
	output logic [3:0] wmask
);

logic [7:0] LSB_byte; 
logic [15:0] LSB_half;
rv32i_word sb_d;
rv32i_word sh_d;
logic [3:0] byte_wmask;
logic [3:0] half_wmask;

assign LSB_byte = in[7:0];
assign LSB_half = in[15:0];

always_comb
begin
	sb_d = 32'd0;
	if(mem_offset == 2'b00) 
	begin
		sb_d[7:0] = LSB_byte;
		byte_wmask = 4'b0001;
	end
	else if(mem_offset == 2'b01) 
	begin
		sb_d[15:8] = LSB_byte;
		byte_wmask = 4'b0010;
	end
	else if(mem_offset == 2'b10) 
	begin
		sb_d[23:16] = LSB_byte;
		byte_wmask = 4'b0100;
	end
	else 
	begin
		sb_d[31:24] = LSB_byte;
		byte_wmask = 4'b1000;
	end
end

always_comb
begin
	sh_d = 32'd0;
	if(mem_offset == 2'b10)
	begin
		sh_d[31:16] = LSB_half;
		half_wmask = 4'b1100;
	end
	else 
	begin 
		sh_d[15:0] = LSB_half;
		half_wmask = 4'b0011;
	end
end

always_comb
begin
	case(funct3)
		sb: 
		begin
			out = sb_d;
			wmask = byte_wmask;
		end
		sh: 
		begin
			out = sh_d;
			wmask = half_wmask;
		end
		sw:
		begin
			out = in;
			wmask = 4'b1111;
		end
		default: 
		begin
			out = 32'd0;
			wmask = 4'd0;
		end
	endcase
end

endmodule : store_formatter 
