`timescale 10ns / 100ps

module testbench();
reg rst, clk;
wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;

textlcd u1(rst, clk, lcd_e, lcd_rs, lcd_rw, lcd_data);
initial begin
    rst = 1; clk = 0;
    #10 rst = 0;
end

always #1 clk = ~clk;

endmodule
