module uart_send(
    input i_clk,
    input i_rst,
    input wire [3:0] i_cnt,
    input wire [7:0] i_data,
    output reg  o_txd
);
    
    always @(posedge i_clk) begin
        case (i_cnt)
            4'd1: o_txd <= 1'b0;
            4'd2: o_txd <= i_data[0];
            4'd3: o_txd <= i_data[1];
            4'd4: o_txd <= i_data[2];
            4'd5: o_txd <= i_data[3];
            4'd6: o_txd <= i_data[4];
            4'd7: o_txd <= i_data[5];
            4'd8: o_txd <= i_data[6];
            4'd9: o_txd <= i_data[7];
            default:o_txd <= 1'b1;
        endcase
    end
endmodule
