`timescale 10ns / 100ps

module testbench();
reg swp1, swp2, swp3, swp4, swp5, swp6, swp7, swp8, swp9, rst, swp0, lrd;
reg [7:0] swd;
reg clk;

wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;
textlcd textlcd(
    swp1, swp2, swp3, swp4, swp5, swp6, swp7, swp8, swp9, rst, swp0, lrd, 
    swd, 
    clk, 
    seg, led, 
    lcd_e, lcd_rs, lcd_rw, lcd_data
);

initial begin
    rst = 1; clk = 0; swp1 = 0; swp2 = 0; swp3 = 0; swp4 = 0; swp5 = 0; swp6 = 0; swp7 = 0; swp8 = 0; swp9 = 0; swp0 = 0; lrd = 0; swd = 0;
    #1 rst = 0;
    #10 swp7 = 1;
    #10 swp7 = 0; swd = 8'b0001_0000;
    #100 swp5 = 1;
    #10 swp5 = 0;
end

always #0.005 clk = ~clk;

endmodule
