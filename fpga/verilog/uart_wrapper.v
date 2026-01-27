module uart_wrapper (
    input  wire i_clk,
    input  wire i_rst,
    input  wire i_rxd,
    output wire o_txd,
    output wire o_wr_en,
    output wire [17:0] o_wr_addr,
    output wire [7:0] o_wr_data,
    output wire o_receive_done
);
    wire [7:0] w_rx_data;
    wire w_rx_flag;

    reg  [3:0] r_tx_cnt;
    wire w_uart_en;

    reg        r_wr_en;
    reg        r_rd_en;
    reg [17:0] r_wr_addr;
    reg [7:0] r_rd_data;
    reg [7:0]  r_wr_data;
    wire [7:0] w_rd_data;
    reg r_received_done;

    assign o_wr_en = r_wr_en;
    assign o_wr_addr = r_wr_addr;
    assign o_wr_data = w_rx_data;
    assign o_receive_done = r_received_done;

    assign w_rd_data = r_rd_data;

    reg [1:0] r_state;
    reg [17:0] r_recv_count;
    reg [17:0] r_send_index;

    uart_receive uart_receive (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_rxd(i_rxd),
        .o_new_data(w_rx_flag),
        .o_received_char(w_rx_data)
    );

    uart_send uart_send (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_cnt(r_tx_cnt),
        .i_data(8'hFF),
        .o_txd(o_txd)
    );

    reg [8:0] r_cnt9;
    assign w_uart_en = (r_cnt9 == 9'd234);

    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst)
            r_cnt9 <= 9'd0;
        else if (r_cnt9 == 9'd234)
            r_cnt9 <= 9'd0;
        else
            r_cnt9 <= r_cnt9 + 9'd1;
    end

    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst)
            r_tx_cnt <= 4'd0;
        else if (r_rd_en)
            r_tx_cnt <= 4'd0;
        else if (w_uart_en && r_tx_cnt != 4'd10)
            r_tx_cnt <= r_tx_cnt + 4'd1;
    end

    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            r_wr_en <= 1'b0;
            r_rd_en <= 1'b0;
            r_wr_addr <= 18'd0;
            r_rd_data <= 8'd0;
            r_wr_data <= 8'd0;
            r_state <= 2'd0;
            r_recv_count <= 18'd0;
            r_send_index <= 18'd0;
            r_received_done <= 1'b0;
        end else begin
            r_wr_en <= 1'b0;
            r_rd_en <= 1'b0;

            case (r_state)
                2'd0: begin
                    if (w_rx_flag) begin
                        if (w_rx_data == 8'h41) begin
                            r_send_index <= 18'd0;
                            r_rd_data <= 8'd0;
                            r_state <= 2'd1;
                            r_received_done <= 1'b1;
                        end else begin
                            r_wr_en   <= 1'b1;
                            r_wr_data <= w_rx_data;
                            r_wr_addr <= r_recv_count;
                            r_recv_count <= r_recv_count + 18'd1;
                        end
                    end
                end
                2'd1: begin
                    r_received_done <= 1'b0;
                    if (r_tx_cnt == 4'd10 && w_uart_en) begin
                        if (r_send_index < r_recv_count) begin
                            r_rd_en <= 1'b1;
                            r_rd_data <= r_rd_data + 8'd1;
                            r_send_index <= r_send_index + 18'd1;
                        end else begin
                            r_state <= 2'd0;
                            r_wr_en <= 1'b0;
                            r_rd_en <= 1'b0;
                            r_wr_addr <= 18'd0;
                            r_rd_data <= 8'd0;
                            r_wr_data <= 8'd0;
                            r_state <= 2'd0;
                            r_recv_count <= 18'd0;
                            r_send_index <= 18'd0;
                        end
                    end
                end
            endcase
        end
    end
endmodule
