module calculator1 (
    input [11:0] sw, 
    input rst, clk,
    output reg [3:0] led, 
    output reg [7:0] seg, 
    output wire lcd_e, 
    output reg lcd_rs, lcd_rw,
    output [7:0] lcd_data
);

reg [7:0] reg_temp, reg_lcd_l1_1, reg_lcd_l1_3, reg_lcd_l1_5, reg_lcd_l1_6;
reg [3:0] reg_num, reg_num1, reg_num2;

reg [4:0] reg_sum;
reg reg_cout;


reg [7:0] lcd_data;
reg [2:0] state;

parameter 
        delay = 3'b000,
        function_set = 3'b001,
        entry_mode = 3'b010,
        disp_onoff = 3'b011,
        line1 = 3'b100,
        line2 = 3'b101,
        delay_t = 3'b110,
        clear_disp = 3'b111,

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
        lcd_div = 8'b1111_0111,
        lcd_equ = 8'b0011_1101,
        
        lcd_blk = 8'b0010_0000;

integer cnt;
integer cnt_100hz;
reg clk_100hz;
integer cnt_sw;

// clock divider
always @(posedge rst or posedge clk)
begin
    if (rst)
        begin
            cnt_100hz = 0;  
            clk_100hz = 1'b0; 
        end
    else if (cnt_100hz >= 4)
        begin
            cnt_100hz = 0; 
            clk_100hz = ~clk_100hz; 
        end
    else cnt_100hz = cnt_100hz + 1;
end

// count
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

// state machine
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
        begin led = 4'b0000; seg = 8'b0000_0000; reg_temp = lcd_blk; end
    else
        begin
            case (sw)
                12'b1000_0000_0000 : begin led = 4'b0000; seg = 8'b1111_1100; reg_num = 4'b0000; reg_temp = lcd_zer;    end // 0
                12'b0100_0000_0000 : begin led = 4'b0001; seg = 8'b0110_0000; reg_num = 4'b0001; reg_temp = lcd_one;    end // 1
                12'b0010_0000_0000 : begin led = 4'b0010; seg = 8'b1101_1010; reg_num = 4'b0010; reg_temp = lcd_two;    end // 2
                12'b0001_0000_0000 : begin led = 4'b0011; seg = 8'b1111_0010; reg_num = 4'b0011; reg_temp = lcd_thr;    end // 3
                12'b0000_1000_0000 : begin led = 4'b0100; seg = 8'b0110_0110; reg_num = 4'b0100; reg_temp = lcd_fou;    end // 4
                12'b0000_0100_0000 : begin led = 4'b0101; seg = 8'b1011_0110; reg_num = 4'b0101; reg_temp = lcd_fiv;    end // 5
                12'b0000_0010_0000 : begin led = 4'b0110; seg = 8'b1011_1110; reg_num = 4'b0110; reg_temp = lcd_six;    end // 6
                12'b0000_0001_0000 : begin led = 4'b0111; seg = 8'b1110_0000; reg_num = 4'b0111; reg_temp = lcd_sev;    end // 7
                12'b0000_0000_0100 : begin led = 4'b1001; seg = 8'b1111_0110; reg_num = 4'b1001; reg_temp = lcd_nin;    end // 9
                12'b0000_0000_0010 : begin led = 4'b0000; seg = 8'b1111_1110; reg_num = 4'b0000; reg_temp = lcd_blk;    end // rst
                12'b0000_0000_0001 : begin led = 4'b1111; seg = 8'b1111_1110; reg_num = 4'b0000; reg_temp = lcd_blk;    end // rst
                default : led = 4'b0000;
            endcase
        end
end

// sum
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) cnt_sw = 0;
    else if (cnt_sw >= 2) cnt_sw = 0;
    else if (sw) cnt_sw = cnt_sw + 1;
end

always @(posedge rst or posedge clk_100hz)
begin
    if (rst) begin reg_temp = lcd_blk; reg_lcd_l1_1 = lcd_blk; reg_lcd_l1_3 = lcd_blk; end
    else
        begin
            case (cnt_sw)
                1 : begin
                        reg_lcd_l1_1 = reg_temp;
                        reg_num1 = reg_num;
                    end
                2 : begin
                        reg_lcd_l1_3 = reg_temp;
                        reg_num2 = reg_num;
                        
                        reg_sum = reg_num1 + reg_num2;
                        if(reg_sum >= 5'b01010) 
                            begin
                                reg_lcd_l1_5 = lcd_one;
                                case(reg_sum - 5'b01010)
                                    0: reg_lcd_l1_6 = lcd_zer;
                                    1: reg_lcd_l1_6 = lcd_one;
                                    2: reg_lcd_l1_6 = lcd_two;
                                    3: reg_lcd_l1_6 = lcd_thr;
                                    4: reg_lcd_l1_6 = lcd_fou;
                                    5: reg_lcd_l1_6 = lcd_fiv;
                                    6: reg_lcd_l1_6 = lcd_six;
                                    7: reg_lcd_l1_6 = lcd_sev;
                                    8: reg_lcd_l1_6 = lcd_eig;
                                    9: reg_lcd_l1_6 = lcd_nin;
                                endcase
                            end
                        else 
                            begin
                                reg_lcd_l1_5 = lcd_zer;
                                case(reg_sum)
                                    0: reg_lcd_l1_6 = lcd_zer;
                                    1: reg_lcd_l1_6 = lcd_one;
                                    2: reg_lcd_l1_6 = lcd_two;
                                    3: reg_lcd_l1_6 = lcd_thr;
                                    4: reg_lcd_l1_6 = lcd_fou;
                                    5: reg_lcd_l1_6 = lcd_fiv;
                                    6: reg_lcd_l1_6 = lcd_six;
                                    7: reg_lcd_l1_6 = lcd_sev;
                                    8: reg_lcd_l1_6 = lcd_eig;
                                    9: reg_lcd_l1_6 = lcd_nin;
                                endcase
                            end
                    end
            endcase
        end
end


// lcd
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
                                    lcd_rs = 1'b1;  lcd_data = reg_lcd_l1_1;
                                end
                            2 : begin
                                    lcd_rs = 1'b1;  lcd_data = lcd_sum;
                                end
                            3 : begin
                                    lcd_rs = 1'b1;  lcd_data = reg_lcd_l1_3;
                                end
                            4 : begin
                                    lcd_rs = 1'b1;  lcd_data = lcd_equ;
                                end
                            5 : begin
                                    lcd_rs = 1'b1;  lcd_data = reg_lcd_l1_5;
                                end
                            6 : begin
                                    lcd_rs = 1'b1;  lcd_data = reg_lcd_l1_6;
                                end
                            default : begin
                                            lcd_rs = 1'b1;  lcd_data = lcd_blk;
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
                            default : begin
                                    lcd_rs = 1'b1; lcd_data = lcd_blk; 
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