`timescale 1ns / 1ps

module diff_values
    #(
        parameter DATA_LEN = 32
    )
    (
        input  wire [DATA_LEN - 1 : 0] i_data_A,
        input  wire [DATA_LEN - 1 : 0] i_data_B,
        output wire o_are_diff
    );

    assign o_are_diff = i_data_A != i_data_B;

endmodule