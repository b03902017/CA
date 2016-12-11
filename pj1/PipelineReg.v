module IFIDRegister
(
	clk_i,
	pc_i,
	inst_i,
	IFIDwrite,
	IFIDflush,
	pc_o,
	inst_o
);
	input clk_i;
	input [31:0] pc_i;
	input [31:0] inst_i;
	input IFIDwrite; // stall
	input IFIDflush; //flush

	output reg [31:0] pc_o;
	output reg [31:0] inst_o;

	always@(posedge clk_i) begin
		if(IFIDwrite)begin
			if(IFIDflush)begin
				pc_o <= 32'b0;
				inst_o <= 32'b0;
			end
			else begin 
				pc_o <= pc_i;
				inst_o <= inst_i;
			end
		end
	end

endmodule

module IDEXRegister
(
	clk_i,
	regdst_ctrl,
	aluop_ctrl,
	alusrc_ctrl,
	regwrite_ctrl,
	memread_ctrl,
	memwrite_ctrl,
	mem2reg_ctrl,
	rsdata_i,
	rtdata_i,
	immediate_i,
	rsaddr_i,
	rtaddr_i,
	rdaddr_i,
	func_i,
	regdst_o,
	aluop_o,
	alusrc_o,
	regwrite_o,
	memread_o,
	memwrite_o,
	mem2reg_o,
	rsdata_o,
	rtdata_o,
	immediate_o,
	rsaddr_o,
	rtaddr_o,
	rdaddr_o,
	func_o
);

	input clk_i;
	input regdst_ctrl;
	input [2:0] aluop_ctrl;
	input alusrc_ctrl;
	input regwrite_ctrl;
	input memread_ctrl;
	input memwrite_ctrl;
	input mem2reg_ctrl;
	input [31:0] rsdata_i;
	input [31:0] rtdata_i;
	input [31:0] immediate_i;
	input [4:0] rsaddr_i;
	input [4:0] rtaddr_i;
	input [4:0] rdaddr_i;
	input [5:0] func_i;

	output reg regdst_o;
	output reg [2:0] aluop_o;
	output reg alusrc_o;
	output reg regwrite_o;
	output reg memread_o;
	output reg memwrite_o;
	output reg mem2reg_o;
	output reg [31:0] rsdata_o;
	output reg [31:0] rtdata_o;
	output reg [31:0] immediate_o;
	output reg [4:0] rsaddr_o;
	output reg [4:0] rtaddr_o;
	output reg [4:0] rdaddr_o;
	output reg [5:0] func_o;

	always@(posedge clk_i) begin		
		regdst_o <= regdst_ctrl;
		aluop_o <= aluop_ctrl;
		alusrc_o <= alusrc_ctrl;
		regwrite_o <= regwrite_ctrl;
		memread_o <= memread_ctrl;
		memwrite_o <= memwrite_ctrl;
		mem2reg_o <= mem2reg_ctrl;
		rsdata_o <= rsdata_i;
		rtdata_o <= rtdata_i;
		immediate_o <= immediate_i;
		rsaddr_o <= rsaddr_i;
		rtaddr_o <= rtaddr_i;
		rdaddr_o <= rdaddr_i;
		func_o <= func_i;

	end

endmodule

module EXMEMregister
(
	clk_i,
	regwrite_i,
	ALUout_i,
	regdst_i,
	ALUrtdata_i,
	memread_i,
	memwrite_i,
	mem2reg_i,
	regwrite_o,
	ALUout_o,
	regdst_o,
	ALUrtdata_o,
	memread_o,
	memwrite_o,
	mem2reg_o
);
	input clk_i;
	input regwrite_i;
	input [31:0] ALUout_i;
	input [4:0] regdst_i;
	input [31:0] ALUrtdata_i;
	input memread_i, memwrite_i, mem2reg_i;

	output reg regwrite_o;
	output reg [31:0] ALUout_o;
	output reg [4:0] regdst_o;
	output reg [31:0] ALUrtdata_o;
	output reg memread_o, memwrite_o, mem2reg_o;

	always@(posedge clk_i) begin
		regwrite_o <= regwrite_i;
		ALUout_o <= ALUout_i;
		regdst_o <= regdst_i;
		ALUrtdata_o <= 	ALUrtdata_i;
		memread_o <= memread_i;
		memwrite_o <= memwrite_i;
		mem2reg_o <= mem2reg_i;
	end

endmodule

module MEMWBregister
(
	clk_i,
	regwrite_i,
	ALUout_i,
	regdst_i,
	mem2reg_i,
	dmdata_i,
	regwrite_o,
	ALUout_o,
	regdst_o,
	mem2reg_o,
	dmdata_o
);
	input clk_i;
	input regwrite_i;
	input [31:0] ALUout_i;
	input [4:0] regdst_i;
	input mem2reg_i;
	input [31:0] dmdata_i;

	output reg regwrite_o;
	output reg [31:0] ALUout_o;
	output reg [4:0] regdst_o;
	output reg mem2reg_o;
	output reg [31:0] dmdata_o;

	always@(posedge clk_i) begin
		regwrite_o <= regwrite_i;
		ALUout_o <= ALUout_i;
		regdst_o <= regdst_i;
		mem2reg_o <= mem2reg_i;
		dmdata_o <= dmdata_i;
	end
endmodule