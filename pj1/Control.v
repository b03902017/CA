module Control(
	Op_i,
	RegDst_o,
	ALUOp_o,
	ALUSrc_o,
	RegWrite_o,
	Memread_o,
	Memwrite_o,
	Mem2reg_o
);

input [5:0] Op_i;
output reg RegDst_o;
output reg [2:0] ALUOp_o;
output reg ALUSrc_o;
output reg RegWrite_o;
output reg Memread_o;
output reg Memwrite_o;
output reg Mem2reg_o;

always@(*) begin
	if(Op_i == 6'b000000) begin
		RegDst_o <= 1'b1; // write to rd
		ALUOp_o <= 3'b111; // R_type
		ALUSrc_o <= 1'b0;
		RegWrite_o <= 1'b1;
		Memread_o <= 1'b0;
		Memwrite_o <= 1'b0;
		Mem2reg_o <= 1'b0;
	end
	else if(Op_i == 6'b101011) begin //save word
		RegDst_o <= 1'b0; // don't cate
		ALUOp_o <= 3'b000; // Add
		ALUSrc_o <= 1'b1; // use immediate
		RegWrite_o <= 1'b0;
		Memread_o <= 1'b0;
		Memwrite_o <= 1'b1;
		Mem2reg_o <= 1'b0;
	end
	else if(Op_i == 6'b100011) begin // load word
		RegDst_o <= 1'b0; // don't cate
		ALUOp_o <= 3'b000; // Add
		ALUSrc_o <= 1'b1; // use immediate
		RegWrite_o <= 1'b1;
		Memread_o <= 1'b1;
		Memwrite_o <= 1'b0;
		Mem2reg_o <= 1'b1;
	end
	else begin // addi
		RegDst_o <= 1'b0; // write to rt
		ALUOp_o <= 3'b000; // Add
		ALUSrc_o <= 1'b1; // use immediate
		RegWrite_o <= 1'b1;
		Memread_o <= 1'b0;
		Memwrite_o <= 1'b0;
		Mem2reg_o <= 1'b0;
	end
end

endmodule