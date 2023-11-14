module switch_push (i_sw_push, o_seg, reg_lcd, rst, clk);

input [11:0] i_sw_push;
input rst, clk;
output [7:0] o_seg, reg_lcd;
reg [7:0] o_seg, reg_lcd;

parameter 
        seg_blk = 8'b0000_0000,
        seg_zer = 8'b1111_1100,
        seg_one = 8'b0110_0000,
        seg_two = 8'b1101_1010,
        seg_thr = 8'b1111_0010,
        seg_fou = 8'b0110_0110,
        seg_fiv = 8'b1011_0110,
        seg_six = 8'b1011_1110,
        seg_sev = 8'b1110_0000,
        seg_eig = 8'b1111_1110,
        seg_nin = 8'b1111_0110,

        lcd_blk = 8'b0010_0000,
        lcd_zer = 8'b0011_0000,
        lcd_one = 8'b0011_0001,
        lcd_two = 8'b0011_0010,
        lcd_thr = 8'b0011_0011,
        lcd_fou = 8'b0011_0100,
        lcd_fiv = 8'b0011_0101,
        lcd_six = 8'b0011_0110,
        lcd_sev = 8'b0011_0111,
        lcd_eig = 8'b0011_1000,
        lcd_nin = 8'b0011_1001;

always@(posedge rst or posedge clk)
begin
    if (rst)
        begin o_seg = seg_blk; reg_lcd = lcd_blk; end
    else
        begin
            case (i_sw_push)
                12'b1000_0000_0000 : begin o_seg = seg_zer; reg_lcd = lcd_zer;   end // 0
                12'b0100_0000_0000 : begin o_seg = seg_one; reg_lcd = lcd_one;   end // 1
                12'b0010_0000_0000 : begin o_seg = seg_two; reg_lcd = lcd_two;   end // 2
                12'b0001_0000_0000 : begin o_seg = seg_thr; reg_lcd = lcd_thr;   end // 3
                12'b0000_1000_0000 : begin o_seg = seg_fou; reg_lcd = lcd_fou;   end // 4
                12'b0000_0100_0000 : begin o_seg = seg_fiv; reg_lcd = lcd_fiv;   end // 5
                12'b0000_0010_0000 : begin o_seg = seg_six; reg_lcd = lcd_six;   end // 6
                12'b0000_0001_0000 : begin o_seg = seg_sev; reg_lcd = lcd_sev;   end // 7
                12'b0000_0000_1000 : begin o_seg = seg_eig; reg_lcd = lcd_eig;   end // 8
                12'b0000_0000_0100 : begin o_seg = seg_nin; reg_lcd = lcd_nin;   end // 9
                12'b0000_0000_0010 : begin o_seg = seg_blk; reg_lcd = lcd_blk;   end // rst
                12'b0000_0000_0001 : begin o_seg = seg_blk; reg_lcd = lcd_blk;   end // rst
                default : begin o_seg = seg_blk; reg_lcd = lcd_blk; end
            endcase
        end
end
endmodule