`timescale 10ns / 100ps

module testbench();
reg [11:0] sw;
reg rst, clk;


wire [3:0] led;
wire [7:0] seg;

wire lcd_e, lcd_rs, lcd_rw;
wire [7:0] lcd_data;

calculator1 u1(sw, rst, clk, led, seg, lcd_e, lcd_rs, lcd_rw, lcd_data);
initial begin
    rst = 1; clk = 0; sw = 0;
   #1 rst = 0; 

   #10 sw = 12'b0000_1000_0000;
   #2.5 sw = 12'b0000_0001_0000;
end

always #0.25 clk = ~clk;

endmodule

// `timescale 10ns / 100ps

// module testbench();
// reg [11:0] sw;
// reg rst, clk;


// wire [3:0] led;
// wire [7:0] seg;

// wire lcd_e, lcd_rs, lcd_rw;
// wire [7:0] lcd_data;

// calculator1 u1(sw, rst, clk, led, seg, lcd_e, lcd_rs, lcd_rw, lcd_data);
// initial begin
//     rst = 1; clk = 0; sw = 0;
//    #1 rst = 0; 

//    #10 sw = 12'b0000_1000_0000;
//    #4 sw = 12'b0000_0001_0000;
//    #4 rst = 1;
//    #4 sw = 12'b0000_0010_0000;
//    #4 sw = 12'b0000_0100_0000;
//    #4 rst = 1;
// end

// always #0.5 clk = ~clk;

// endmodule

