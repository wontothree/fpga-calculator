`timescale 10ns / 100ps

module testbench ();
reg [11:0] swp;
reg [7:0] swd;
reg rst, clk;

wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;
calculator calculator(
    swp, swd, rst, clk, seg, led, lcd_e, lcd_rs, lcd_rw, lcd_data
);

initial begin
    rst = 1; clk = 0; swp = 12'b0000_0000_0000; swd = 8'b0000_0000;
    #1 rst = 0;
    #130 swp = 12'b0100_0000_0000; // 2
    #10 swp = 0;    
    #130 swp = 12'b0010_0000_0000; // 3
    #10 swp = 0;

    #130 swd = 8'b1000_0000;
    #10 swd = 0;

    #130 swp = 12'b0001_0000_0000; // 4
    #10 swp = 0;
    #130 swp = 12'b0000_1000_0000; // 5
    #10 swp = 0;    
    #130 swp = 12'b0000_0100_0000; // 6
    #10 swp = 0;

    #130 swd = 8'b0100_0000;
    #10 swd = 0;

    #130 swp = 12'b0100_0000_0000; // 2
    #10 swp = 0;
    #130 swp = 12'b0010_0000_0000; // 3
    #10 swp = 0;    
    #130 swp = 12'b0001_0000_0000; // 4
    #10 swp = 0;

    #10 swd = 8'b0000_0001;
    
end

always #0.005 clk = ~clk;

endmodule