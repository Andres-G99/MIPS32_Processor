`timescale 1ns / 1ps

/*
Se implementa la etapa de decodificación de instrucciones (ID: Instruction Decode),
manejando las señales de control y datos necesarios para la ejecución de las instrucciones
*/

module id
    #(
        parameter REGISTER_BANK_SIZE = 32,
        parameter PC_SIZE = 32,
        parameter BUS_SIZE = 32
    )
    (
        /* input controls wires */
        input wire i_clk, // señal de clock
        input wire i_reset, // señal de reset
        input wire i_flush, // señal para vaciar
        input wire i_write_enable, // señal de escritura
        input wire i_ctrl_reg_source, // señal para seleccionar la fuente de los registros
        /* input data wires */
        input wire [$clog2(REGISTER_BANK_SIZE) - 1 : 0] i_reg_write_addr, // dirección en el banco de registros donde se va a escribir el dato
        input wire [BUS_SIZE - 1 : 0] i_reg_write_bus, // datos que se escribirán en el banco
        input wire [BUS_SIZE - 1 : 0] i_instruction, // instrucción que se está decodificando
        input wire [BUS_SIZE - 1 : 0] i_ex_data_A, // dato A de la etapa EX
        input wire [BUS_SIZE - 1 : 0] i_ex_data_B, // dato B de la etapa EX
        input wire [PC_SIZE - 1 : 0] i_next_seq_pc, // dirección de la próxima instrucción secuencial
        /* output control wires */
        output wire o_next_pc_source, // fuente del próximo PC. Puede tener dos valores: 1 para una secuencia normal (incremento secuencial del PC) y 0 para una fuente externa, como una instrucción de salto.
        output wire [2 : 0] o_mem_read_source, // fuente del dato a leer desde la memoria.
        output wire [1 : 0] o_mem_write_source, // fuente del dato a escribir en la memoria
        output wire o_mem_write, // señal para escribir en la memoria
        output wire o_wb, // señal para write-back
        output wire o_mem_to_reg, // indica si el dato que se lee desde la memoria debe ser transferido al banco de registros
        output wire [1 : 0] o_reg_dst, // destino del dato en el banco de registros.
        output wire o_alu_source_A, // indica si el primer operando de la ALU debe provenir de la etapa de ejecución (1) o del banco de registros (0)
        output wire [2 : 0] o_alu_source_B, // indica la fuente del segundo operando de la ALU.
        output wire [2 : 0] o_alu_opp, // operación que realizará la ALU
        /* output data wires */
        output wire [BUS_SIZE - 1 : 0] o_bus_A, // valor en el bus A que se enviará a la siguiente etapa del pipeline
        output wire [BUS_SIZE - 1 : 0] o_bus_B, // valor en el bus B que se enviará a la siguiente etapa del pipeline
        output wire [PC_SIZE - 1 : 0] o_next_not_seq_pc, // dirección de la próxima instrucción no secuencial
        output wire [4 : 0] o_rs, // registro fuente RS
        output wire [4 : 0] o_rt, // registro fuente RT
        output wire [4 : 0] o_rd, // registro destino RD
        output wire [5 : 0] o_funct, // función de la instrucción
        output wire [5 : 0] o_op, // operación de la instrucción
        output wire [BUS_SIZE - 1 : 0] o_shamt_ext_unsigned, // shamt extendido sin signo
        output wire [BUS_SIZE - 1 : 0] o_inm_ext_signed, // inmediato extendido con signo
        output wire [BUS_SIZE - 1 : 0] o_inm_upp, // inmediato extendido con ceros en los bits menos significativos
        output wire [BUS_SIZE - 1 : 0] o_inm_ext_unsigned, // inmediato extendido sin signo
        /* debug wires */
        output wire [REGISTER_BANK_SIZE * BUS_SIZE - 1 : 0] o_bus_debug
    );

    /* Internal wires */
    wire is_not_equal_result; // señal para saber si dos valores son diferentes
    wire is_nop_result; // señal para saber si la instrucción es un NOP
    wire [1 : 0] jmp_ctrl; // control para saber si la instrucción es de salto
    wire [19 : 0] ctrl_register; // registros de control de la etapa ID
    wire [16 : 0] next_stage_ctrl_register; // registros de control de la siguiente etapa
    wire [BUS_SIZE - 1 : 0] inm_ext_signed_shifted; // inmediato extendido con signo y desplazado
    wire [BUS_SIZE - 1 : 0] dir_ext_unsigned; // dirección extendida sin signo
    wire [BUS_SIZE - 1 : 0] dir_ext_unsigned_shifted; // dirección extendida sin signo y desplazada

    wire [4 : 0] shamt; // shamt de la instrucción
    wire [15 : 0] inm; // inmediato de la instrucción
    wire [25 : 0] dir; // dirección de la instrucción
    wire [BUS_SIZE - 1 : 0] branch_pc_dir; // dirección de la próxima instrucción en caso de salto condicional
    wire [BUS_SIZE - 1 : 0] jump_pc_dir; // dirección de la próxima instrucción en caso de salto no condicional
    
    /* Assignment internal wires */
    assign shamt = i_instruction[10:6];
    assign inm = i_instruction[15:0];
    assign dir = i_instruction[25:0];
    assign jmp_ctrl = ctrl_register[18:17]; // control para saber si la instrucción es de salto
    assign jump_pc_dir = { i_next_seq_pc[31:28], dir_ext_unsigned_shifted[27:0] }; // calcular la dirección de salto

    /* Assignment output wires */
    assign o_op = i_instruction[31:26];
    assign o_rs = i_instruction[25:21];
    assign o_rt = i_instruction[20:16];
    assign o_rd = i_instruction[15:11];
    assign o_funct = i_instruction[5:0];

    assign o_next_pc_source = ctrl_register[19];
    assign o_reg_dst = next_stage_ctrl_register[16:15];
    assign o_alu_source_A = next_stage_ctrl_register[14];
    assign o_alu_source_B = next_stage_ctrl_register[13:11];
    assign o_alu_opp = next_stage_ctrl_register[10:8];
    assign o_mem_read_source = next_stage_ctrl_register[7:5];
    assign o_mem_write_source = next_stage_ctrl_register[4:3];
    assign o_mem_write = next_stage_ctrl_register[2];
    assign o_wb = next_stage_ctrl_register[1];
    assign o_mem_to_reg = next_stage_ctrl_register[0];

    /* Register Bank */
    registers 
    #(
        .REGISTERS_BANK_SIZE (REGISTER_BANK_SIZE),
        .REGISTERS_SIZE      (BUS_SIZE)
    ) 
    registers_unit 
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_flush        (i_flush),
        .i_write_enable (i_write_enable),
        .i_addr_A       (o_rs),
        .i_addr_B       (o_rt),
        .i_addr_wr      (i_reg_write_addr),
        .i_bus_wr       (i_reg_write_bus),
        .o_bus_A        (o_bus_A),
        .o_bus_B        (o_bus_B),
        .o_bus_debug    (o_bus_debug)
    );

    /* Control: generar señales de control necesarias */
    ctrl_register ctrl_register_unit 
    (
        .i_bus_A_diff_bus_B (is_not_equal_result),
        .i_instr_nop        (is_nop_result),
        .i_opp              (o_op),
        .i_funct            (o_funct),
        .o_ctrl_register    (ctrl_registers)
    );

    /* Multiplexor para seleccionar el siguiente registro de control de la etapa */
    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(17)
    ) 
    mux_ctr_regs_unit 
    (
        .selector (i_ctrl_reg_source),
        .data_in  ({17'b0, ctrl_register[16:0]}),
        .data_out (next_stage_ctrl_register)
    );

    /* Multiplexor para seleccionar el siguiente PC */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_jump_src_unit 
    (
        .selector (jmp_ctrl),
        .data_in  ({jump_pc_dir, i_ex_data_A, branch_pc_dir}),
        .data_out (o_next_not_seq_pc)
    );

    /* Extend unsigned for DIR */
    unsig_extend 
    #(
        .REG_IN_SIZE  (26), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    unsig_extend_dir_unit  
    (
        .i_reg (dir),
        .o_reg (dir_ext_unsigned)
    );

    /* Extend unsigned for SHAMT */
    unsig_extend 
    #(
        .REG_IN_SIZE  (5), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    unsig_extend_shamt_unit  
    (
        .i_reg (shamt),
        .o_reg (o_shamt_ext_unsigned)
    );

    /* Extend signed for INM */
    sig_extend 
    #(
        .REG_IN_SIZE  (16), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    sig_extend_inm_unit  
    (
        .i_reg (inm),
        .o_reg (o_inm_ext_signed)
    );
    
    /* Extend unsigned for INM */
    unsig_extend 
    #(
        .REG_IN_SIZE  (16), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    unsig_extend_inm_unit 
    (
        .i_reg (inm),
        .o_reg (o_inm_ext_unsigned)
    );    

    /* Verificar A igual a B */
    is_not_equal 
    #(
        .BUS_SIZE (BUS_SIZE)
    )
    is_not_equal_unit 
    (
        .in_a         (i_ex_data_A),
        .in_b         (i_ex_data_B),
        .is_not_equal (is_not_equal_result)
    );

    /* Verificar instruccion NOP */
    is_zero 
    #(
        .BUS_SIZE (BUS_SIZE)
    )
    is_nop_unit 
    (
        .in      (i_instruction),
        .is_zero (is_nop_result)
    );


    /* Shift left 2 for extended signed INM */
    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (2)
    ) 
    shift_left_ext_inm_signed_unit  
    (
        .in  (o_inm_ext_signed),
        .out (inm_ext_signed_shifted)
    );


    /* Shift left 2 for DIR */
    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (2)
    ) 
    shift_left_dir_unit 
    (
        .in  (dir_ext_unsigned),
        .out (dir_ext_unsigned_shifted)
    );


    /* Shift left 16 for INM */
    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (16)
    ) 
    shift_left_inm_unit 
    (
        .in  (o_inm_ext_unsigned),
        .out (o_inm_upp)
    );

    /* Calcular next branch PC */
    adder 
    #
    (
        .BUS_SIZE (BUS_SIZE)
    ) 
    adder_unit 
    (
        .a   (i_next_seq_pc),
        .b   (inm_ext_signed_shifted),
        .sum (branch_pc_dir)
    );

endmodule