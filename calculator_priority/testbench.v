`timescale 10ns / 100ps

module testbench ();
reg swp1, swp2, swp3, swp4, swp5, swp6, swp7, swp8, swp9, rst, swp0, lrd;
reg swd1, swd2, swd3, swd4, swd5, swd6, swd7, swd8;

reg clk;
wire [7:0] seg, led;

wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;
calculator calculator(
    swp1, swp2, swp3, swp4, swp5, swp6, swp7, swp8, swp9, rst, swp0, lrd, 
    swd1, swd2, swd3, swd4, swd5, swd6, swd7, swd8, clk, seg, led, lcd_e, lcd_rs, lcd_rw, lcd_data
);

initial begin
    rst = 1; lrd = 0;
    clk = 0; swp1 = 0; swp1 = 0; swp2 = 0; swp3 = 0; swp4 = 0; swp5 = 0; swp6 = 0; swp7 = 0; swp8 = 0; swp9 = 0; swp0 = 0; 
    swd1 = 0; swd2 = 0; swd3 = 0; swd4 = 0; swd5 = 0; swd6 = 0; swd7 = 0; swd8 = 0;
    
    #1 rst = 0;
    #130 swp8 = 1; // 8
    #10 swp8 = 0;    
    #130 swp0 = 1; // 0
    #10 swp0 = 0;

    #130 swd4 = 1; // x
    #10 swd4 = 0;

    #130 swd1 = 1; // min
    #10 swd1 = 0;

    #130 swp2 = 1; // 2
    #10 swp2 = 0;
    #130 swp5 = 1; // 5
    #10 swp5 = 0;    

    #130 swd3 = 1; // sub
    #10 swd3 = 0;

    #130 swp3 = 1; // 3
    #10 swp3 = 0;
    #130 swp3 = 1; // 3
    #10 swp3 = 0;    
    #130 swp4 = 1; // 4
    #10 swp4 = 0;

    #130 swd3 = 1; // sum
    #10 swd3 = 0;

    #130 swp9 = 1; // 9
    #10 swp9 = 0;
    #130 swp9 = 1; // 9
    #10 swp9 = 0;

    #130 swd4 = 1; // mul
    #10 swd4 = 0;

    #130 swp3 = 1; // 3
    #10 swp3 = 0;
    #130 swp0 = 1; // 0
    #10 swp0 = 0;


    #130 swd8 = 1;
end

always #0.005 clk = ~clk;

endmodule