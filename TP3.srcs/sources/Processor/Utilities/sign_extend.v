`timescale 1ns / 1ps

module sign_extend
    #(
        parameter DATA_ORIGINAL_SIZE  = 16,
        parameter DATA_EXTENDED_SIZE = 32
    )
    (
        input wire [DATA_ORIGINAL_SIZE - 1 : 0] i_value,
        output wire [DATA_EXTENDED_SIZE - 1 : 0] o_extended_value
    );

    assign o_extended_value = {{(DATA_EXTENDED_SIZE - DATA_ORIGINAL_SIZE){i_value[DATA_ORIGINAL_SIZE - 1]}}, i_value};

endmodule

// module SignExtend16to32 (
//     input  wire [15:0] in,
//     output wire [31:0] out
// );
//     assign out = {{16{in[15]}}, in};
// endmodule

// module extend
//     #(
//         parameter DATA_ORIGINAL_SIZE = 16, // Default size of the original data
//         parameter DATA_EXTENDED_SIZE = 32  // Default size of the extended data
//     )
//     (
//         input wire [DATA_ORIGINAL_SIZE - 1 : 0] i_value,        // Input value to be extended
//         input wire signed_extend,  // Control signal: 1 for signed extension, 0 for unsigned extension
//         output wire [DATA_EXTENDED_SIZE - 1 : 0] o_extended_value // Output extended value
//     );

//     // Extend the input value based on the signed_extend control signal
//     assign o_extended_value = signed_extend ? 
//         {{(DATA_EXTENDED_SIZE - DATA_ORIGINAL_SIZE){i_value[DATA_ORIGINAL_SIZE - 1]}}, i_value} : 
//         {{(DATA_EXTENDED_SIZE - DATA_ORIGINAL_SIZE){1'b0}}, i_value};

// endmodule