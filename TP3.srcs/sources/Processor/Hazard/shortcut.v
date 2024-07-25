`timescale 1ns / 1ps

module short_circuit
    #(
        parameter MEM_ADDR_SIZE = 5,

        parameter DATA_SRC_ID_EX = 2'b00, // Fuente de datos en la etapa ID/EX
        parameter DATA_SRC_MEM_WB = 2'b01, // Fuente de datos en la etapa MEM/WB
        parameter DATA_SRC_EX_MEM = 2'b10 // Fuente de datos en la etapa EX/MEM
    )
    (   
        input  wire                         i_ex_mem_wb, // indica si el dato de la etapa EX/MEM es válido
        input  wire                         i_mem_wb_wb, // indica si el dato de la etapa MEM/WB es válido
        input  wire [4 : 0]                 i_id_ex_rs, // Registro fuente A en la etapa ID/EX
        input  wire [4 : 0]                 i_id_ex_rt, // Registro fuente B en la etapa ID/EX
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_ex_mem_addr, // Dirección de la etapa EX/MEM
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_mem_wb_addr, // Dirección de la etapa MEM/WB
        output wire [1 : 0]                 o_sc_data_a_src, // Fuente de datos A
        output wire [1 : 0]                 o_sc_data_b_src // Fuente de datos B
    );

    assign o_sc_data_a_src = i_ex_mem_addr == i_id_ex_rs && i_id_ex_rs != 0 && i_ex_mem_wb  ? DATA_SRC_EX_MEM : 
                             i_mem_wb_addr == i_id_ex_rs && i_id_ex_rs != 0 && i_mem_wb_wb  ? DATA_SRC_MEM_WB : 
                                                                                              DATA_SRC_ID_EX;
    // Si la dirección de la etapa EX/MEM es igual a la dirección de la etapa ID/EX y la dirección de la etapa ID/EX es distinta de 0 y la señal de escritura en la etapa EX/MEM está activa, entonces la fuente de datos A es la etapa EX/MEM.
    // Aplica para los registros fuente A y B.

    assign o_sc_data_b_src = i_ex_mem_addr == i_id_ex_rt && i_id_ex_rt != 0 && i_ex_mem_wb  ? DATA_SRC_EX_MEM :
                             i_mem_wb_addr == i_id_ex_rt && i_id_ex_rt != 0 && i_mem_wb_wb  ? DATA_SRC_MEM_WB :
                                                                                              DATA_SRC_ID_EX;
    

endmodule