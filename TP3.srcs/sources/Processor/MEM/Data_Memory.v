`timescale 1ns / 1ps

module Data_Memory
    #(
        parameter ADDRESS_WIDTH = 5, // 2^5 = 32 slots de memoria
        parameter MEM_SLOT_WIDTH = 32 // Cada slot de memoria tiene 32 bits
    )
    (
        input wire i_clk,
        input wire i_reset, // reset de la memoria
        input wire i_flush, // flush de la memoria
        input wire i_wr_rd, // 0: read, 1: write
        input wire [ADDRESS_WIDTH-1:0] i_address, // direccion de memoria
        input wire [MEM_SLOT_WIDTH-1:0] i_data, // dato a escribir
        output wire [MEM_SLOT_WIDTH-1:0] o_data // dato leido
        // linea para el debug

    );

    reg [MEM_SLOT_WIDTH-1:0] mem [2**ADDRESS_WIDTH-1:0]; // Memoria de 32 slots de 32 bits
    // mem es una memoria con 2**ADDRESS_WIDTH slots (32) de MEM_SLOT_WIDTH bits (32 bits)

    integer i = 0; // Iterador
    always @(posedge clk) 
    begin
        if (i_reset) 
            begin
                for (i = 0; i < 2**ADDRESS_WIDTH; i = i+1)
                    mem[i] <= 32'b0; // Limpia la memoria
            end
        else
            begin
                if (i_wr_rd) // Write
                    mem[i_address] <= i_data; // Escribe en la direccion i_address el dato i_data
            end
    end

    assign o_data = mem[i_address]; // Lee el dato en la direccion i_address

    /*
        Debugger code
    */

endmodule
