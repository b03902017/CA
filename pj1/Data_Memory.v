module Data_Memory
(
    addr_i,
    memread,
    memwrite,
    data_i,
    data_o
);

// Interface
input   [31:0]      addr_i;
input memread, memwrite;
input 	[31:0] 		data_i;
output reg  [31:0]     	data_o;

// Instruction memory
reg     [31:0]     memory  [0:255];

always@(*) begin
	if(memread) begin
		data_o = memory[addr_i];
	end
	if(memwrite) begin
		memory[addr_i] = data_i;
	end
end

endmodule
