timescale 1ns / 1ps

module ctrl_unit
    #(
        // OPCODE parameters
        parameter CODE_OPP_R_TYPE = 6'b000000, 
        parameter CODE_OPP_LW     = 6'b100011,
        parameter CODE_OPP_SW     = 6'b101011,
        parameter CODE_OPP_BEQ    = 6'b000100,
        parameter CODE_OPP_BNE    = 6'b000101,
        parameter CODE_OPP_ADDI   = 6'b001000,
        parameter CODE_OPP_J      = 6'b000010,
        parameter CODE_OPP_JAL    = 6'b000011,
        parameter CODE_OPP_ANDI   = 6'b001100,
        parameter CODE_OPP_ORI    = 6'b001101,
        parameter CODE_OPP_XORI   = 6'b001110,
        parameter CODE_OPP_SLTI   = 6'b001010,
        parameter CODE_OPP_LUI    = 6'b001111,
        parameter CODE_OPP_LB     = 6'b100000,
        parameter CODE_OPP_LBU    = 6'b100100,
        parameter CODE_OPP_LH     = 6'b100001,
        parameter CODE_OPP_LHU    = 6'b100101,
        parameter CODE_OPP_LWU    = 6'b100111,
        parameter CODE_OPP_SB     = 6'b101000,
        parameter CODE_OPP_SH     = 6'b101001,
        
        // FUNCT parameters
        parameter CODE_FUNCT_JR   = 6'b001000,
        parameter CODE_FUNCT_JALR = 6'b001001,
        parameter CODE_FUNCT_SLL  = 6'b000000,
        parameter CODE_FUNCT_SRL  = 6'b000010,
        parameter CODE_FUNCT_SRA  = 6'b000011,

        // Control parameters
        parameter CODE_CTRL_NEXT_PC_SRC_SEQ = 1'b0  , // Sequential
        parameter CODE_CTRL_NEXT_PC_SRC_NOT_SEQ = 1'b1  , // Not sequential
        parameter CODE_CTRL_NOT_JMP = 2'bxx , // Not jump
        parameter CODE_CTRL_JMP_DIR = 2'b10 , // Jump direct
        parameter CODE_CTRL_JMP_REG = 2'b01 , // Jump register
        parameter CODE_CTRL_JMP_BRANCH = 2'b00 , // Jump branch
        parameter CODE_CTRL_REG_DST_RD = 2'b01 , // Register destination is rd
        parameter CODE_CTRL_REG_DST_GPR_31 = 2'b10 , // Register destination is gpr[31]
        parameter CODE_CTRL_REG_DST_RT = 2'b00 , // Register destination is rt
        parameter CODE_CTRL_REG_DST_NOTHING = 2'bxx , // Register destination is nothing
        parameter CODE_CTRL_MEM_WR_SRC_WORD = 2'b00 , // Memory write source is word
        parameter CODE_CTRL_MEM_WR_SRC_HALFWORD = 2'b01 , // Memory write source is halfword
        parameter CODE_CTRL_MEM_WR_SRC_BYTE = 2'b10 , // Memory write source is byte
        parameter CODE_CTRL_MEM_WR_SRC_NOTHING = 2'bxx , // Memory write source is nothing
        parameter CODE_CTRL_MEM_RD_SRC_WORD = 3'b000, // Memory read source is word
        parameter CODE_CTRL_MEM_RD_SRC_SIG_HALFWORD = 3'b001, // Memory read source is signed halfword
        parameter CODE_CTRL_MEM_RD_SRC_SIG_BYTE = 3'b010, // Memory read source is signed byte
        parameter CODE_CTRL_MEM_RD_SRC_USIG_HALFWORD = 3'b011, // Memory read source is unsigned halfword
        parameter CODE_CTRL_MEM_RD_SRC_USIG_BYTE = 3'b100, // Memory read source is unsigned byte
        parameter CODE_CTRL_MEM_RD_SRC_NOTHING = 3'bxxx, // Memory read source is nothing
        parameter CODE_CTRL_MEM_WRITE_ENABLE = 1'b1  , // Enable memory write
        parameter CODE_CTRL_MEM_WRITE_DISABLE = 1'b0  , // Disable memory write
        parameter CODE_CTRL_WB_ENABLE = 1'b1  , // Enable register write back
        parameter CODE_CTRL_WB_DISABLE = 1'b0  , // Disable register write back
        parameter CODE_CTRL_MEM_TO_REG_MEM_RESULT = 1'b0  , // Memory result to register
        parameter CODE_CTRL_MEM_TO_REG_ALU_RESULT = 1'b1  , // ALU result to register
        parameter CODE_CTRL_MEM_TO_REG_NOTHING = 1'bx  , // Nothing to register

        // ALU control parameters
        parameter CODE_ALU_CTRL_LOAD_TYPE = 3'b000, // Load instructions
        parameter CODE_ALU_CTRL_STORE_TYPE = 3'b000, // Store instructions
        parameter CODE_ALU_CTRL_ADDI = 3'b000, // Add immediate instruction
        parameter CODE_ALU_CTRL_BRANCH_TYPE = 3'b001, // Branch instructions
        parameter CODE_ALU_CTRL_ANDI = 3'b010, // And immediate instruction
        parameter CODE_ALU_CTRL_ORI = 3'b011, // Or immediate instruction
        parameter CODE_ALU_CTRL_XORI = 3'b100, // Xor immediate instruction
        parameter CODE_ALU_CTRL_SLTI = 3'b101, // Set less than immediate instruction
        parameter CODE_ALU_CTRL_R_TYPE = 3'b110, // R-Type instructions
        parameter CODE_ALU_CTRL_JUMP_TYPE = 3'b111, // Jump instructions
        parameter CODE_ALU_CTRL_UNDEFINED = 3'bxxx, // Undefined instruction

        parameter CODE_ALU_CTRL_SRC_A_SHAMT = 1'b0 , // Shamt
        parameter CODE_ALU_CTRL_SRC_A_BUS_A = 1'b1 , // Bus A
        parameter CODE_ALU_CTRL_SRC_A_NOTHING = 1'bx, // Nothing
        
        parameter CODE_ALU_CTRL_SRC_B_NEXT_SEQ_PC = 3'b000 , // Next sequential PC
        parameter CODE_ALU_CTRL_SRC_B_UPPER_INM = 3'b001 , // Upper immediate
        parameter CODE_ALU_CTRL_SRC_B_SIG_INM = 3'b010 , // Sign immediate
        parameter CODE_ALU_CTRL_SRC_B_USIG_INM = 3'b011 , // Unsigned immediate
        parameter CODE_ALU_CTRL_SRC_B_BUS_B = 3'b100 , // Bus B
        parameter CODE_ALU_CTRL_SRC_B_NOTHING = 3'bxxx // Nothing
    )
    (
        input  wire          i_bus_a_not_equal_bus_b,
        input  wire          i_instruction_is_nop,
        input  wire [5 : 0]  i_op,
        input  wire [5 : 0]  i_funct,
        output wire [19 : 0] o_ctrl_regs
    );
    
    /* Instruction register:
    instruction[19] : next_pc_src
    instruction[18:b17] : jmp_ctrl
    instruction[b16:b15] : reg_dst
    instruction[b14] : alu_src_A
    instruction[b13:b11] : alu_src_B
    instruction[b10:b8] : alu_opp
    instruction[b7:b5] : mem_read_source
    instruction[b4:b3] : mem_write_source
    instruction[b2] : mem_write
    instruction[b1] : wb
    instruction[b0] : mem_to_reg
    */

    reg [19 : 0] ctrl_regs; 

    always @(*) 
    begin
        if (!i_instruction_is_nop)
            case (i_op)
                CODE_OPP_R_TYPE :
                    case (i_funct)
                        CODE_FUNCT_JR    : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_NOT_SEQ, CODE_CTRL_JMP_REG, CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_NOTHING, CODE_ALU_CTRL_SRC_B_NOTHING,     CODE_ALU_CTRL_R_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING, CODE_CTRL_MEM_WR_SRC_NOTHING, CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
                        CODE_FUNCT_JALR  : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_NOT_SEQ, CODE_CTRL_JMP_REG, CODE_CTRL_REG_DST_GPR_31,  CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_NEXT_SEQ_PC, CODE_ALU_CTRL_R_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING, CODE_CTRL_MEM_WR_SRC_NOTHING, CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                        CODE_FUNCT_SLL   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,     CODE_CTRL_NOT_JMP, CODE_CTRL_REG_DST_RD,      CODE_ALU_CTRL_SRC_A_SHAMT,   CODE_ALU_CTRL_SRC_B_BUS_B,       CODE_ALU_CTRL_R_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING, CODE_CTRL_MEM_WR_SRC_NOTHING, CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                        CODE_FUNCT_SRL   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,     CODE_CTRL_NOT_JMP, CODE_CTRL_REG_DST_RD,      CODE_ALU_CTRL_SRC_A_SHAMT,   CODE_ALU_CTRL_SRC_B_BUS_B,       CODE_ALU_CTRL_R_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING, CODE_CTRL_MEM_WR_SRC_NOTHING, CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                        CODE_FUNCT_SRA   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,     CODE_CTRL_NOT_JMP, CODE_CTRL_REG_DST_RD,      CODE_ALU_CTRL_SRC_A_SHAMT,   CODE_ALU_CTRL_SRC_B_BUS_B,       CODE_ALU_CTRL_R_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING, CODE_CTRL_MEM_WR_SRC_NOTHING, CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                        default           : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,    CODE_CTRL_NOT_JMP, CODE_CTRL_REG_DST_RD,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_BUS_B,       CODE_ALU_CTRL_R_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING, CODE_CTRL_MEM_WR_SRC_NOTHING, CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                    endcase
                CODE_OPP_LW   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_LOAD_TYPE,   CODE_CTRL_MEM_RD_SRC_WORD,          CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_MEM_RESULT };
                CODE_OPP_SW   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_STORE_TYPE,  CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_WORD,     CODE_CTRL_MEM_WRITE_ENABLE,  CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
                CODE_OPP_BEQ  : ctrl_regs = { !i_bus_a_not_equal_bus_b ? { CODE_CTRL_NEXT_PC_SRC_NOT_SEQ, CODE_CTRL_JMP_BRANCH } : { CODE_CTRL_NEXT_PC_SRC_SEQ, CODE_CTRL_NOT_JMP }, CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_NOTHING, CODE_ALU_CTRL_SRC_B_NOTHING,     CODE_ALU_CTRL_BRANCH_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
                CODE_OPP_BNE  : ctrl_regs = {  i_bus_a_not_equal_bus_b ? { CODE_CTRL_NEXT_PC_SRC_NOT_SEQ, CODE_CTRL_JMP_BRANCH } : { CODE_CTRL_NEXT_PC_SRC_SEQ, CODE_CTRL_NOT_JMP }, CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_NOTHING, CODE_ALU_CTRL_SRC_B_NOTHING,     CODE_ALU_CTRL_BRANCH_TYPE, CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
                CODE_OPP_ADDI : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_ADDI,        CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                CODE_OPP_J    : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_NOT_SEQ,  CODE_CTRL_JMP_DIR,    CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_NOTHING, CODE_ALU_CTRL_SRC_B_NOTHING,     CODE_ALU_CTRL_JUMP_TYPE,   CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
                CODE_OPP_JAL  : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_NOT_SEQ,  CODE_CTRL_JMP_DIR,    CODE_CTRL_REG_DST_GPR_31,  CODE_ALU_CTRL_SRC_A_NOTHING, CODE_ALU_CTRL_SRC_B_NEXT_SEQ_PC, CODE_ALU_CTRL_JUMP_TYPE,   CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                CODE_OPP_ANDI : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_USIG_INM,    CODE_ALU_CTRL_ANDI,        CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                CODE_OPP_ORI  : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_USIG_INM,    CODE_ALU_CTRL_ORI,         CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                CODE_OPP_XORI : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_USIG_INM,    CODE_ALU_CTRL_XORI,        CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                CODE_OPP_SLTI : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_SLTI,        CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                CODE_OPP_LUI  : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_UPPER_INM,   CODE_ALU_CTRL_LOAD_TYPE,   CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_ALU_RESULT };
                CODE_OPP_LB   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_LOAD_TYPE,   CODE_CTRL_MEM_RD_SRC_SIG_BYTE,      CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_MEM_RESULT };
                CODE_OPP_LBU  : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_LOAD_TYPE,   CODE_CTRL_MEM_RD_SRC_USIG_BYTE,     CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_MEM_RESULT };
                CODE_OPP_LH   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_LOAD_TYPE,   CODE_CTRL_MEM_RD_SRC_SIG_HALFWORD,  CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_MEM_RESULT };
                CODE_OPP_LHU  : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_LOAD_TYPE,   CODE_CTRL_MEM_RD_SRC_USIG_HALFWORD, CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_MEM_RESULT };
                CODE_OPP_LWU  : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_RT,      CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_LOAD_TYPE,   CODE_CTRL_MEM_RD_SRC_WORD,          CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_ENABLE,  CODE_CTRL_MEM_TO_REG_MEM_RESULT };
                CODE_OPP_SB   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_STORE_TYPE,  CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_BYTE,     CODE_CTRL_MEM_WRITE_ENABLE,  CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
                CODE_OPP_SH   : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_BUS_A,   CODE_ALU_CTRL_SRC_B_SIG_INM,     CODE_ALU_CTRL_STORE_TYPE,  CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_HALFWORD, CODE_CTRL_MEM_WRITE_ENABLE,  CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
                default       : ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ,      CODE_CTRL_NOT_JMP,    CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_NOTHING, CODE_ALU_CTRL_SRC_B_NOTHING,     CODE_ALU_CTRL_UNDEFINED ,  CODE_CTRL_MEM_RD_SRC_NOTHING,       CODE_CTRL_MEM_WR_SRC_NOTHING,  CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING    };
            endcase
        else
            ctrl_regs = { CODE_CTRL_NEXT_PC_SRC_SEQ, CODE_CTRL_NOT_JMP, CODE_CTRL_REG_DST_NOTHING, CODE_ALU_CTRL_SRC_A_NOTHING, CODE_ALU_CTRL_SRC_B_NOTHING, CODE_ALU_CTRL_UNDEFINED, CODE_CTRL_MEM_RD_SRC_NOTHING, CODE_CTRL_MEM_WR_SRC_NOTHING, CODE_CTRL_MEM_WRITE_DISABLE, CODE_CTRL_WB_DISABLE, CODE_CTRL_MEM_TO_REG_NOTHING };
    end

    assign o_ctrl_regs = ctrl_regs;

endmodule