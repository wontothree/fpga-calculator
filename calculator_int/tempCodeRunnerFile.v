module calculator (
    input [11:0] swp,
    input [7:0] swd,
    input rst, clk, 

    output reg [7:0] seg,
    output reg [7:0] led,
    
    output wire lcd_e,
    output reg lcd_rs, lcd_rw, 
    output reg [7:0] lcd_data
);