`timescale 1ns / 1ps

/* Memoria de datos */

module data_memory
    #(
        parameter ADDR_SIZE = 5,
        parameter SLOT_SIZE = 32
    )
    (      
        input wire i_clk,
        input wire i_reset,
        input wire i_flush,
        input wire i_wr_rd,
        input wire [ADDR_SIZE - 1 : 0] i_addr,
        input wire [SLOT_SIZE - 1 : 0] i_data,
        output wire [SLOT_SIZE - 1 : 0] o_data,
        output wire [2**ADDR_SIZE * SLOT_SIZE - 1 : 0] o_bus_debug
    );

    reg [SLOT_SIZE - 1 : 0] memory [2**ADDR_SIZE - 1 : 0]; // mem matrix

    integer i = 0;

    always@(posedge i_clk) 
    begin
        if (i_reset || i_flush) 
            begin
                for (i = 0; i < 2**ADDR_SIZE; i = i + 1)
                    memory[i] <= 'b0;
            end
        else
            begin
                if (i_wr_rd) // write opp
                    memory[i_addr] <= i_data;
            end
    end

    assign o_data = memory[i_addr]; // for reading

    /* Outputs entire memory for printing */
    generate
        genvar j;
        
        for (j = 0; j < 2**ADDR_SIZE; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * SLOT_SIZE - 1 : j * SLOT_SIZE] = memory[j];
        end
    endgenerate
endmodule
