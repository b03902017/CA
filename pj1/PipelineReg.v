module IFIDRegister
(
	clk_i,
	pc_i,
	inst_i,
	pc_o,
	inst_o
);
	input clk_i;
	input [31:0] pc_i;
	input [31:0] inst_i;

	output reg [31:0] pc_o;
	output reg [31:0] inst_o;

	always@(posedge clk_i) begin
		pc_o <= pc_i;
		inst_o <= inst_i;
	end

endmodule

module IDEXRegister
(
	clk_i,
	regdst_ctrl,
	aluop_ctrl,
	alusrc_ctrl,
	regwrite_ctrl,
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
	regwrite_o,
	ALUout_o,
	regdst_o
);
	input clk_i;
	input regwrite_i;
	input [31:0] ALUout_i;
	input [4:0] regdst_i;

	output reg regwrite_o;
	output reg [31:0] ALUout_o;
	output reg [4:0] regdst_o;

	always@(posedge clk_i) begin
		regwrite_o <= regwrite_i;
		ALUout_o <= ALUout_i;
		regdst_o <= regdst_i;
	end

endmodule

module MEMWBregister
(
	clk_i,
	regwrite_i,
	ALUout_i,
	regdst_i,
	regwrite_o,
	ALUout_o,
	regdst_o
);
	input clk_i;
	input regwrite_i;
	input [31:0] ALUout_i;
	input [4:0] regdst_i;

	output reg regwrite_o;
	output reg [31:0] ALUout_o;
	output reg [4:0] regdst_o;

	always@(posedge clk_i) begin
		regwrite_o <= regwrite_i;
		ALUout_o <= ALUout_i;
		regdst_o <= regdst_i;
	end
endmodule