`timescale 1ns / 1ps


module IF_ID_sreg
    #(
        parameter PC_WIDTH = 32,
        parameter INSTRUC_WIDTH = 32
    )
    (
        input wire i_clk, // Clock
        input wire i_reset, // Reset
        input wire i_enable, // Enable
        input wire i_flush, 
        input wire i_halt,
        input wire [PC_WIDTH-1:0] i_next_pc_sq, // PC siguiente en modo secuencial
        //input wire [PC_WIDTH-1:0] i_next_pc_br, // PC siguiente en modo branch
        input wire [INSTRUC_WIDTH-1:0] i_instruction, // Instrucción

        output wire [PC_WIDTH-1:0] o_next_pc_sq, // PC
        output wire [INSTRUC_WIDTH-1:0] o_instruction, // Instrucción
        output wire o_halt
    );

    // Registers
    reg [PC_WIDTH-1:0] next_pc_sq;
    reg [INSTRUC_WIDTH-1:0] instruction;
    reg halt;

    // state machine
    always @(posedge i_clk)
    begin
        if(i_reset || i_flush) // Si reset o flush se limpian los registros
        begin
            next_pc_sq <= 0; 
            instruction <= 0;
            halt <= 0;
        end
        else if(i_enable) // Si enable se actualizan los registros
        begin
            next_pc_sq <= i_next_pc_sq;
            instruction <= i_instruction;
            halt <= i_halt;
        end
    end

    assign o_next_pc_sq = next_pc_sq;
    assign o_instruction = instruction;
    assign o_halt = halt;

endmodule
