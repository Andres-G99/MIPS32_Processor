`timescale 1ns / 1ps

module mem
    #(
        parameter IO_BUS_SIZE   = 32,
        parameter MEM_ADDR_SIZE = 5
    )
    (
        input  wire                                          i_clk,
        input  wire                                          i_reset,
        input  wire                                          i_flush,
        input  wire                                          i_mem_wr_rd,
        input  wire [1 : 0]                                  i_mem_wr_src,
        input  wire [2 : 0]                                  i_mem_rd_src,
        input  wire [MEM_ADDR_SIZE - 1 : 0]                  i_mem_addr,
        input  wire [IO_BUS_SIZE - 1 : 0]                    i_bus_b,
        output wire [IO_BUS_SIZE - 1 : 0]                    o_mem_rd,
        output wire [2**MEM_ADDR_SIZE * IO_BUS_SIZE - 1 : 0] o_bus_debug
    );

    wire [8 - 1 : 0]      bus_b_byte;
    wire [IO_BUS_SIZE / 2 - 1 : 0] bus_b_halfword;
    wire [IO_BUS_SIZE - 1 : 0]     bus_b_uext_byte;
    wire [IO_BUS_SIZE - 1 : 0]     bus_b_uext_halfword;

    wire [8 - 1 : 0]      mem_out_data_byte;
    wire [IO_BUS_SIZE / 2 - 1 : 0] mem_out_data_halfword;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_uext_byte;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_uext_halfword;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_sext_byte;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data_sext_halfword;

    wire [IO_BUS_SIZE - 1 : 0]     mem_in_data;
    wire [IO_BUS_SIZE - 1 : 0]     mem_out_data;

    assign bus_b_byte            = i_bus_b[8 - 1 : 0];
    assign bus_b_halfword        = i_bus_b[IO_BUS_SIZE / 2 - 1 : 0];

    assign mem_out_data_byte     = mem_out_data[8 - 1 : 0];
    assign mem_out_data_halfword = mem_out_data[IO_BUS_SIZE / 2 - 1 : 0];

    data_memory
    #(
        .ADDR_SIZE (MEM_ADDR_SIZE),
        .SLOT_SIZE (IO_BUS_SIZE)
    )
    data_memory_unit
    (
        .i_clk       (i_clk),
        .i_reset     (i_reset),
        .i_flush     (i_flush),
        .i_wr_rd     (i_mem_wr_rd),
        .i_addr      (i_mem_addr),
        .i_data      (mem_in_data),
        .o_data      (mem_out_data),
        .o_bus_debug (o_bus_debug)
    );

    mux 
    #(
        .CHANNELS (3), 
        .BUS_SIZE (IO_BUS_SIZE)
    ) 
    mux_in_mem_unit
    (
        .selector (i_mem_wr_src),
        .data_in  ({bus_b_uext_byte, bus_b_uext_halfword, i_bus_b}),
        .data_out (mem_in_data)
    );

    mux 
    #(
        .CHANNELS (5), 
        .BUS_SIZE (IO_BUS_SIZE)
    ) 
    mux_out_mem_unit
    (
        .selector (i_mem_rd_src),
        .data_in  ({mem_out_data_uext_byte, mem_out_data_uext_halfword, mem_out_data_sext_byte, mem_out_data_sext_halfword, mem_out_data}),
        .data_out (o_mem_rd)
    );

    extend 
    #(
        .DATA_ORIGINAL_SIZE  (IO_BUS_SIZE / 2), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_bus_b_halfword_unit 
    (
        .i_value (bus_b_halfword),
        .i_is_signed(1'b0),
        .o_extended_value (bus_b_uext_halfword)
    );

    extend 
    #(
        .DATA_ORIGINAL_SIZE  (8), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_bus_b_byte_unit 
    (
        .i_value (bus_b_byte),
        .i_is_signed(1'b0),
        .o_extended_value (bus_b_uext_byte)
    );

    extend 
    #(
        .DATA_ORIGINAL_SIZE  (IO_BUS_SIZE / 2), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_mem_out_data_halfword_unit 
    (
        .i_value (mem_out_data_halfword),
        .i_is_signed(1'b0),
        .o_extended_value (mem_out_data_uext_halfword)
    );

    extend 
    #(
        .DATA_ORIGINAL_SIZE  (8), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    unsig_extend_mem_out_data_byte_unit 
    (
        .i_value (mem_out_data_byte),
        .i_is_signed(1'b0),
        .o_extended_value (mem_out_data_uext_byte)
    );

    extend 
    #(
        .DATA_ORIGINAL_SIZE  (IO_BUS_SIZE / 2), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    sig_extend_mem_out_data_halfword_unit
    (
        .i_value (mem_out_data_halfword),
        .i_is_signed(1'b1),
        .o_extended_value (mem_out_data_sext_halfword)
    );

    extend
    #(
        .DATA_ORIGINAL_SIZE  (8), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    )
    sig_extend_mem_out_data_byte_unit
    (
        .i_value (mem_out_data_byte),
        .i_is_signed(1'b1),
        .o_extended_value (mem_out_data_sext_byte)
    );

endmodule
