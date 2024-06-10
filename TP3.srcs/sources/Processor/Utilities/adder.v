`timescale 1ns / 1ps

module adder
    #(
        parameter DATA_WIDTH = 32
    )
    (
        input wire [DATA_WIDTH-1:0] i_a,
        input wire [DATA_WIDTH-1:0] i_b,
        input wire [DATA_WIDTH-1:0] o_res
    );
    
    assign o_res = i_a + i_b;
    
endmodule
