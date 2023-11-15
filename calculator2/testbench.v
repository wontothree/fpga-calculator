`timescale 10ns / 100ps

module testbench();
reg [11:0] sw;
reg [7:0] dipsw;
reg rst, clk;
wire [3:0] led;
wire [7:0] seg;

wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;

calculator2 u1(sw, dipsw, rst, clk, led, seg, lcd_e, lcd_rs, lcd_rw, lcd_data);
initial begin
    rst = 1; clk = 0; sw = 12'b0000_0000_0000; dipsw = 8'b0000_0000;
    #5 rst = 0;
end

always #0.25 clk = ~clk;

endmodule
