`timescale 10ns / 100ps

module testbench();
reg sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, rst, sw0, lrd;
reg clk;

wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;

calculator calculator(sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, rst, sw0, lrd, clk, seg, lcd_e, lcd_rs, lcd_rw, lcd_data);
initial begin
    rst = 1; clk = 0; sw1 = 0; sw2 = 0; sw3 = 0; sw4 = 0; sw5 = 0; sw6 = 0; sw7 = 0; sw8 = 0; sw9 = 0; sw0 = 0; lrd = 0;
    #1 rst = 0;
    #1 sw7 = 1;
    #10 sw7 = 0;
    #100 sw5 = 1;
    #10 sw5 = 0;
end

always #0.005 clk = ~clk;

endmodule
