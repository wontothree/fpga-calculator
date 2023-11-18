`timescale 10ns / 10ps

module testbench();
reg sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, rst, sw0, lrd;
reg clk;

wire [3:0] led;
wire [7:0] seg;

wire lcd_e;
wire lcd_rs, lcd_rw;
wire [7:0] lcd_data;

calculator1 u1(sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, rst, sw0, lrd, clk, led, seg, lcd_e, lcd_rs, lcd_rw, lcd_data);
initial begin
    rst = 1; clk = 0;
   #5 rst = 0; 
   #5 sw5 = 1;
   #60 sw5 = 0;
   #1 sw7 = 1;
   #25 sw7 = 0;

end

always #0.001 clk = ~clk;

endmodule