module calculator (
    input [11:0] i_sw_push,
    input [7:0] i_sw_dip,
    input wire rst, clk,
    output wire [7:0] o_led, o_seg,
    output wire [7:0] lcd_data,
    output wire lcd_e, lcd_rs, lcd_rw
);
wire [7:0] reg_temp1, reg_temp2;

parameter
        lcd_sum = 8'b0010_1011,
        lcd_sub = 8'b0010_1101,
        lcd_mul = 8'b1101_0111,
        lcd_div = 8'b0010_1111,
        lcd_rem = 8'b1111_0111,
        lcd_pow = 8'b0101_1110,
        lcd_fac = 8'b0010_0001,
        lcd_equ = 8'b0011_1101,
        
        lcd_zer = 8'b0011_0000,
        lcd_one = 8'b0011_0001,
        lcd_two = 8'b0011_0010,
        lcd_thr = 8'b0011_0011,
        lcd_fou = 8'b0011_0100,
        lcd_fiv = 8'b0011_0101,
        lcd_six = 8'b0011_0110,
        lcd_sev = 8'b0011_0111,
        lcd_eig = 8'b0011_1000,
        lcd_nin = 8'b0011_1001,
        
        lcd_blk = 8'b0010_0000;


// clock divider
clock_divider clock_divider(rst, clk, clk_100hz);

// push switch
switch_push switch_push (i_sw_push, rst, clk_100hz, o_seg, reg_lcd, reg_temp1, reg_temp2);

// dip switch
// switch_dip switch_dip (i_sw_dip, rst, clk_100hz, o_led, reg_lcd);

// state machine
textlcd textlcd(rst, clk_100hz, 
                lcd_one, lcd_sum, lcd_one, lcd_equ,
                lcd_one, lcd_blk, lcd_one, lcd_blk,
                lcd_one, lcd_blk, lcd_one, lcd_blk,
                lcd_one, lcd_blk, lcd_one, lcd_blk,

                lcd_blk, lcd_blk, lcd_blk, lcd_blk,
                lcd_blk, lcd_blk, lcd_blk, lcd_blk,
                lcd_blk, lcd_blk, lcd_blk, lcd_blk,
                lcd_blk, lcd_blk, lcd_blk, lcd_blk,
                
                lcd_e, lcd_rs, lcd_rw, lcd_data
);

endmodule