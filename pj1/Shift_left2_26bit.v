module Shift_left2_26bit(
	data_i,
	data_o
);

input [25:0] data_i;
output [27:0] data_o;

assign data_o = {data_i[25:0], 2'b0};

endmodule
