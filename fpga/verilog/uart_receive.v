module uart_receive(
    input i_clk,
    input i_rst,
    input wire i_rxd,
    output reg o_new_data,
    output reg [7:0] o_received_char
);
    reg [2:0] r_state;
    reg [3:0] r_bit_count;
    reg [7:0] r_data;
    reg [15:0] r_divisor_counter;

    parameter DELAY = 234;
    parameter HALF_DELAY = 117;

    always @(posedge i_clk) begin
        if (!i_rst) begin
            r_state <= 0;
            r_bit_count <= 4'b0000;
            r_data <= 8'b00000000;
            o_new_data <= 1'b0;
            o_received_char <= 8'b00000000;
            r_divisor_counter <= 16'b0000000000000000;
        end else begin
            case (r_state)
                0: begin
                    if (i_rxd == 1'b0) begin
                        r_state <= 1;
                        r_divisor_counter <= 1;
                        r_data <= 8'b00000000;
                        r_bit_count <= 0;
                        o_new_data <= 0;
                    end
                end 
                1: begin
                    if (r_divisor_counter == HALF_DELAY) begin
                        r_state <= 2;
                        r_divisor_counter <= 1;
                    end else 
                        r_divisor_counter <= r_divisor_counter + 1'b1;
                end
                2: begin
                    r_divisor_counter <= r_divisor_counter + 1'b1;
                    if ((r_divisor_counter + 1) == DELAY) begin
                        r_state <= 3;
                    end
                end
                3: begin
                    r_divisor_counter <= 1;
                    r_data <= {i_rxd, r_data[7:1]};
                    r_bit_count <= r_bit_count + 1'b1;
                    if (r_bit_count == 7)
                        r_state <= 4;
                    else
                        r_state <= 2;
                end
                4: begin
                    r_divisor_counter <= r_divisor_counter + 1'b1;
                    if ((r_divisor_counter + 1) == DELAY) begin
                        r_state <= 5;
                        r_divisor_counter <= 0;
                        o_new_data <= 1'b1;
                    end
                end
                5: begin
                    r_state <= 0;
                    o_received_char <= r_data;
                    o_new_data <= 1'b0;
                end
           endcase
        end
    end
endmodule
