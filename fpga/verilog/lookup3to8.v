module lookup3to8 (
    input wire [2:0] i_3,
    output reg [7:0] o_8
);

    always @(*) begin
        case (i_3)
            3'd0: o_8 = 8'd0;
            3'd1: o_8 = 8'd36;
            3'd2: o_8 = 8'd73;
            3'd3: o_8 = 8'd109;
            3'd4: o_8 = 8'd146;
            3'd5: o_8 = 8'd182;
            3'd6: o_8 = 8'd219;
            3'd7: o_8 = 8'd255;
            default: o_8 = 8'd0; 
        endcase
    end
endmodule
