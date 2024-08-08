`timescale 1ns / 1ps

module risk_detection
    #(
        parameter CODE_FUNCT_JALR = 6'b001001,
        parameter CODE_FUNCT_JR = 6'b001000,

        parameter CODE_OP_R_TYPE = 6'b000000,
        parameter CODE_OP_BNE = 6'b000101,
        parameter CODE_OP_BEQ = 6'b000100,

        parameter CODE_OP_HALT = 6'b111111,

        parameter CODE_OP_LW = 6'b100011,
        parameter CODE_OP_LB = 6'b100000,
        parameter CODE_OP_LBU = 6'b100100,
        parameter CODE_OP_LH = 6'b100001,
        parameter CODE_OP_LHU = 6'b100101,
        parameter CODE_OP_LUI = 6'b001111,
        parameter CODE_OP_LWU = 6'b100111
    )(
        input wire i_jump_stop, // Indica si se debe detener el salto (REVISAR)
        input wire [4:0] i_if_id_rs, // Registro rs en la etapa IF/ID
        input wire [4:0] i_if_id_rd, // Registro rd en la etapa IF/ID
        input wire [5:0] i_if_id_op, // Código de operación en la etapa IF/ID
        input wire [5:0] i_if_id_funct, // Código de función en la etapa IF/ID

        input wire [4:0] i_id_ex_rt, // Registro rt en la etapa ID/EX
        input wire [5:0] i_id_ex_op, // Código de operación en la etapa ID/EX

        output wire o_jmp_stop, // Detiene al procesador un ciclo debido a un salto
        output wire o_not_load,
        output wire o_halt,
        output wire o_ctr_reg_src

    );

    assign o_jmp_stop = ( 
            (i_if_id_funct == CODE_FUNCT_JALR || i_if_id_funct == CODE_FUNCT_JR && i_if_id_op == CODE_OP_R_TYPE) || 
            (i_if_id_op == CODE_OP_BNE || i_if_id_op == CODE_OP_BEQ) 
            ) && !i_jump_stop;
    // JARL y JR -> R_TYPE
    // BNE y BEQ -> I_TYPE (Pero no es necesario evaluar porque no estan agrupadas por tipo cono JARL y JR)
    // Evalúa si la instrucción es JARL, JR, BNE o BEQ y si se debe detener el pipeline.

    assign o_not_load = (
            (i_id_ex_rt == i_if_id_rs || i_id_ex_rt == i_if_id_rd) && // Verifica si el registro rt en la etapa ID/EX es igual al registro rs o rd en la etapa IF/ID
            (i_id_ex_op == CODE_OP_LW || i_id_ex_op == CODE_OP_LB || 
            i_id_ex_op == CODE_OP_LBU || i_id_ex_op == CODE_OP_LH || 
            i_id_ex_op == CODE_OP_LHU || i_id_ex_op == CODE_OP_LUI ||
            i_id_ex_op == CODE_OP_LWU) // Verifica si la operación en la etapa ID/EX es una de las operaciones de carga
            ) || o_jmp_stop; // Si se detiene el pipeline por un salto, no se carga el registro.

    // la señal o_not_load se activa si el registro destino de la etapa ID/EX es igual al registro fuente rs o rd de la etapa IF/ID y la operación es de carga.
    // También se activa si se detiene el pipeline por un salto. (Riesgo de control)

    assign o_ctr_reg_src = o_not_load; // Se usa para propagar la señal de control por el pipeline.
    assign o_halt = i_if_id_op == CODE_OP_HALT;




endmodule