module ForwardingUnit
(
	IDEXrsaddr,
	IDEXrtaddr,
	EXMEMregwrite,
	EXMEMregdst,
	MEMWBregwrite,
	MEMWBregdst,
	forwardA,
	forwardB
);

input [4:0] IDEXrsaddr,IDEXrtaddr,EXMEMregdst,MEMWBregdst;
input EXMEMregwrite, MEMWBregwrite;

output reg [1:0] forwardA, forwardB;
always@(*) begin
	forwardA = 2'b00;
	forwardB = 2'b00;
	if (MEMWBregwrite && (MEMWBregdst != 5'b0)) begin
		if (MEMWBregdst == IDEXrsaddr) begin
			forwardA = 2'b01;
		end
		if (MEMWBregdst == IDEXrtaddr) begin
			forwardB = 2'b01;
		end
	end

	if (EXMEMregwrite && (EXMEMregdst != 5'b0)) begin	
		if (EXMEMregdst == IDEXrsaddr) begin
			forwardA = 2'b10;
		end
		if (EXMEMregdst == IDEXrtaddr) begin
			forwardB = 2'b10;
		end
	end

end

endmodule