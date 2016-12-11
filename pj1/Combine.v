module Combine(
	data1_i,
	data2_i,
	data_o
);

input [27:0] data1_i;
input [3:0]  data2_i;
output [31:0] data_o;

assign data_o = {data2_i[3:0], data1_i[27:0]};

endmodule

