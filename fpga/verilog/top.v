module top(
    input wire i_clk,
    input wire i_rst,
    input wire i_rxd,
    output wire o_mosi,
    output wire o_cs,
    output wire o_dc,
    output wire o_rst,
    output wire o_clk,
    output wire o_txd
);

    parameter DELAY  = 2_700_000; 
    parameter WIDTH  = 240;
    parameter HEIGHT = 320;

    reg [3:0] r_state = 0;
    reg       r_init_start = 0;
    reg       r_clear_start = 0;
    reg       r_picture_start = 0;

    wire w_init_done;
    wire w_init_mosi;
    wire w_init_dc;
    wire w_init_cs;
    wire w_clear_done;
    wire w_clear_mosi;
    wire w_clear_dc;
    wire w_clear_cs;
    wire w_picture_done;
    wire w_picture_mosi;
    wire w_picture_dc;
    wire w_picture_cs;
    wire w_receive_done;

    wire        w_mem_wr_en;
    wire [17:0] w_mem_wr_addr;
    wire [7:0]  w_mem_wr_data;

    wire        w_mem_rd_en;
    wire [17:0] w_mem_rd_addr;
    wire [7:0]  w_mem_rd_data;

    assign w_rst = ~i_rst;
    assign o_rst = i_rst;
    assign o_clk = i_clk;

    assign o_mosi = (r_state == 1) ? w_init_mosi :
                    (r_state == 6) ? w_init_mosi :
                    (r_state == 2) ? w_clear_mosi :
                    (r_state == 7) ? w_clear_mosi :
                    (r_state == 4) ? w_picture_mosi :
                    (r_state == 8) ? w_picture_mosi :0; 
    assign o_dc =   (r_state == 1) ? w_init_dc :
                    (r_state == 6) ? w_init_dc :
                    (r_state == 2) ? w_clear_dc :
                    (r_state == 7) ? w_clear_dc :
                    (r_state == 4) ? w_picture_dc :
                    (r_state == 8) ? w_picture_dc :0; 
    assign o_cs =   (r_state == 1) ? w_init_cs :
                    (r_state == 6) ? w_init_cs :
                    (r_state == 2) ? w_clear_cs :
                    (r_state == 7) ? w_clear_cs :
                    (r_state == 4) ? w_picture_cs :
                    (r_state == 8) ? w_picture_cs :1; 

    uart_mem mem0 (
        .i_clk(i_clk),
        .i_rst(w_rst),
        .i_wr_en(w_mem_wr_en),
        .i_wr_addr(w_mem_wr_addr),
        .i_wr_data(w_mem_wr_data),
        .i_rd_en(w_mem_rd_en),
        .i_rd_addr(w_mem_rd_addr),
        .o_rd_data(w_mem_rd_data)
    );

    uart_wrapper uw (
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .i_rxd      (i_rxd),
        .o_txd      (o_txd),
        .o_wr_en    (w_mem_wr_en),
        .o_wr_addr  (w_mem_wr_addr),
        .o_wr_data  (w_mem_wr_data),
        .o_receive_done (w_receive_done)
    );

    SPI_init # (
        .DELAY (DELAY)
    )spi_init(
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_init_start),
        .o_mosi     (w_init_mosi),
        .o_dc       (w_init_dc),
        .o_cs       (w_init_cs),
        .o_done     (w_init_done)
    );

    SPI_clear # (
        .DELAY  (DELAY),
        .WIDTH  (WIDTH),
        .HEIGHT (HEIGHT)
    ) spi_clear(
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_clear_start),
        .o_mosi     (w_clear_mosi),
        .o_dc       (w_clear_dc),
        .o_cs       (w_clear_cs),
        .o_done     (w_clear_done)
    );

    SPI_picture # (
        .DELAY (DELAY)
    ) spi_picture (
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_picture_start),
        .o_rd_en    (w_mem_rd_en),
        .o_rd_addr  (w_mem_rd_addr),
        .i_rd_data  (w_mem_rd_data),
        .o_mosi     (w_picture_mosi),
        .o_dc       (w_picture_dc),
        .o_cs       (w_picture_cs),
        .o_done     (w_picture_done)
    );

    always @(posedge i_clk or posedge w_rst) begin
        if (w_rst) begin
            r_state <= 0;
            r_init_start <= 0;
            r_clear_start <= 0;
            r_picture_start <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_init_start <= 1;
                    r_state <= 1;
                end
                1: begin
                    r_init_start <= 0;
                    if (w_init_done) begin
                        r_state <= 2;
                        r_clear_start <= 1;
                    end
                end
                2: begin
                    r_clear_start <= 0;
                    if (w_clear_done) begin
                        r_state <= 3;
                    end 
                end
                3: begin 
                    if (w_receive_done) begin
                        r_state <= 4;
                        r_picture_start <= 1;
                    end
                end
                4: begin
                    r_picture_start <= 0;
                    if (w_picture_done) begin
                        r_state <= 5;
                    end 
                end
                5: begin
                    if (w_receive_done) begin 
                        r_state <= 3;
                    end
                end
                9: begin
                    if (w_receive_done) begin 
                        r_state <= 6;
                        r_init_start <= 1;
                    end
                end
                6: begin
                    r_init_start <= 0;
                    if (w_init_done) begin
                        r_state <= 7;
                        r_clear_start <= 1;
                    end
                end
                7: begin
                    r_clear_start <= 0;
                    if (w_clear_done) begin
                        r_state <= 8;   
                        r_picture_start <= 1;
                    end
                end
                8: begin
                    r_picture_start <= 0;
                    if (w_picture_done) begin
                        r_state <= 5;
                    end
                end
            endcase
        end
    end
endmodule
