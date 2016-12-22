module IDForwarding
(
	IFIDrsaddr,
	IFIDrtaddr,
	MEMWBregwrite,
	MEMWBregdst,
	IDforwardA,
	IDforwardB
);

input [4:0] IFIDrsaddr, IFIDrtaddr, MEMWBregdst;
input MEMWBregwrite;

output reg IDforwardA, IDforwardB;

always@(*) begin
	IDforwardA = 0;
	IDforwardB = 0;
	if (MEMWBregwrite && (MEMWBregdst != 5'b0)) begin
		if (MEMWBregdst == IFIDrsaddr) begin
			IDforwardA = 1;
		end
		if (MEMWBregdst == IFIDrtaddr) begin
			IDforwardB = 1;
		end
	end
end

endmodule
