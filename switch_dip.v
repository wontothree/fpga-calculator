module switch_dip(i_sw_dip, o_led, reg_lcd, rst, clk);

input [7:0] i_sw_dip;
input rst, clk;
output [7:0] o_led, reg_lcd;
reg [7:0] o_led, reg_lcd;

parameter 
        lcd_blk = 8'b0010_0000,
        lcd_sum = 8'b0010_1011,
        lcd_sub = 8'b0010_1101,
        lcd_mul = 8'b1101_0111,
        lcd_div = 8'b0010_1111,
        lcd_rem = 8'b1111_0111,
        lcd_pow = 8'b0101_1110,
        lcd_fac = 8'b0010_0001,
        lcd_equ = 8'b0011_1101;

always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin o_led = 8'b0000_0000; reg_lcd = lcd_blk; end
    else
        begin
            case (i_sw_dip)
                8'b1000_0000 : begin o_led = 8'b1000_0000; reg_lcd = lcd_sum;    end 
                8'b0100_0000 : begin o_led = 8'b0100_0000; reg_lcd = lcd_sub;    end 
                8'b0010_0000 : begin o_led = 8'b0010_0000; reg_lcd = lcd_mul;    end 
                8'b0001_0000 : begin o_led = 8'b0001_0000; reg_lcd = lcd_div;    end 
                8'b0000_1000 : begin o_led = 8'b0000_1000; reg_lcd = lcd_rem;    end 
                8'b0000_0100 : begin o_led = 8'b0000_0100; reg_lcd = lcd_pow;    end 
                8'b0000_0010 : begin o_led = 8'b0000_0010; reg_lcd = lcd_fac;    end 
                8'b0000_0001 : begin o_led = 8'b0000_0001; reg_lcd = lcd_equ;    end 
                default :      begin o_led = 8'b0000_0000; reg_lcd = lcd_blk;    end
            endcase
        end
end

endmodule