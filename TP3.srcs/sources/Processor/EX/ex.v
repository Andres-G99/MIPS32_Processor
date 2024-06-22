`timescale 1ns / 1ps

module ex
    #(
        parameter BUS_SIZE = 32,
        parameter ALU_CTRL_BUS_WIDTH = 6
    )
    (   // control inputs
        input wire i_alu_src_A, 
        input wire  [2 : 0] i_alu_src_B,
        input wire  [1 : 0] i_reg_dst,
        input wire  [2 : 0] i_alu_opp,
        input wire  [1 : 0] i_src_A_select, // selects the source for forwarding data to the ALU input A
        input wire  [1 : 0] i_src_B_select, // selects the source for forwarding data to the ALU input B
        input wire  [4 : 0] i_rt,
        input wire  [4 : 0] i_rd,
        input wire  [5 : 0] i_funct,
        // data inputs
        input wire  [BUS_SIZE - 1 : 0] i_forwarded_alu_result, // for data forwarding (result from previous instruction)
        input wire  [BUS_SIZE - 1 : 0] i_forwarded_wb_result, // for data forwarding (writeback from previous instruction)
        input wire  [BUS_SIZE - 1 : 0] i_bus_A,
        input wire  [BUS_SIZE - 1 : 0] i_bus_B,
        input wire  [BUS_SIZE - 1 : 0] i_shamt_ext_unsigned,
        input wire  [BUS_SIZE - 1 : 0] i_inm_ext_signed,
        input wire  [BUS_SIZE - 1 : 0] i_inm_upp,
        input wire  [BUS_SIZE - 1 : 0] i_inm_ext_unsigned,
        input wire  [BUS_SIZE - 1 : 0] i_next_seq_pc,
        
        output wire [4 : 0] o_wb_addr,
        output wire [BUS_SIZE - 1 : 0] o_alu_result,
        output wire [BUS_SIZE - 1 : 0] o_forwarded_data_A, // carries the forwarded data that will be used as ALU input A
        output wire [BUS_SIZE - 1 : 0] o_forwarded_data_B // carries the forwarded data that will be used as ALU input B
    );

    /* Internal wires */
    wire [BUS_SIZE - 1 : 0] alu_data_A;
    wire [BUS_SIZE - 1 : 0] alu_data_B;
    wire [5 : 0] alu_ctrl;

    /* ALU */
    alu 
    #(
        .IO_BUS_WIDTH (BUS_SIZE),
        .CTRL_BUS_WIDTH (ALU_CTRL_BUS_WIDTH)
    ) 
    alu_unit 
    (
        .i_ctrl (alu_ctrl),
        .i_data_A (alu_data_A),
        .i_data_B (alu_data_B),
        .o_result (o_alu_result)
    );

    alu_control 
    #(
        .ALU_CTRL_BUS_WIDTH (ALU_CTRL_BUS_WIDTH),
        .ALU_OP_BUS_WIDTH (3),
        .ALU_FUNCT_BUS_WIDTH (6)
    ) 
    alu_control_unit 
    (
        .i_funct (i_funct),
        .i_alu_opp (i_alu_opp),
        .o_alu_ctrl (alu_ctrl)
    );

    /* MUX for Data A and B */
    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_alu_src_data_a_unit
    (
        .selector (i_alu_src_A),
        .data_in ({o_forwarded_data_A, i_shamt_ext_unsigned}),
        .data_out (alu_data_A)
    );

    mux 
    #(
        .CHANNELS (5), 
        .BUS_SIZE (BUS_SIZE)
    ) 
    mux_alu_src_data_b_unit
    (
        .selector (i_alu_src_B),
        .data_in ({o_forwarded_data_B, i_inm_ext_unsigned, i_inm_ext_signed, i_inm_upp, i_next_seq_pc}),
        .data_out (alu_data_B)
    );

    /* MUX for short circuit sources */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_sc_src_a_unit
    (
        .selector (i_src_A_select),
        .data_in ({i_forwarded_alu_result, i_forwarded_wb_result, i_bus_A}),
        .data_out (o_forwarded_data_A)
    );

    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_sc_src_b_unit
    (
        .selector (i_src_B_select),
        .data_in ({i_forwarded_alu_result, i_forwarded_wb_result, i_bus_B}),
        .data_out (o_forwarded_data_B)
    );

    /* MUX for register destination */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(5)
    ) 
    mux_reg_dst_unit
    (
        .selector (i_reg_dst),
        .data_in ({5'b11111, i_rd, i_rt}),
        .data_out (o_wb_addr)
    );
    
endmodule