
module MEM_Unit
    #(
        parameter BUS_WIDTH = 32,
        parameter ADDRESS_WIDTH = 5
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_flush,
        input wire i_wr_rd, // 0: read, 1: write
        input wire [1:0] i_wr_src, // 
        input wire [2:0] i_rd_src, //
        input wire [ADDRESS_WIDTH-1:0] i_mem_address,
        input wire [BUS_WIDTH-1:0] i_data_b,
        output wire [BUS_WIDTH-1:0] o_mem_rd,
        output wire [2**ADDRESS_WIDTH * BUS_WIDTH - 1 : 0] o_bus_debug

    );

    localparam BYTE_WIDTH = 8;
    localparam HALFWORD_WIDTH = 16;

    // Buses de datos en bytes y halfwords de entrada

    wire [BYTE_WIDTH-1:0] data_b_byte; // dato del bus b en formato byte (8 bits)
    wire [HALFWORD_WIDTH:0] data_b_halfword; // dato del bus b en formato halfword (16 bits)
    wire [BUS_WIDTH-1:0] data_b_unsig_ext_byte; // dato del bus b en formato byte con extension de signo a word (de 8 a u32 bits)
    wire [BUS_WIDTH:0] data_b_unsig_ext_halfword; // dato del bus b en formato halfword con extension de signo a word (de 16 a u32 bits)

    // Buses de datos en bytes y halfwords de salida (u: unsigned, s: signed)

    wire [BYTE_WIDTH-1:0] out_data_byte; // dato de salida en formato byte (8 bits)
    wire [HALFWORD_WIDTH:0] out_data_halfword; // dato de salida en formato halfword (16 bits)
    wire [BUS_WIDTH-1:0] out_data_unsig_ext_byte; // dato de salida en formato byte con extension de signo a word (u32 bits)
    wire [BUS_WIDTH-1:0] out_data_unsig_ext_halfword; // dato de salida en formato halfword con extension de signo a word (u32 bits)
    wire [BUS_WIDTH-1:0] out_data_sig_ext_byte; // dato de salida con extension de signo en formato byte a word (s32 bits)
    wire [BUS_WIDTH-1:0] out_data_sig_ext_halfword; // dato de salida con extension de signo en formato halfword a word (s32 bits)

    wire [BUS_WIDTH-1:0] mem_data_in; // dato de entrada a la memoria (word)
    wire [BUS_WIDTH-1:0] mem_data_out; // dato de salida de la memoria (word)

    // Asignacion de los buses de datos en bytes y halfwords de entrada y salida

    assign data_b_byte = i_data_b[BYTE_WIDTH-1:0]; // Extrae el byte de i_data_b
    assign data_b_halfword = i_data_b[HALFWORD_WIDTH:0]; // Extrae el halfword de i_data_b

    assign out_data_byte = mem_data_out[BYTE_WIDTH-1:0]; // byte de mem_data_out
    assign out_data_halfword = mem_data_out[HALFWORD_WIDTH:0]; // halfword de mem_data_out


    // Unidad de memoria de datos
    Data_Memory
    #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .MEM_SLOT_WIDTH(BUS_WIDTH)
    )
    data_mem_unit
    (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_flush(i_flush),
        .i_wr_rd(i_wr_rd),
        .i_address(i_mem_address),
        .i_data(mem_data_in),
        .o_data(mem_data_out),
        .o_bus_debug (o_bus_debug)
    );

// ------------------------------- Selectores -------------------------------

    // Selector de fuente de lectura
    mux
    #(
        .CHANNELS(3),
        .BUS_SIZE(BUS_WIDTH)
    )
    mux_rd_src
    (
        .selector(i_rd_src),
        .data_in({data_b_unsig_ext_byte, data_b_unsig_ext_halfword, i_data_b}),
        .data_out(mem_data_in)
    ); // Selecciona la fuente de lectura: byte, halfword o word.


    // Selector de formato de salida (lectura de memoria)
    mux
    #(
        .CHANNELS(5),
        .BUS_SIZE(BUS_WIDTH)
    )
    mux_out_mem
    (
        .selector(i_rd_src),
        .data_in({out_data_unsig_ext_byte, out_data_unsig_ext_halfword, out_data_sig_ext_byte, out_data_sig_ext_byte, mem_data_out}),
        .data_out(o_mem_rd)
    ); // Selecciona el formato: byte sin signo extendido, halfword sin signo extendido, byte con signo extendido, halfword con signo extendido o word.

// ------------------------------------------------------------------------------------



// ------------------------------- Extensores sin signo -------------------------------
extend
#(
    .DATA_ORIGINAL_SIZE(HALFWORD_WIDTH),
    .DATA_EXTENDED_SIZE(BUS_WIDTH)
)
unsig_ext_data_b_halfword_u // Extensor sin signo de halfword a word (entrada de la memoria)
(
    .i_value(data_b_halfword),
    .i_is_signed(1'b0),
    .o_extended_value(data_b_unsig_ext_halfword)
);

extend
#(
    .DATA_ORIGINAL_SIZE(BYTE_WIDTH),
    .DATA_EXTENDED_SIZE(BUS_WIDTH)
)
unsig_ext_data_b_byte_u // Extensor sin signo de byte a word (entrada de la memoria)
(
    .i_value(data_b_byte),
    .i_is_signed(1'b0),
    .o_extended_value(data_b_unsig_ext_byte)
);

extend
#(
    .DATA_ORIGINAL_SIZE(HALFWORD_WIDTH),
    .DATA_EXTENDED_SIZE(BUS_WIDTH)
)
unsig_ext_out_data_halfword_u // Extensor sin signo de halfword a word (salida de la memoria)
(
    .i_value(out_data_halfword),
    .i_is_signed(1'b0),
    .o_extended_value(out_data_unsig_ext_halfword)
);

extend
#(
    .DATA_ORIGINAL_SIZE(BYTE_WIDTH),
    .DATA_EXTENDED_SIZE(BUS_WIDTH)
)
unsig_ext_out_data_byte_u // Extensor sin signo de byte a word (salida de la memoria)
(
    .i_value(out_data_byte),
    .i_is_signed(1'b0),
    .o_extended_value(out_data_unsig_ext_byte)
);

// ------------------------------------------------------------------------------------

// ------------------------------- Extensores con signo -------------------------------
extend
#(
    .DATA_ORIGINAL_SIZE(HALFWORD_WIDTH),
    .DATA_EXTENDED_SIZE(BUS_WIDTH)
)
sig_ext_out_data_halfword_u // Extensor con signo de halfword a word (salida de la memoria)
(
    .i_value(out_data_halfword),
    .i_is_signed(1'b1),
    .o_extended_value(out_data_sig_ext_halfword)
);

extend
#(
    .DATA_ORIGINAL_SIZE(BYTE_WIDTH),
    .DATA_EXTENDED_SIZE(BUS_WIDTH)
)
sig_ext_out_data_byte_u // Extensor con signo de byte a word (salida de la memoria)
(
    .i_value(out_data_byte),
    .i_is_signed(1'b1),
    .o_extended_value(out_data_sig_ext_byte)
);
// ------------------------------------------------------------------------------------

endmodule
