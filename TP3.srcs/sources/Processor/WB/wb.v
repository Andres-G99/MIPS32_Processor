`timescale 1ns / 1ps

/*
Se implementa la etapa de Write Back (WB),
que escribe en los registros el resultado correspondiente.
*/

module wb
    #(
        parameter BUS_WIDTH = 32
    )
    (
        input  wire i_mem_to_reg, // indica si hay que escribir en los registros
        input  wire [BUS_WIDTH - 1 : 0] i_alu_result,
        input  wire [BUS_WIDTH - 1 : 0] i_mem_result,
        output wire [BUS_WIDTH - 1 : 0] o_wb_data  // datos a escribir en los registros
    );

    /* Seleccionar si escribimos el resultado de la ALU o el de la opp en memoria */
    mux 
    #(
        .CHANNELS (2), 
        .BUS_SIZE (BUS_WIDTH)
    ) 
    mux_wb_unit
    (
        .selector (i_mem_to_reg),
        .data_in ({i_alu_result, i_mem_result}),
        .data_out (o_wb_data)
    );

endmodule