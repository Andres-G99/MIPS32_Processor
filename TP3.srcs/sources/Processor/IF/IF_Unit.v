
`timescale 1ns / 1ps

/*
Se implementa la etapa de fetch de instrucciones (IF: Instruction FEech),
obtiene la proxima instruccion y actualiza el PC.
*/

module _if
    #(
        parameter PC_SIZE = 32,
        parameter WORD_SIZE_IN_BYTES = 4,
        parameter MEM_SIZE_IN_WORDS = 10
    )(
        input wire i_clk, 
        input wire i_reset,
        input wire i_halt,
        input wire i_not_load, // indica si se carga la instruccion
        input wire i_enable, // habilita el modulo
        input wire i_next_pc_src, // indica si se toma el pc secuencial o no secuencial
        input wire i_write_mem,
        input wire i_clear_mem,
        input wire i_flush,
        input wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] i_instruction, // instruccion recibida
        input wire [PC_SIZE - 1 : 0] i_next_not_seq_pc, // proximo pc no secuencial
        input wire [PC_SIZE - 1 : 0] i_next_seq_pc, // proximo pc secuencial
        output wire o_full_mem,
        output wire o_empty_mem,
        output wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] o_instruction,
        output wire [PC_SIZE - 1 : 0] o_next_seq_pc
    );
    
    localparam BUS_SIZE = WORD_SIZE_IN_BYTES * 8;

    wire [PC_SIZE - 1 : 0] next_pc;
    wire [PC_SIZE - 1 : 0] pc;

    /* Selecciona proximo PC (secuencial o no secuencial)*/
    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_pc_unit
    (
        .selector (i_next_pc_src),
        .data_in ({i_next_not_seq_pc, i_next_seq_pc}),
        .data_out (next_pc)
    );

    /* Calcula proximo PC secuencial */
    adder 
    #
    (
        .BUS_SIZE(BUS_SIZE)
    ) 
    adder_unit 
    (
        .a (WORD_SIZE_IN_BYTES),
        .b (pc),
        .sum(o_next_seq_pc)
    );

    pc 
    #(
        .PC_WIDTH(PC_SIZE)
    ) 
    pc_unit 
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_flush (i_flush),
        .i_clear (i_clear_mem),
        .i_halt (i_halt),
        .i_not_load(i_not_load),
        .i_enable (i_enable),
        .i_next_pc (next_pc),
        .o_pc (pc)
    );

    Instruction_Memory 
    #(
        .WORD_WIDTH_BYTES (WORD_SIZE_IN_BYTES),
        .MEM_SIZE_WORDS (MEM_SIZE_IN_WORDS),
        .PC_WIDTH (PC_SIZE)
    ) 
    instruction_memory_unit 
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_inst_write (i_write_mem),
        .i_pc (pc),
        .i_instruction (i_instruction),
        .i_clear (i_clear_mem),
        .o_full_mem (o_full_mem),
        .o_empty_mem (o_empty_mem),
        .o_instruction (o_instruction)
    );


endmodule