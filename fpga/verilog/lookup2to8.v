module lookup2to8 (
    input wire [1:0] i_2,
    output reg [7:0] o_8
);

    always @(*) begin
        case (i_2)
            2'd0: o_8 = 8'd0;
            2'd1: o_8 = 8'd85;
            2'd2: o_8 = 8'd170;
            2'd3: o_8 = 8'd255;
            default: o_8 = 8'd0; 
        endcase
    end
endmodule
