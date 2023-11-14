`timescale 10ns / 10ps

module testbench();
reg [11:0] i_sw_push;
reg [7:0] i_sw_dip;
reg rst, clk;


wire [3:0] o_led;
wire [7:0] o_seg;

wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;

calculator calculator(i_sw_push, i_sw_dip, rst, clk, o_led, o_seg, lcd_data, lcd_e, lcd_rs, lcd_rw);
initial begin
//    rst = 1; clk = 0; sw = 0;
//    #5 sw = 12'b1000_0000_0000; rst = 0; // 0
//    #5 sw = 12'b0100_0000_0000; // 1
//    #5 sw = 12'b0010_0000_0000; // 2
//    #5 sw = 12'b0001_0000_0000; // 3
//    #5 sw = 12'b0000_1000_0000; // 4
//    #5 sw = 12'b0000_0100_0000; // 5
//    #5 sw = 12'b0000_0010_0000; // 6
//    #5 sw = 12'b0000_0001_0000; // 7
//    #5 sw = 12'b0000_0000_1000; // 8
   
//    #5 sw = 12'b0000_0000_0100; // 9
//    #5 sw = 12'b0000_0000_0010;
//    #5 sw = 12'b0000_0000_0001;
//    #5 sw = 12'b0000_0000_0010;
//    #5 sw = 12'b0000_0000_0100; // 9
//    #5 sw = 12'b0000_0000_1000; // 8
//    #5 sw = 12'b0000_0001_0000; // 7
//    #5 sw = 12'b0000_0010_0000; // 6
//    #5 sw = 12'b0000_0100_0000; // 5
//    #5 sw = 12'b0000_1000_0000; // 4
    rst = 1; clk = 0; i_sw_push = 12'b0000_0000_0000;
    #5 i_sw_push = 12'b0010_0000_0000; rst = 0;
end

always #0.5 clk = ~clk;

endmodule
