
`timescale 1ns / 1ps

module _if
    #(
        //parameter PC_SIZE            = `DEFAULT_PC_SIZE,
        //parameter WORD_SIZE_IN_BYTES = `DEFAULT_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES,
        //parameter MEM_SIZE_IN_WORDS  = `DEFAULT_INSTRUCTION_MEMORY_MEM_SIZE_IN_WORDS
        
        parameter PC_SIZE = 32,
        parameter WORD_SIZE_IN_BYTES = 4,
        parameter MEM_SIZE_IN_WORDS = 10
        //parameter INSTRUCTION_WIDTH = 32
    )
    (
        input  wire                                           i_clk, 
        input  wire                                           i_reset,
        input  wire                                           i_halt,
        input  wire                                           i_not_load,
        input  wire                                           i_enable,
        input  wire                                           i_next_pc_src,
        input  wire                                           i_write_mem,
        input  wire                                           i_clear_mem,
        input  wire                                           i_flush,
        input  wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] i_instruction,
        input  wire [PC_SIZE - 1 : 0]                         i_next_not_seq_pc,
        input  wire [PC_SIZE - 1 : 0]                         i_next_seq_pc,
        output wire                                           o_full_mem,
        output wire                                           o_empty_mem,
        output wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] o_instruction,
        output wire [PC_SIZE - 1 : 0]                         o_next_seq_pc
    );
    
    localparam BUS_SIZE = WORD_SIZE_IN_BYTES * 8;

    wire [PC_SIZE - 1 : 0]  next_pc;
    wire [PC_SIZE - 1 : 0]  pc;

    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_2_unit_pc
    (
        .selector(i_next_pc_src),
        .data_in ({i_next_not_seq_pc, i_next_seq_pc}),
        .data_out(next_pc)
    );

    adder 
    #
    (
        .BUS_SIZE(BUS_SIZE)
    ) 
    adder_unit 
    (
        .a  (WORD_SIZE_IN_BYTES),
        .b  (pc),
        .sum(o_next_seq_pc)
    );

    pc 
    #(
        .PC_WIDTH(PC_SIZE)
    ) 
    pc_unit 
    (
        .i_clk     (i_clk),
        .i_reset   (i_reset),
        .i_flush   (i_flush),
        .i_clear   (i_clear_mem),
        .i_halt    (i_halt),
        .i_not_load(i_not_load),
        .i_enable  (i_enable),
        .i_next_pc (next_pc),
        .o_pc      (pc)
    );

    Instruction_Memory 
    #(
        .WORD_WIDTH_BYTES(WORD_SIZE_IN_BYTES),
        .MEM_SIZE_WORDS (MEM_SIZE_IN_WORDS),
        .PC_WIDTH       (PC_SIZE)
    ) 
    instruction_memory_unit 
    (
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_inst_write       (i_write_mem),
        .i_pc               (pc),
        .i_instruction      (i_instruction),
        .i_clear            (i_clear_mem),
        .o_full_mem         (o_full_mem),
        .o_empty_mem        (o_empty_mem),
        .o_instruction      (o_instruction)
    );


endmodule