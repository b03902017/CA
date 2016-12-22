module ALU_Control(
	funct_i,
	ALUOp_i,
	ALUCtrl_o
);

input [5:0] funct_i;
input [2:0] ALUOp_i;
output reg [2:0] ALUCtrl_o;

`define ADD 3'b000
`define SUB 3'b001
`define AND 3'b010
`define OR  3'b011
`define MUL 3'b101

always@(*) begin
	case (ALUOp_i)
		3'b000: begin
			ALUCtrl_o <= `ADD;
		end
		default: begin
			case(funct_i)
				6'b100000: begin
					ALUCtrl_o <= `ADD;
				end
				6'b100010: begin
					ALUCtrl_o <= `SUB;
				end
				6'b100100: begin
					ALUCtrl_o <= `AND;
				end
				6'b100101: begin
					ALUCtrl_o <= `OR;
				end
				6'b011000: begin
					ALUCtrl_o <= `MUL;
				end
			endcase
		end
	endcase
end
endmodule
