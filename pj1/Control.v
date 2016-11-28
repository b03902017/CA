module Control(
	Op_i,
	RegDst_o,
	ALUOp_o,
	ALUSrc_o,
	RegWrite_o
);

input [5:0] Op_i;
output reg RegDst_o;
output reg [2:0] ALUOp_o;
output reg ALUSrc_o;
output reg RegWrite_o;

always@(*) begin
	if(Op_i == 6'b000000) begin
		RegDst_o <= 1'b1;
		ALUOp_o <= 3'b111; // R_type
		ALUSrc_o <= 1'b0;
		RegWrite_o <= 1'b1;
	end
	else begin
		RegDst_o <= 1'b0;
		ALUOp_o <= 3'b000; // Add
		ALUSrc_o <= 1'b1;
		RegWrite_o <= 1'b1;
	end
end

endmodule