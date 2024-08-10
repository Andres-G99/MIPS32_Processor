`timescale 1ns / 1ps

/* Mantiene y actualiza el PC */

module pc
    #(
        parameter PC_WIDTH = 32, // Tamaño del PC
        parameter PC_STATES_NUM = 3, // Número de estados del PC
        parameter STATES_WIDTH = $clog2(PC_STATES_NUM), // Tamaño del estado
    
        //PC states
        parameter PC_IDLE = 2'b00, // Estado de espera
        parameter PC_NEXT = 2'b01, // Estado de cambio de PC
        parameter PC_END = 2'b10 // Estado de fin de ejecución
    )
    (
        input wire i_clk, 
        input wire i_reset,
        input wire i_halt,
        input wire i_not_load,
        input wire i_enable,
        input wire i_flush,
        input wire i_clear,                        
        input wire [PC_WIDTH - 1 : 0] i_next_pc,
        output wire [PC_WIDTH - 1 : 0] o_pc
    );

    reg [STATES_WIDTH - 1 : 0] state, state_next; 
    reg [PC_WIDTH - 1 : 0] pc, pc_next;

    always @ (negedge i_clk) // 
    begin
        if(i_reset || i_flush || i_clear) // si hay reset, flush o clear, se limpia el PC
            begin
                state <= PC_IDLE;
                pc <= 32'b0;
            end
        else
            begin
                state <= state_next;
                pc <= pc_next;
            end
    end

    always @ (*) 
    begin
        state_next = state;
        pc_next = pc;

        case(state)
            PC_IDLE: // Estado de espera
                begin
                    pc_next = 32'b0;
                    state_next = PC_NEXT;
                end

            PC_NEXT: // Estado de cambio de PC
                begin
                    if (i_enable) 
                        begin
                            if(i_halt) // si hay halt, se termina la ejecución
                                state_next = PC_END;
                            else 
                                begin
                                    if(~i_not_load)
                                        begin
                                            pc_next = i_next_pc;
                                            state_next = PC_NEXT;
                                        end
                                end
                        end
                end

            PC_END:
            begin
                if(~i_halt) // si no hay halt, se vuelve al estado de espera
                    state_next = PC_IDLE;
            end

        endcase
    end

    assign o_pc = pc;

endmodule
