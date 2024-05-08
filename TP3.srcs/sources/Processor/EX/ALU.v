

module ALU
  #(
    //parameters
    parameter IO_WIDTH = 32, // ancho de los datos
    parameter OP_WIDTH = 6, // ancho de los códigos de operación
    
    //OPCODE parameters
    parameter SLL  = 6'b000001,
    parameter SRL  = 6'b000010,
    parameter SRA  = 6'b000011,
    parameter SLLV = 6'b000100,
    parameter SRLV = 6'b000101,
    parameter SRAV = 6'b000110,
    parameter ADDU = 6'b000111,
    parameter SUBU = 6'b001000,
    parameter AND  = 6'b001001,
    parameter OR   = 6'b001010,
    parameter XOR  = 6'b001011,
    parameter NOR  = 6'b001100,
    parameter SLT  = 6'b001101,
    parameter ADD  = 6'b001110,
    parameter SUB  = 6'b001111
    )
   (
    input [IO_WIDTH-1:0] i_op_a, // operando A
    input [IO_WIDTH-1:0] i_op_b, // operando B
    input [IO_WIDTH-1:0] i_opcode, // código de operación
    output [IO_WIDTH-1:0] o_data // dato de salida
    );
    
    reg[IO_WIDTH-1:0] res; // buffer de resultado
    
    always@(*)
    begin
        case(i_opcode)
            SLL : res = i_op_b << i_op_a;
            SRL : res = i_op_b >> i_op_a;
            SRA : res = $signed(i_op_b) >>> i_op_a;
            SLLV : res = i_op_a << i_op_b;
            SRLV : res = i_op_a >> i_op_b;
            SRAV : res = $signed(i_op_a) >>> i_op_b;
            ADDU : res = i_op_a + i_op_b;
            SUBU : res = i_op_a - i_op_b;
            AND : res = i_op_a & i_op_b;
            OR : res = i_op_a | i_op_b;
            XOR : res = i_op_a ^ i_op_b;
            NOR : res = ~(i_op_a | i_op_b);
            SLT : res = $signed(i_op_a) < $signed(i_op_b);
            ADD : res = $signed(i_op_a) + $signed(i_op_b);
            SUB : res = $signed(i_op_a) - $signed(i_op_b);
            default : res = {IO_WIDTH{1'bz}};
        endcase
    end 
    
    assign o_data = res;
    
endmodule
