`timescale 1ns / 1ps

module wb
    #(
        parameter BUS_WIDTH = 32
    )
    (
        input  wire i_mem_to_reg,
        input  wire [BUS_WIDTH - 1 : 0] i_alu_result,
        input  wire [BUS_WIDTH - 1 : 0] i_mem_result,
        output wire [BUS_WIDTH - 1 : 0] o_wb_data
    );

    mux 
    #(
        .CHANNELS (2), 
        .BUS_SIZE (BUS_WIDTH)
    ) 
    mux_wb_data
    (
        .selector (i_mem_to_reg),
        .data_in ({i_alu_result, i_mem_result}),
        .data_out (o_wb_data)
    );

endmodule