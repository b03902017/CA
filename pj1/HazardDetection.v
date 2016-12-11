module HazardDetection
(
	IDEXmemread,
	IDEXrtaddr,
	IFIDrsaddr,
	IFIDrtaddr,
	bubble_ctrl,
	IFIDwrite,
	pcwrite
);

input IDEXmemread;
input [4:0] IDEXrtaddr;
input [4:0] IFIDrsaddr, IFIDrtaddr;

output reg bubble_ctrl, IFIDwrite, pcwrite;

initial begin
	bubble_ctrl <= 1'b0;
	IFIDwrite <= 1'b1;
	pcwrite <= 1'b1;
end

always@(*) begin
	if(IDEXmemread && ((IDEXrtaddr == IFIDrsaddr) || (IDEXrtaddr == IFIDrtaddr)))begin
		bubble_ctrl <= 1'b1; // bubble
		IFIDwrite <= 1'b0; // don't write
		pcwrite <= 1'b0; // don't write
	end
	else begin
		bubble_ctrl <= 1'b0;
		IFIDwrite <= 1'b1;
		pcwrite <= 1'b1;
	end
end

endmodule
