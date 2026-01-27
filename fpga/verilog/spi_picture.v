module SPI_picture (
    input wire i_rst,
    input wire i_clk,
    input wire i_start,
    output wire        o_rd_en,
    output reg [17:0] o_rd_addr,
    input  wire [7:0] i_rd_data,
    output wire o_mosi,
    output wire o_dc,
    output wire o_cs,
    output wire o_done
);

    parameter WIDTH         = 220;
    parameter HEIGHT        = 220;
    parameter SET_COLUMN    = 8'h2A;
    parameter SET_PAGE      = 8'h2B;
    parameter WRITE_RAM     = 8'h2C;
    parameter DELAY = 2_700_000; 


    reg [3:0]  r_state   = 0;
    reg        r_we_cmd  = 0;
    reg        r_we_data = 0;
    reg [7:0]  r_cmd;
    reg [7:0]  r_data;
    reg        r_dc = 0;
    reg        r_done = 0;
    reg        r_need_delay = 0; 
    reg [11:0]  r_ycnt = 45;
    reg [11:0] r_xcnt = 5;
    reg [2:0]  r_state_column = 0;
    reg [2:0]  r_state_page = 0;
    reg [23:0] r_pixel_data;

    assign o_rd_en = 1'b1;

    wire w_done_cmd;
    wire w_done_data;
    wire o_cmd;
    wire o_data;
    wire o_cs_cmd;
    wire o_cs_data;
    wire [7:0] w_red;
    wire [7:0] w_green;
    wire [7:0] w_blue;

    SPI_cmd # (
        .DELAY (DELAY)
    ) spi_cmd (
        .i_rst          (i_rst       ),
        .i_clk          (i_clk       ),
        .i_cmd          (r_cmd       ),
        .i_we           (r_we_cmd    ),
        .i_need_delay   (r_need_delay),
        .o_cmd          (o_cmd       ),
        .o_cs           (o_cs_cmd    ),
        .o_done         (w_done_cmd  )
    );

    SPI_data_8 spi_data_8 (
        .i_rst          (i_rst      ),
        .i_clk          (i_clk      ),
        .i_data         (r_data     ),
        .i_we           (r_we_data  ),
        .o_data         (o_data     ),
        .o_cs           (o_cs_data  ),
        .o_done         (w_done_data)
    );

    lookup2to8 u_b (.i_2(i_rd_data[1:0]), .o_8(w_blue));
    lookup3to8 u_g (.i_3(i_rd_data[4:2]), .o_8(w_green));
    lookup3to8 u_r (.i_3(i_rd_data[7:5]), .o_8(w_red));

    assign o_dc = r_dc;
    assign o_done = r_done;
    assign o_mosi = r_dc ? o_data : o_cmd;
    assign o_cs   = r_dc ? o_cs_data : o_cs_cmd;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state   <= 0;
            r_dc <= 0;
            r_done    <= 0;
            r_xcnt    <= 5;
            r_ycnt    <= 45;
            o_rd_addr    <= 0;
            r_we_cmd  <= 0;
            r_we_data <= 0;
            r_state_column <= 0;
            r_state_page <= 0;
            r_need_delay = 0; 
        end else begin
                r_done    <= 0;
                if (r_ycnt-45 == HEIGHT) begin
                    r_state <= 0;
                    r_done <= 1;
                    r_ycnt <= 50;
                    o_rd_addr    <= 0;
                    r_dc <= 0;
                end else begin
                    case (r_state)
                        0: begin
                            r_we_cmd     <= 0;
                            r_we_data    <= 0;
                            r_done       <= 0;
                            if (i_start) begin
                                r_dc         <= 0;
                                r_we_cmd     <= 1;
                                r_we_data    <= 0;
                                r_cmd        <= SET_COLUMN;
                                r_state      <= 1;
                            end
                        end
                        1: begin
                            r_we_cmd    <= 0;
                            r_we_data   <= 0;
                            case (r_state_column)
                                0: begin
                                    if (w_done_cmd) begin
                                        r_dc        <= 1;
                                        r_state_column <= 1;
                                    end
                                end
                                1: begin
                                    r_we_cmd        <= 0;
                                    r_we_data       <= 1;
                                    r_data          <= r_xcnt >> 8;
                                    r_state_column  <= 2;
                                end
                                2: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd        <= 0;
                                        r_we_data       <= 1;
                                        r_data          <= r_xcnt & 8'hff;
                                        r_state_column  <= 3;
                                    end
                                end
                                3: begin 
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd        <= 0;
                                        r_we_data       <= 1;
                                        r_data          <= r_xcnt >> 8;
                                        r_state_column  <= 4;
                                    end
                                end
                                4: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd        <= 0;
                                        r_we_data       <= 1;
                                        r_data          <= r_xcnt & 8'hff;
                                        r_state_column  <= 5;
                                    end
                                end
                                5: begin
                                    r_we_cmd    <= 0;
                                    r_we_data   <= 0;
                                    if (w_done_data) begin
                                        r_state_column <= 0;
                                        r_state <= 2;
                                    end
                                end
                            endcase
                        end
                        2: begin
                            r_dc        <= 0;
                            r_we_cmd    <= 1;
                            r_we_data   <= 0;
                            r_cmd       <= SET_PAGE;
                            r_state     <= 3;
                        end
                        3: begin
                            r_we_cmd    <= 0;
                            r_we_data   <= 0;
                            case (r_state_page)
                                0: begin
                                    if (w_done_cmd) begin
                                        r_dc        <= 1;
                                        r_state_page <= 1;
                                    end
                                end
                                1: begin
                                    r_we_cmd      <= 0;
                                    r_we_data     <= 1;
                                    r_data        <= r_ycnt >> 8;
                                    r_state_page  <= 2;
                                end
                                2: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd      <= 0;
                                        r_we_data     <= 1;
                                        r_data        <= r_ycnt & 8'hff;
                                        r_state_page  <= 3;
                                    end
                                end
                                3: begin 
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd      <= 0;
                                        r_we_data     <= 1;
                                        r_data        <= r_ycnt >> 8;
                                        r_state_page  <= 4;
                                    end
                                end
                                4: begin
                                    r_we_cmd  <= 0;
                                    r_we_data <= 0;
                                    if (w_done_data) begin
                                        r_we_cmd      <= 0;
                                        r_we_data     <= 1;
                                        r_data        <= r_ycnt & 8'hff;
                                        r_state_page  <= 5;
                                    end
                                end
                                5: begin
                                    r_we_cmd    <= 0;
                                    r_we_data   <= 0;
                                    if (w_done_data) begin
                                        r_state_page <= 0;
                                        r_state <= 4;
                                    end
                                end
                        endcase
                    end
                    4: begin
                        r_dc        <= 0;
                        r_we_cmd    <= 1;
                        r_we_data   <= 0;
                        r_cmd       <= WRITE_RAM;
                        r_state     <= 5;
                    end
                    5: begin
                        r_we_cmd    <= 0;
                        r_we_data   <= 0;
                        r_pixel_data <= {w_blue, w_green, w_red};
                        if (w_done_cmd) begin
                            r_dc          <= 1;
                            r_we_cmd      <= 0;
                            r_we_data     <= 1;
                           r_data        <= r_pixel_data[23:16];
                            r_state       <= 6;
                        end
                    end
                    6: begin
                        r_we_cmd    <= 0;
                        r_we_data   <= 0;
                        if (w_done_data) begin
                            r_dc          <= 1;
                            r_we_cmd      <= 0;
                            r_we_data     <= 1;
                           r_data        <= r_pixel_data[15:8];
                            r_state     <= 7;
                        end
                    end
                    7: begin
                        r_we_cmd    <= 0;
                        r_we_data   <= 0;
                        if (w_done_data) begin
                            r_dc          <= 1;
                            r_we_cmd      <= 0;
                            r_we_data     <= 1;
                           r_data        <= r_pixel_data[7:0];
                            r_xcnt        <= r_xcnt + 1'b1;
                            o_rd_addr        <= o_rd_addr + 1'b1;
                            r_state     <= 9;
                        end
                    end
                    9: begin
                        r_we_cmd    <= 0;
                        r_we_data   <= 0;
                        if (w_done_data) begin
                            if (r_xcnt-5 == WIDTH) begin
                                r_state <= 10;
                                r_xcnt <= 5;
                            end else begin
                                r_dc         <= 0;
                                r_we_cmd     <= 1;
                                r_we_data    <= 0;
                                r_cmd        <= SET_COLUMN;
                                r_state      <= 1;
                            end 
                        end
                    end
                    10: begin
                        r_state <= 11;
                        r_ycnt <= r_ycnt + 1'b1;
                    end
                    11: begin
                            r_dc         <= 0;
                            r_we_cmd     <= 1;
                            r_we_data    <= 0;
                            r_cmd        <= SET_COLUMN;
                            r_state      <= 1;
                    end
                    endcase
                end
        end
    end
endmodule
