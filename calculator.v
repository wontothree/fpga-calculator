module calculator1 (sw, dipsw, rst, clk, led, seg, lcd_e, lcd_rs, lcd_rw, lcd_data);

input [11:0] sw;
input [7:0] dipsw;
input rst, clk;
output lcd_e, lcd_rs, lcd_rw;
output [7:0] led;
output [7:0] seg;
output [7:0] lcd_data;

reg [3:0] led;
reg [7:0] seg;
reg [7:0] reg_temp;
reg [7:0] reg_temp1;
reg [7:0] reg_temp2;
reg [7:0] reg_temp3;
wire lcd_e;
reg lcd_rs, lcd_rw;
reg [7:0] lcd_data;
reg [2:0] state;

parameter delay = 3'b000,
        function_set = 3'b001,
        entry_mode = 3'b010,
        disp_onoff = 3'b011,
        line1 = 3'b100,
        line2 = 3'b101,
        delay_t = 3'b110,
        clear_disp = 3'b111,
        
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
        lcd_nin = 8'b0011_1001,
        
        lcd_sum = 8'b0010_1011,
        lcd_sub = 8'b0010_1101,
        lcd_mul = 8'b1101_0111,
        lcd_div = 8'b0010_1111,
        lcd_rem = 8'b1111_0111,
        lcd_pow = 8'b0101_1110,
        lcd_fac = 8'b0010_0001,
        lcd_equ = 8'b0011_1101;

integer cnt;
integer cnt_100hz;
reg clk_100hz;
integer swcnt;


always @(posedge rst or posedge clk)
begin
    if (rst) begin cnt_100hz = 0;  clk_100hz = 1'b0; end
    else if (cnt_100hz >= 4) begin cnt_100hz = 0; clk_100hz = ~clk_100hz; end
    else cnt_100hz = cnt_100hz + 1;
end

always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
        cnt = 0;
    else
        begin
            case (state)
                delay :
                    if (cnt >= 70) cnt = 0;
                    else cnt = cnt + 1;
                function_set :
                    if (cnt >= 30) cnt = 0;
                    else cnt = cnt + 1;
                disp_onoff :
                    if (cnt >= 30) cnt = 0;
                    else cnt = cnt + 1;
                entry_mode :
                    if (cnt >= 30) cnt = 0;
                    else cnt = cnt + 1;
                line1 :
                    if (cnt >= 20) cnt = 0;
                    else cnt = cnt + 1;
                line2 :
                    if (cnt >= 20) cnt = 0;
                    else cnt = cnt + 1;
                delay_t :
                    if (cnt >= 400) cnt = 0;
                    else cnt = cnt + 1;
                clear_disp :
                    if (cnt >= 200) cnt = 0;
                    else cnt = cnt + 1;
                default : cnt = 0;
            endcase
        end
end

always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        state = delay;
    else
        begin
            case (state)
                delay :             if (cnt == 70) state = function_set;
                function_set :      if (cnt == 30) state = disp_onoff;
                disp_onoff :        if (cnt == 30) state = entry_mode;
                entry_mode :        if (cnt == 30) state = line1;
                line1 :             if (cnt == 20) state = line2;
                line2 :             if (cnt == 20) state = delay_t;
                delay_t :           if (cnt == 400) state = clear_disp;
                clear_disp :        if (cnt == 200) state = line1;
                default : state = delay;
            endcase
        end
end



always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin led = 4'b0000; seg = 8'b0000_0000; reg_temp = 8'b0000_0000; end
    else
        begin
            case (sw)
                12'b1000_0000_0000 : begin seg = seg_zer; reg_temp = lcd_zer;   end // 0
                12'b0100_0000_0000 : begin seg = seg_one; reg_temp = lcd_one;   end // 1
                12'b0010_0000_0000 : begin seg = seg_two; reg_temp = lcd_two;   end // 2
                12'b0001_0000_0000 : begin seg = seg_thr; reg_temp = lcd_thr;   end // 3
                12'b0000_1000_0000 : begin seg = seg_fou; reg_temp = lcd_fou;   end // 4
                12'b0000_0100_0000 : begin seg = seg_fiv; reg_temp = lcd_fiv;   end // 5
                12'b0000_0010_0000 : begin seg = seg_six; reg_temp = lcd_six;   end // 6
                12'b0000_0001_0000 : begin seg = seg_sev; reg_temp = lcd_sev;   end // 7
                12'b0000_0000_1000 : begin seg = seg_eig; reg_temp = lcd_eig;   end // 8
                12'b0000_0000_0100 : begin seg = seg_nin; reg_temp = lcd_nin;   end // 9
                12'b0000_0000_0010 : begin seg = seg_blk; reg_temp = lcd_blk;   end // rst
                12'b0000_0000_0001 : begin seg = seg_blk; reg_temp = lcd_blk;   end // rst
                default : led = 4'b0000;
            endcase
        end
end


always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin led = 4'b0000_0000; end
    else
        begin
            case (dipsw)
                8'b1000_0000 : begin led = 8'b1000_0000; reg_temp = lcd_sum;    end 
                8'b0100_0000 : begin led = 8'b0100_0000; reg_temp = lcd_sub;    end 
                8'b0010_0000 : begin led = 8'b0010_0000; reg_temp = lcd_mul;    end 
                8'b0001_0000 : begin led = 8'b0001_0000; reg_temp = lcd_div;    end 
                8'b0000_1000 : begin led = 8'b0000_1000; reg_temp = lcd_rem;    end 
                8'b0000_0100 : begin led = 8'b0000_0100; reg_temp = lcd_pow;    end 
                8'b0000_0010 : begin led = 8'b0000_0010; reg_temp = lcd_fac;    end 
                8'b0000_0001 : begin led = 8'b0000_0001; reg_temp = lcd_equ;    end 
                default : led = 4'b0000;
            endcase
        end
end


always @(posedge rst or posedge clk_100hz)
begin
    if (rst) swcnt = 0;
    else if (swcnt >= 2) swcnt = 0;
    else if (sw) swcnt = swcnt + 1;
end

always @(posedge rst or posedge clk_100hz)
begin
    if (rst) begin reg_temp = 8'b0000_0000; reg_temp1 = 8'b0000_0000; reg_temp2 = 8'b0000_0000; end
    else
        begin
            case (swcnt)
                1 : reg_temp1 = reg_temp;
                2 : reg_temp2 = reg_temp;
                default reg_temp3 = reg_temp;
            endcase
        end
end

//always @(posedge rst or posedge clk)
//begin



always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin
            lcd_rs = 1'b1;
            lcd_rw = 1'b1;
            lcd_data = 8'b00000000;
        end
    else
        begin
            case (state)
                function_set :
                    begin
                        lcd_rs = 1'b0; lcd_rw = 1'b0; lcd_data = 8'b00111100;
                    end
                disp_onoff :
                    begin
                        lcd_rs = 1'b0; lcd_rw = 1'b0; lcd_data = 8'b00001100;
                    end
                entry_mode :
                    begin
                        lcd_rs = 1'b0;  lcd_rw = 1'b0; lcd_data = 8'b00000110;
                    end
                line1 :
                    begin
                        lcd_rw = 1'b0; 
                        
                        case (cnt)
                            0 : begin
                                    lcd_rs = 1'b0;  lcd_data = 8'b10000000;
                                end
                            1 : begin
                                    lcd_rs = 1'b1;  lcd_data = reg_temp1;
                                end
                            2 : begin
                                    lcd_rs = 1'b1;  lcd_data = lcd_sum;
                                end
                            3 : begin
                                    lcd_rs = 1'b1;  lcd_data = reg_temp2;
                                end
                            4 : begin
                                    lcd_rs = 1'b1;  lcd_data = lcd_equ;
                                end
                            5 : begin
                                    lcd_rs = 1'b1;  lcd_data = lcd_blk;
                                end
                            6 : begin
                                    lcd_rs = 1'b1;  lcd_data = reg_temp;
                                end
                            default : begin
                                            lcd_rs = 1'b1; lcd_rw = 1'b0;   lcd_data =8'b00100000;
                                      end
                        endcase
                    end
                line2 :
                    begin
                        lcd_rw = 1'b0;

                        case (cnt)
                            0 : begin
                                    lcd_rs = 1'b0; lcd_data = 8'b11000000;
                                end
                            9 : begin
                                    lcd_rs = 1'b1; lcd_data = 8'b01010111; // W
                                end
                            10 : begin
                                    lcd_rs = 1'b1; lcd_data = 8'b01101111; // o
                                end
                            11 : begin
                                    lcd_rs = 1'b1; lcd_data = 8'b01110010; // r
                                end
                            12 : begin
                                    lcd_rs = 1'b1; lcd_data = 8'b01101100; // l
                                end
                            13 : begin
                                    lcd_rs = 1'b1; lcd_data = 8'b01100100; // d
                                end
                            default : begin
                                    lcd_rs = 1'b1; lcd_data = 8'b00100000; 
                                end
                        endcase
                    end                        
                delay_t :
                    begin
                        lcd_rs = 1'b0; lcd_rw = 1'b0; lcd_data = 8'b00000010;
                    end
                clear_disp :
                    begin
                        lcd_rs = 1'b0; lcd_rw = 1'b0; lcd_data = 8'b00000001;
                    end
                default :
                    begin
                        lcd_rs = 1'b1;  lcd_rw = 1'b1;  lcd_data = 8'b00000000;
                    end
            endcase
        end
end

assign lcd_e = clk_100hz;

endmodule