`timescale 1ns / 1ps

module PC
   #(
    parameter PC_WIDTH = 32, // Tamaño del PC
    parameter PC_STATES_NUM = 3, // Número de estados del PC
    
    //PC states
    parameter PC_IDLE = 2'b00, // Estado de espera
    parameter PC_NEXT = 2'b01, // Estado de cambio de PC
    parameter PC_END = 2'b10 // Estado de fin de ejecución
    )
    (
    input wire i_clk, // Señal de clock
    input wire i_reset, // Señal de reset
    input wire i_halt, // Señal de halt
    /*
    Quedan definir mas señales
    */
    
    input wire [PC_WIDTH-1:0] i_pc_next, // Siguiente dirección de PC
    output wire [PC_WIDTH-1:0] o_pc // Valor del PC (salida)
    );
    
    reg [PC_STATES_NUM-1:0] state, state_next; // Estados del PC
    reg [PC_WIDTH-1:0] pc, pc_next; // Valores del PC
    
    always @ (posedge i_clk) 
    begin
        if(i_reset) // Si se activa la señal de reset, se reinicia el PC
            begin
                state <= PC_IDLE;
                pc <= CLEAR(PC_WIDTH);
            end
        else // Si no se activa la señal de reset, se actualiza el PC (o no) según el estado
            begin
                state <= state_next;
                pc <= pc_next;
            end
    end
    
    always @ (*) // Máquina de estados del PC
    begin
        state_next = state; // Valor default
        pc_next = pc; // Valor default

        case(state)
            PC_IDLE: // Estado de espera
                begin
                    if(i_halt) // Si se activa la señal de halt, se detiene el PC
                        state_next = PC_END;
                    else
                        state_next = PC_NEXT;
                end
            PC_NEXT: // Estado de cambio de PC
                begin
                    if(i_halt) // Si se activa la señal de halt, se detiene el PC
                        state_next = PC_END;
                    else
                        state_next = PC_IDLE;
                        pc_next = i_pc_next;
                end
            PC_END: // Estado de fin de ejecución
                begin
                    if(i_reset && ~i_halt) // Si se activa la señal de reset y no se activa la señal de halt, se reinicia el PC
                        state_next = PC_IDLE;
                    else
                        state_next = PC_END;
                end
        endcase
    end
    
    assign o_pc = pc;
    
endmodule
