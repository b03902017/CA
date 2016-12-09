module MUX_stall(
    data1_i,
    select_i,
    data_o
);
    input [8:0] data1_i;
    input select_i;
    output [8:0] data_o;

    assign data_o = (select_i == 0)? data1_i: 9'b0;

endmodule
