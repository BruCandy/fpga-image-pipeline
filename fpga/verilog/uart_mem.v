module uart_mem (
    input  wire        i_clk,
    input  wire        i_rst,    
    input  wire        i_wr_en,
    input  wire [17:0] i_wr_addr,
    input  wire [7:0]  i_wr_data,
    input  wire        i_rd_en,
    input  wire [17:0] i_rd_addr,
    output wire [7:0]  o_rd_data
);

    parameter WIDTH = 220;
    parameter HEIGHT = 220;

    reg [7:0] img_mem [0:48400];

    reg [7:0] r_rd_data;
    assign o_rd_data = r_rd_data;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_rd_data <= 8'd0;
        end else begin
            if(i_wr_en)
                img_mem[i_wr_addr] <= i_wr_data;
            if(i_rd_en)
                r_rd_data <= img_mem[i_rd_addr];
        end
    end
endmodule
