module textlcd (
    input rst, clk,
    input wire [7:0] reg_lcd_l1_1, reg_lcd_l1_2, reg_lcd_l1_3, reg_lcd_l1_4, reg_lcd_l1_5, reg_lcd_l1_6, reg_lcd_l1_7, reg_lcd_l1_8, reg_lcd_l1_9, reg_lcd_l1_10, reg_lcd_l1_11, reg_lcd_l1_12, reg_lcd_l1_13, reg_lcd_l1_14, reg_lcd_l1_15, reg_lcd_l1_16,
    input wire [7:0] reg_lcd_l2_1, reg_lcd_l2_2, reg_lcd_l2_3, reg_lcd_l2_4, reg_lcd_l2_5, reg_lcd_l2_6, reg_lcd_l2_7, reg_lcd_l2_8, reg_lcd_l2_9, reg_lcd_l2_10, reg_lcd_l2_11, reg_lcd_l2_12, reg_lcd_l2_13, reg_lcd_l2_14, reg_lcd_l2_15, reg_lcd_l2_16,
    output lcd_e,
    output reg lcd_rs, lcd_rw,
    output reg [7:0] lcd_data
);
reg [2:0] state;
integer cnt;

parameter 
        delay        = 3'b000,
        function_set = 3'b001,
        entry_mode   = 3'b010,
        disp_onoff   = 3'b011,
        line1        = 3'b100,
        line2        = 3'b101,
        delay_t      = 3'b110,
        clear_disp   = 3'b111,
        
        lcd_blk = 8'b0010_0000;


// count
always @(posedge rst or posedge clk)
begin
    if (rst)
        cnt <= 0;
    else
        begin
            case (state)
                delay :
                    if (cnt >= 70) cnt = 0;
                    else cnt <= cnt + 1;
                function_set :
                    if (cnt >= 30) cnt = 0;
                    else cnt <= cnt + 1;
                disp_onoff :
                    if (cnt >= 30) cnt = 0;
                    else cnt <= cnt + 1;
                entry_mode :
                    if (cnt >= 30) cnt = 0;
                    else cnt <= cnt + 1;
                line1 :
                    if (cnt >= 20) cnt = 0;
                    else cnt <= cnt + 1;
                line2 :
                    if (cnt >= 20) cnt = 0;
                    else cnt <= cnt + 1;
                delay_t :
                    if (cnt >= 400) cnt = 0;
                    else cnt <= cnt + 1;
                clear_disp :
                    if (cnt >= 200) cnt = 0;
                    else cnt <= cnt + 1;
                default : cnt <= 0;
            endcase
        end
end

// state
always@(posedge rst or posedge clk)
begin
    if (rst)
        state <= delay;
    else
        begin
            case (state)
                delay :         if (cnt == 70)  state <= function_set;
                function_set :  if (cnt == 30)  state <= disp_onoff;
                disp_onoff :    if (cnt == 30)  state <= entry_mode;
                entry_mode :    if (cnt == 30)  state <= line1;
                line1 :         if (cnt == 20)  state <= line2;
                line2 :         if (cnt == 20)  state <= delay_t;
                delay_t :       if (cnt == 400) state <= clear_disp;
                clear_disp :    if (cnt == 200) state <= line1;
                default :                       state <= delay;
            endcase
        end
end


always@(posedge rst or posedge clk)
begin
    if (rst)
        begin
            lcd_rs <= 1'b1;
            lcd_rw <= 1'b1;
            lcd_data <= 8'b00000000;
        end
    else
        begin
            case (state)
                function_set :
                    begin
                        lcd_rs <= 1'b0; lcd_rw <= 1'b0; lcd_data <= 8'b00111100;
                    end
                disp_onoff :
                    begin
                        lcd_rs <= 1'b0; lcd_rw <= 1'b0; lcd_data <= 8'b00001100;
                    end
                entry_mode :
                    begin
                        lcd_rs <= 1'b0;  lcd_rw <= 1'b0; lcd_data <= 8'b00000110;
                    end
                line1 :
                    begin
                        lcd_rw = 1'b0; 
                        
                        case (cnt)
                            0 : begin
                                    lcd_rs <= 1'b0;  lcd_data <= 8'b10000000;
                                end
                            1 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_1;
                                end
                            2 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_2;
                                end
                            3 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_3;
                                end
                            4 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_4;
                                end
                            5 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_5;
                                end
                            6 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_6;
                                end
                            7 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_7;
                                end
                            8 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_8;
                                end
                            9 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_9;
                                end
                            10 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_10;
                                end
                            11 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_11;
                                end
                            12 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_12;
                                end
                            13 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_13;
                                end
                            14 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_14;
                                end
                            15 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_15;
                                end
                            16 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l1_16;
                                end
                            default : begin
                                            lcd_rs <= 1'b1;  lcd_data <= lcd_blk;
                                      end
                        endcase
                    end
                line2 :
                    begin
                        lcd_rw <= 1'b0;

                        case (cnt)
                            0 : begin
                                    lcd_rs <= 1'b0;  lcd_data <= 8'b10000000;
                                end
                            1 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_1;
                                end
                            2 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_2;
                                end
                            3 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_3;
                                end
                            4 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_4;
                                end
                            5 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_5;
                                end
                            6 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_6;
                                end
                            7 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_7;
                                end
                            8 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_8;
                                end
                            9 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_9;
                                end
                            10 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_10;
                                end
                            11 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_11;
                                end
                            12 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_12;
                                end
                            13 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_13;
                                end
                            14 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_14;
                                end
                            15 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_15;
                                end
                            16 : begin
                                    lcd_rs <= 1'b1;  lcd_data <= reg_lcd_l2_16;
                                end
                            default : begin
                                            lcd_rs <= 1'b1;  lcd_data <= lcd_blk;
                                      end
                        endcase
                    end                        
                delay_t :
                    begin
                        lcd_rs <= 1'b0; lcd_rw <= 1'b0; lcd_data <= 8'b00000010;
                    end
                clear_disp :
                    begin
                        lcd_rs <= 1'b0; lcd_rw <= 1'b0; lcd_data <= 8'b00000001;
                    end
                default :
                    begin
                        lcd_rs <= 1'b1;  lcd_rw <= 1'b1;  lcd_data <= 8'b00000000;
                    end
            endcase
        end
end

assign lcd_e = clk;

endmodule