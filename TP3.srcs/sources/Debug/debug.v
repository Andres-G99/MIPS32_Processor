`timescale 1ns / 1ps

module debug
    #(
        parameter UART_BUS_SIZE = 8,
        parameter DATA_IN_BUS_SIZE = UART_BUS_SIZE * 4,
        parameter DATA_OUT_BUS_SIZE = UART_BUS_SIZE * 7,
        parameter REGISTER_SIZE = 32,
        parameter REGISTER_BANK_BUS_SIZE = REGISTER_SIZE * 32,
        parameter MEMORY_SLOT_SIZE = 32,
        parameter MEMORY_DATA_BUS_SIZE = MEMORY_SLOT_SIZE * 32
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_uart_empty,
        input wire i_uart_full,
        input wire i_instruction_memory_empty,
        input wire i_instruction_memory_full,
        input wire i_mips_end_program, // fin de programa
        input wire [UART_BUS_SIZE - 1 : 0] i_uart_data_rd, // data que llega desde la uart
        input wire [REGISTER_BANK_BUS_SIZE - 1 : 0] i_registers_content, // contenido de registros
        input wire [MEMORY_DATA_BUS_SIZE - 1 : 0] i_memory_content, // contenido de memoria
        output wire o_uart_wr, // datos escritos
        output wire o_uart_rd, //  datos leidos
        output wire o_mips_instruction_wr, // nueva instruccion
        output wire o_mips_flush, // reset de etapas
        output wire o_mips_clear_program, // reset de programa
        output wire o_mips_enabled,
        output wire [UART_BUS_SIZE - 1 : 0] o_uart_data_wr,
        output wire [REGISTER_SIZE - 1 : 0] o_mips_instruction,
        output wire [4 : 0] o_state
    );

    wire start_uart_rd;
    wire start_uart_wr;
    wire start_uart_wr_control;
    wire start_uart_wr_memory;
    wire start_uart_wr_printer;
    wire start_register_print;
    wire start_memory_print;
    wire end_uart_rd;
    wire end_uart_wr;
    wire end_register_print;
    wire end_memory_print;
    wire [UART_BUS_SIZE - 1 : 0] clk_cicle;
    wire [DATA_IN_BUS_SIZE - 1 : 0] data_uart_rd;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_control;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_memory;
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_printer;

    assign start_uart_wr = start_uart_wr_control | start_uart_wr_memory | start_uart_wr_printer;

    reg  [DATA_OUT_BUS_SIZE - 1 : 0] reg_data_uart_wr;

    always @(posedge i_clk)
    begin
        if (i_reset)
            reg_data_uart_wr <= 'b0;
        else
            begin
                if (start_uart_wr_control)
                    reg_data_uart_wr <= data_uart_wr_control;
                else if (start_uart_wr_memory)
                    reg_data_uart_wr <= data_uart_wr_memory;
                else if (start_uart_wr_printer)
                    reg_data_uart_wr <= data_uart_wr_printer;
            end
    end

    assign data_uart_wr = reg_data_uart_wr;

    buffer_reader
    #(
        .DATA_LEN (UART_BUS_SIZE),
        .DATA_OUT_LEN (DATA_IN_BUS_SIZE)
    )
    buffer_reader_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_is_uart_empty (i_uart_empty),
        .i_rd (start_uart_rd),
        .i_uart_data (i_uart_data_rd),
        .o_uart_rd (o_uart_rd),
        .o_rd_finished (end_uart_rd),
        .o_rd_buffer (data_uart_rd)
    );

    buffer_writer
    #(
        .DATA_LEN (UART_BUS_SIZE),
        .DATA_IN_LEN (DATA_OUT_BUS_SIZE)
    )
    buffer_writer_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_is_uart_full (i_uart_full),
        .i_wr (start_uart_wr),
        .i_wr_data (data_uart_wr),
        .o_uart_wr (o_uart_wr),
        .o_wr_finished (end_uart_wr),
        .o_wr_buffer (o_uart_data_wr)
    );

    reg_printer
    #(
        .UART_BUS_SIZE (UART_BUS_SIZE),
        .DATA_OUT_BUS_SIZE (DATA_OUT_BUS_SIZE),
        .REGISTER_SIZE (REGISTER_SIZE),
        .REGISTER_BANK_BUS_SIZE (REGISTER_BANK_BUS_SIZE)
    )
    reg_printer_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_start (start_register_print),
        .i_is_mem(1'b0),
        .i_reg_bank (i_registers_content),
        .i_clk_cicle (clk_cicle),
        .i_write_finish (end_uart_wr),
        .o_write (start_uart_wr_printer),
        .o_finish (end_register_print),
        .o_data_write (data_uart_wr_printer)
    );

    reg_printer
    #(
        .UART_BUS_SIZE (UART_BUS_SIZE),
        .DATA_OUT_BUS_SIZE (DATA_OUT_BUS_SIZE),
        .REGISTER_SIZE (MEMORY_SLOT_SIZE),
        .REGISTER_BANK_BUS_SIZE (MEMORY_DATA_BUS_SIZE)
    )
    mem_printer_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_start (start_memory_print),
        .i_is_mem(1'b1),
        .i_reg_bank (i_memory_content),
        .i_clk_cicle (clk_cicle),
        .i_write_finish (end_uart_wr),
        .o_write (start_uart_wr_memory),
        .o_finish (end_memory_print),
        .o_data_write (data_uart_wr_memory)
    );

    interface
    #(
        .UART_DATA_LEN (UART_BUS_SIZE),
        .DATA_IN_LEN (DATA_IN_BUS_SIZE),
        .DATA_OUT_LEN (DATA_OUT_BUS_SIZE),
        .REG_LEN (REGISTER_SIZE)
    )
    interface_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_instr_mem_empty (i_instruction_memory_empty),
        .i_instr_mem_full (i_instruction_memory_full),
        .i_finish_program (i_mips_end_program),
        .i_uart_read_finish (end_uart_rd),
        .i_uart_write_finish (end_uart_wr),
        .i_print_regs_finish (end_register_print),
        .i_print_mem_finish (end_memory_print),
        .i_data_uart_read (data_uart_rd),
        .o_clk_cicle (clk_cicle),
        .o_uart_write (start_uart_wr_control),
        .o_uart_read (start_uart_rd),
        .o_print_regs (start_register_print),
        .o_print_mem (start_memory_print),
        .o_new_instruction (o_mips_instruction_wr),
        .o_flush (o_mips_flush),
        .o_clear_program (o_mips_clear_program),
        .o_mips_enabled (o_mips_enabled),
        .o_ctrl_info (data_uart_wr_control),
        .o_mips_instruction (o_mips_instruction),
        .o_state (o_state)
    );

endmodule