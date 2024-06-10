`timescale 1ns / 1ps

module mux
    #(
        parameter CHANNEL_NUM = 2,
        parameter DATA_WIDTH = 32
    )
    (
        input wire [$clog2(CHANNEL_NUM)-1 : 0] selector,
        input wire [CHANNEL_NUM * DATA_WIDTH-1: 0] i_data,
        
        output wire [DATA_WIDTH-1: 0] o_data
    );
    
    reg [DATA_WIDTH-1: 0] data;
    
    integer i;
    always @ (*)
        begin
            data = {DATA_WIDTH{1'bz}};
            for(i = 0; i < CHANNEL_NUM; i = i+1)
                begin
                    if(i == selector)
                        begin
                            data = i_data >> (DATA_WIDTH * i) & {DATA_WIDTH{1'b1}};
                        end
                end
        end
    
    assign o_data = data;
    
endmodule
