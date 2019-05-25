module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;

logic mem_resp;
logic [255:0] mem_rdata;
logic [31:0] mem_addr;
logic [255:0] mem_wdata;
logic mem_read;
logic mem_write;

logic [31:0] registers [32];

initial
begin
    clk = 0;
end

/* Clock generator */
always #5 clk = ~clk;

assign registers = dut.cpu.ID.regfile.data;

mp3 dut(
    .*
);

physical_memory memory
(
	.clk(clk),
	.read(mem_read),
	.write(mem_write),
	.address(mem_addr),
	.wdata(mem_wdata),
	.resp(mem_resp),
	.rdata(mem_rdata)
);

endmodule : mp3_tb

