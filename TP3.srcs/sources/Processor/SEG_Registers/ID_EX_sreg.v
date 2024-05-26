`timescale 1ns / 1ps


module ID_EX_sreg
    #(
        parameter BUS_WIDTH = 32
    )
    (
        input wire i_clk, // Clock
        input wire i_reset, // Reset
        input wire i_enable, // Enable
        input wire i_flush, // Flush

        // Control inputs
        input wire i_stop_jump, // Stop jump
        //input wire[2:0] i_mem_read_src, // Mem read source
        //input wire[1:0] i_mem_write_src, // Mem write source
        //input wire i_mem_wr, // Mem write
        //input wire i_mem_rd, // Mem read

        // Data inputs
        input wire [BUS_WIDTH-1:0] i_op_a, // Operando A
        input wire [BUS_WIDTH-1:0] i_op_b // Operando B
        
        
        // Te lo dejo a vos xq tenes mas idea de las señales que van aca




    );
endmodule
