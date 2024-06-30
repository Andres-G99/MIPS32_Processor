`timescale 1ns / 1ps

/*
Se implementa un banco de registros de tamaño configurable. 
Permite leer, escribir y reiniciar los registros
*/

module registers
    #(
        parameter REGISTERS_BANK_SIZE = 32,
        parameter REGISTERS_SIZE = 32
    )
    (
        input  wire i_clk,
        input  wire i_reset,
        input  wire i_flush,
        input  wire i_write_enable,
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0] i_addr_A,
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0] i_addr_B,
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0] i_addr_wr,
        input  wire [REGISTERS_SIZE - 1 : 0] i_bus_wr,
        
        output wire [REGISTERS_SIZE - 1 : 0] o_bus_A,
        output wire [REGISTERS_SIZE - 1 : 0] o_bus_B,
        output wire [REGISTERS_BANK_SIZE * REGISTERS_SIZE - 1 : 0] o_bus_debug
    );
    
    reg [REGISTERS_SIZE - 1 : 0] registers [REGISTERS_BANK_SIZE - 1 : 0]; // register matrix
    
    integer i = 0;
    
    always @(negedge i_clk) 
    begin
        if (i_reset || i_flush) // reset registers
            begin
                for (i = 0; i < REGISTERS_BANK_SIZE; i = i + 1)
                    registers[i] <= 'b0; // clear all registers
            end
        else
            begin
                if (i_write_enable)
                    if(i_addr_wr != 0)
                        registers[i_addr_wr] = i_bus_wr; // set registers
                    else
                        registers[i_addr_wr] = 'b0; // clear register 0
            end
    end

    // asignation of the registers
    assign o_bus_A = registers[i_addr_A];
    assign o_bus_B = registers[i_addr_B];

    // debug bus
    generate
        genvar j; 
        // generate a bus with all the registers
        for (j = 0; j < REGISTERS_BANK_SIZE; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * REGISTERS_SIZE - 1 : j * REGISTERS_SIZE] = registers[j];
        end
    endgenerate

endmodule