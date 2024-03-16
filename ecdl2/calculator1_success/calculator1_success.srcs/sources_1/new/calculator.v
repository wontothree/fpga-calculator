module calculator(
    input sw1, sw2, sw3, sw4, sw5, sw6, sw7, sw8, sw9, rst, sw0, lrd,
    input clk, 

    output reg [7:0] seg,
    output wire lcd_e,
    output reg lcd_rs, lcd_rw, 
    output reg [7:0] lcd_data
);

parameter 
        delay           = 3'b000,
        function_set    = 3'b001,
        entry_mode      = 3'b010,
        disp_onoff      = 3'b011,
        line1           = 3'b100,
        line2           = 3'b101,
        delay_t         = 3'b110,
        clear_disp      = 3'b111,

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

// clock divider
integer cnt_100hz;
reg clk_100hz;
always @(posedge rst or posedge clk)
begin
    if (rst)
        begin
        cnt_100hz = 0;  clk_100hz = 1'b0;
        end
    else if (cnt_100hz >= 4)
        begin
        cnt_100hz = 0; clk_100hz = ~clk_100hz;
        end
    else
        cnt_100hz = cnt_100hz + 1;
end

// push switch
reg [7:0] reg_lcd;
reg [3:0] reg_num;
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin 
            reg_num = 4'b0000;
            reg_lcd = lcd_blk; 
            seg = 8'b0000_0000;
        end
    else
        begin
            if (sw1)
                begin
                    reg_num = 4'b0001;
                    reg_lcd = lcd_one;
                    seg = 8'b0110_0000;
                end
            else if (sw2)
                begin
                    reg_num = 4'b0010;
                    reg_lcd = lcd_two;
                    seg = 8'b1101_1010;
                end
            else if (sw3)
                begin
                    reg_num = 4'b0011;
                    reg_lcd = lcd_thr;
                    seg = 8'b1111_0010;
                end
            else if (sw4)
                begin
                    reg_num = 4'b0100;
                    reg_lcd = lcd_fou;
                    seg = 8'b0110_0110;
                end
            else if (sw5)
                begin
                    reg_num = 4'b0101;
                    reg_lcd = lcd_fiv;
                    seg = 8'b1011_0110;
                end
            else if (sw6)
                begin
                    reg_num = 4'b0110;
                    reg_lcd = lcd_six;
                    seg = 8'b1011_1110;
                end
            else if (sw7)
                begin
                    reg_num = 4'b111;
                    reg_lcd = lcd_sev;
                    seg = 8'b1110_0000;
                end
            else if (sw8)
                begin
                    reg_num = 4'b1000;
                    reg_lcd = lcd_eig;
                    seg = 8'b1111_1110;
                end
            else if (sw9)
                begin
                    reg_num = 4'b1001;
                    reg_lcd = lcd_nin;
                    seg = 8'b1111_0110;
                end
            else if (rst)
                begin
                    reg_lcd = lcd_blk;
                    seg = 8'b0000_0000;
                end
            else if (sw0)
                begin
                    reg_num = 4'b0000;
                    reg_lcd = lcd_zer;
                    seg = 8'b1111_1100;
                end
            // lrd
        end
end

// one shot code
assign sw = sw1 | sw2 | sw3 | sw4 | sw5 | sw6 | sw7 | sw8 | sw9 | sw0 | lrd;
reg reg_os;
assign one_shot = sw & ~reg_os;
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst)
        reg_os = 0;
    else
        reg_os = sw;
end

// switch count
integer cnt_sw;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) cnt_sw = 0;
    else if (one_shot) cnt_sw = cnt_sw + 1;
end


// sum
reg [3:0] reg_num1, reg_num2;
reg reg_num3;
reg [3:0] reg_num4;

reg [7:0] reg_lcd_l1_1, reg_lcd_l1_3, reg_lcd_l1_5, reg_lcd_l1_6;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) 
        begin 
//            reg_lcd = lcd_blk; 
            reg_lcd_l1_1 = lcd_blk; 
            reg_lcd_l1_3 = lcd_blk;
            reg_lcd_l1_5 = lcd_blk;
            reg_lcd_l1_6 = lcd_blk;
            
            reg_num1 = 4'b0000;
            reg_num2 = 4'b0000;

        end
    else
        begin
            if (cnt_sw == 1) 
                begin
                    reg_lcd_l1_1 = reg_lcd;
                    reg_num1 = reg_num;
                end
            else if (cnt_sw == 2)
                begin
                    reg_lcd_l1_3 = reg_lcd;
                    reg_num2 = reg_num;

                    if(reg_num1 + reg_num2 >= 5'b01010) 
                        begin
                            reg_lcd_l1_5 = lcd_one;
                            reg_num3 = 1'b1;
                            
                            case(reg_num1 + reg_num2 - 5'b01010)
                                0:  begin
                                        reg_lcd_l1_6 = lcd_zer;
                                        reg_num4 = 4'b0000;
                                    end
                                1:  begin
                                        reg_lcd_l1_6 = lcd_one;
                                        reg_num4 = 4'b0001;
                                    end
                                2:  begin
                                        reg_lcd_l1_6 = lcd_two;
                                        reg_num4 = 4'b0010;
                                    end
                                3:  begin
                                        reg_lcd_l1_6 = lcd_thr;
                                        reg_num4 = 4'b0011;
                                    end
                                4:  begin
                                        reg_lcd_l1_6 = lcd_fou;
                                        reg_num4 = 4'b0100;
                                    end
                                5:  begin
                                        reg_lcd_l1_6 = lcd_fiv;
                                        reg_num4 = 4'b0101;
                                    end
                                6:  begin
                                        reg_lcd_l1_6 = lcd_six;
                                        reg_num4 = 4'b0110;
                                    end
                                7:  begin
                                        reg_lcd_l1_6 = lcd_sev;
                                        reg_num4 = 4'b0111;
                                    end
                                8:  begin
                                        reg_lcd_l1_6 = lcd_eig;
                                        reg_num4 = 4'b1000;
                                    end
                                9:  begin
                                        reg_lcd_l1_6 = lcd_nin;
                                        reg_num4 = 4'b1001;
                                    end
                            endcase
                        end
                    else 
                        begin
                            reg_lcd_l1_5 = lcd_zer;
                            reg_num3 = 1'b0;
                            
                            case(reg_num1 + reg_num2)
                                0:  begin
                                        reg_lcd_l1_6 = lcd_zer;
                                        reg_num4 = 4'b0000;
                                    end
                                1:  begin
                                        reg_lcd_l1_6 = lcd_one;
                                        reg_num4 = 4'b0001;
                                    end
                                2:  begin
                                        reg_lcd_l1_6 = lcd_two;
                                        reg_num4 = 4'b0010;
                                    end
                                3:  begin
                                        reg_lcd_l1_6 = lcd_thr;
                                        reg_num4 = 4'b0011;
                                    end
                                4:  begin
                                        reg_lcd_l1_6 = lcd_fou;
                                        reg_num4 = 4'b0100;
                                    end
                                5:  begin
                                        reg_lcd_l1_6 = lcd_fiv;
                                        reg_num4 = 4'b0101;
                                    end
                                6:  begin
                                        reg_lcd_l1_6 = lcd_six;
                                        reg_num4 = 4'b0110;
                                    end
                                7:  begin
                                        reg_lcd_l1_6 = lcd_sev;
                                        reg_num4 = 4'b0111;
                                    end
                                8:  begin
                                        reg_lcd_l1_6 = lcd_eig;
                                        reg_num4 = 4'b1000;
                                    end
                                9:  begin
                                        reg_lcd_l1_6 = lcd_nin;
                                        reg_num4 = 4'b1001;
                                    end
                            endcase
                        end

                end
        end
end





// count
reg [2:0] state;
integer cnt;
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
                delay :     if (cnt == 70) state = function_set;
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
                        lcd_rs = 1'b0;  lcd_rw = 1'b0; lcd_data = 8'b00001100;
                    end
                line1 :
                    begin
                        lcd_rw = 1'b0;
                        
                        case (cnt)
                            0 : begin
                                    lcd_rs = 1'b0;  
                                    lcd_data = 8'b10000000;
                                end
                            1 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_1;
                                end
                            2 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = lcd_sum;
                                end
                            3 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_3;
                                end
                            4 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = lcd_equ;
                                end
                            5 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_5;
                                end
                            6 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_6;
                                end
                            default : begin
                                            lcd_rs = 1'b1; lcd_rw = 1'b0;   lcd_data = lcd_blk;
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
                                    lcd_rs = 1'b1; lcd_data = 8'b00100000; 
                                end
                        endcase
                    end                        
                delay_t :
                    begin
                        lcd_rs = 1'b0; lcd_rw = 1'b0; lcd_data = 89'b00000010;
                    end
                clear_disp :
                    begin
                        lcd_rs = 1'b1; lcd_rw = 1'b1; lcd_data = 8'b00000000;
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