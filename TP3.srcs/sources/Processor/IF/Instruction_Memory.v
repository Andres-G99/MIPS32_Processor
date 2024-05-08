`timescale 1ns / 1ps

module Instruction_Memory
   #(
    parameter PC_WIDTH = 32, // 32 bits
    parameter WORD_WIDTH = 32, // 32 bits
    parameter MEM_SIZE = 32, // 32 palabras
    parameter POINTER_SIZE = $clog2(MEM_SIZE*4) // 32 palabras, 4 bytes direccionables en c/u 
    )
    (
    input wire i_clk, // señal de clock
    input wire i_reset, // señal de reset
    input wire i_inst_write, // señal de escritura
    input wire [PC_WIDTH-1:0] i_pc, // program counter
    input wire [WORD_WIDTH-1:0] i_instruction, // instrucción a escribir
    output wire [WORD_WIDTH-1:0] o_instruction // instrucción leída
    );
    
    localparam MEM_SIZE_BITS = MEM_SIZE * WORD_WIDTH; // 32 palabras de 32 bits
    localparam BYTE_SIZE = 8;
    
    reg [POINTER_SIZE-1:0] pointer; // puntero de memoria
    reg [MEM_SIZE_BITS-1:0] memory; // memoria
    
    always @(posedge i_clk)
    begin
        if(i_reset) // si hay reset, se limpia la memoria y el puntero
            begin
                memory <= CLEAR(MEM_SIZE_BITS);
                pointer <= CLEAR(POINTER_SIZE);
            end
        else
            begin
                if(i_inst_write) // si hay señal de escritura, se escribe la instrucción en la memoria
                    begin
                        memory[BYTE_SIZE*pointer +: WORD_WIDTH] = i_instruction; // +: es un operando que selcciona un rango de bits
                        //8*valor del puntero +: se seleccionan WORD_WIDTH bits
                        // si (8*0), se seleccionan los primeros 32 bits
                        // si (8*1)*4 (4 es incremento del puntero), se seleccionan los siguientes 32 bits (32-63)
                        pointer = pointer + 4; // incremento una palabra puntero
                    end
            end
    end
    
    assign o_instruction = memory[BYTE_SIZE*i_pc +: WORD_WIDTH]; // instruccion leida de la memoria
                                                                // se seleccionan 32 bits a partir de la dirección del PC (el PC ya viene incrementado en 4)
    
    
endmodule
