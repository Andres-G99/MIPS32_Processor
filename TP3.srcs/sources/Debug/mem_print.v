`timescale 1ns / 1ps

module mem_printer
    #(
        parameter UART_BUS_SIZE = 8,
        parameter DATA_OUT_BUS_SIZE = UART_BUS_SIZE * 7,
        parameter MEMORY_SLOT_SIZE = 32,
        parameter MEMORY_DATA_BUS_SIZE = MEMORY_SLOT_SIZE * 32
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_write_finish, // final de una operación de escritura
        input wire i_start,  
        input wire [MEMORY_DATA_BUS_SIZE - 1 : 0] i_mem_bank, // contenido de la memoria
        input wire [UART_BUS_SIZE - 1 : 0] i_clk_cicle,
        output wire o_write, // indica si se debe escribir en la UART
        output wire o_finish, // indica si se ha terminado de escribir
        output wire [DATA_OUT_BUS_SIZE - 1 : 0] o_data_write // datos a escribir en la UART
    );

    // Estados de la máquina de estados
    localparam STATE_IDLE = 2'b00;
    localparam STATE_PRINT = 2'b01;
    localparam STATE_WAIT_WR_TRANSITION = 2'b10;
    localparam STATE_WAIT_WR = 2'b11;

    localparam MEMORY_POINTER_SIZE = $clog2(MEMORY_DATA_BUS_SIZE / MEMORY_SLOT_SIZE);

    reg [1 : 0] state, state_next;
    reg write, write_next;
    reg [DATA_OUT_BUS_SIZE - 1 : 0] data_write, data_write_next;
    reg [MEMORY_POINTER_SIZE : 0] memory_pointer, memory_pointer_next;
    reg _end, end_next;
    
    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state <= STATE_IDLE;
                memory_pointer <= 'b0;
                data_write <= 'b0;
                write <= 1'b0;
                _end <= 1'b0;
            end
        else
            begin
                state <= state_next;
                memory_pointer <= memory_pointer_next;
                data_write <= data_write_next;
                write <= write_next;
                _end <= end_next;
            end
    end
    
    always @(*)
    begin
        state_next = state;
        memory_pointer_next = memory_pointer;
        data_write_next = data_write;
        write_next = write;
        end_next = _end;
    
        case (state)

            // IDLE: espera inicio
            STATE_IDLE:
            begin          
                if (i_start) 
                    begin
                        state_next = STATE_PRINT;
                        end_next = 1'b0;
                    end
            end

            // PRINT: prepara dato para mandar
            STATE_PRINT:
            begin
                if (memory_pointer < MEMORY_DATA_BUS_SIZE / MEMORY_SLOT_SIZE) // leer de a un registro
                    begin
                        data_write_next = {8'b00000010, i_clk_cicle , { { (UART_BUS_SIZE - MEMORY_POINTER_SIZE - 1) { 1'b0 } }, memory_pointer }, i_mem_bank[memory_pointer * MEMORY_SLOT_SIZE +: MEMORY_SLOT_SIZE] };
                        memory_pointer_next = memory_pointer + 1;
                        write_next = 1'b1;
                        state_next = STATE_WAIT_WR_TRANSITION;
                    end
                else
                    begin
                        end_next = 1'b1;
                        memory_pointer_next = 'b0;
                        state_next = STATE_IDLE;
                    end
            end

            STATE_WAIT_WR_TRANSITION:
            begin
                state_next = STATE_WAIT_WR;
            end

            // WAIT_WR: espera a que se termine de escribir
            STATE_WAIT_WR:
            begin
                write_next = 1'b0;
                if (i_write_finish)
                    state_next = STATE_PRINT;
            end

        endcase
    end

    assign o_write = write;
    assign o_data_write = data_write;
    assign o_finish = _end;

endmodule