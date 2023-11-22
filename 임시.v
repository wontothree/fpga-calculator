// reg [63:0] reg_rlt_bcd

// lcd position passignment
reg [8*16-1 : 0] reg_lcd_l1;
reg [8*16-1 : 0] reg_lcd_l2;

reg [31:0] reg_result_neg;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin
            for (i = 0; i < 16; i = i + 1) begin 
                reg_lcd_l1[8*i +: 8] <= ascii_blk; 
                reg_lcd_l2[8*i +: 8] <= ascii_blk;
            end
        end
    else if (swd == 8'b0000_0001) // result
        begin
            if (reg_rlt >= 32'b1000_0000_0000_0000_0000_0000_0000_0000) // negative
                begin
                    for (i=0; i<16; i+=1) begin
                        case (reg_rlt_bcd[8*i +: 8])
                            0 : reg_lcd_l2[8*i +: 8] <= ascii_0;
                            1 : reg_lcd_l2[8*i +: 8] <= ascii_1;
                            2 : reg_lcd_l2[8*i +: 8] <= ascii_2;
                            3 : reg_lcd_l2[8*i +: 8] <= ascii_3;
                            4 : reg_lcd_l2[8*i +: 8] <= ascii_4;
                            5 : reg_lcd_l2[8*i +: 8] <= ascii_5;
                            6 : reg_lcd_l2[8*i +: 8] <= ascii_6;
                            7 : reg_lcd_l2[8*i +: 8] <= ascii_7;
                            8 : reg_lcd_l2[8*i +: 8] <= ascii_8;
                            9 : reg_lcd_l2[8*i +: 8] <= ascii_9;
                        endcase
                    end
                end
            else // positive
                begin
                    for (i=0; i<16; i+=1) begin
                        case (reg_rlt_bcd[8*i +: 8])
                            0 : reg_lcd_l2[8*i +: 8] <= ascii_0;
                            1 : reg_lcd_l2[8*i +: 8] <= ascii_1;
                            2 : reg_lcd_l2[8*i +: 8] <= ascii_2;
                            3 : reg_lcd_l2[8*i +: 8] <= ascii_3;
                            4 : reg_lcd_l2[8*i +: 8] <= ascii_4;
                            5 : reg_lcd_l2[8*i +: 8] <= ascii_5;
                            6 : reg_lcd_l2[8*i +: 8] <= ascii_6;
                            7 : reg_lcd_l2[8*i +: 8] <= ascii_7;
                            8 : reg_lcd_l2[8*i +: 8] <= ascii_8;
                            9 : reg_lcd_l2[8*i +: 8] <= ascii_9;
                        endcase
                    end
                end
        end
    else // input
        begin
            if (cnt_lcd <= 16)
                begin
                    case (cnt_lcd)
                        1 :     reg_lcd_l1[8*0 +: 8] <= reg_lcd;
                        2 :     reg_lcd_l1[8*1 +: 8] <= reg_lcd;
                        3 :     reg_lcd_l1[8*2 +: 8] <= reg_lcd;
                        4 :     reg_lcd_l1[8*3 +: 8] <= reg_lcd;
                        5 :     reg_lcd_l1[8*4 +: 8] <= reg_lcd;
                        6 :     reg_lcd_l1[8*5 +: 8] <= reg_lcd;
                        7 :     reg_lcd_l1[8*6 +: 8] <= reg_lcd;
                        8 :     reg_lcd_l1[8*7 +: 8] <= reg_lcd;
                        9 :     reg_lcd_l1[8*8 +: 8] <= reg_lcd;
                        10 :    reg_lcd_l1[8*9 +: 8] <= reg_lcd;
                        11 :    reg_lcd_l1[8*10 +: 8] <= reg_lcd;
                        12 :    reg_lcd_l1[8*11 +: 8] <= reg_lcd;
                        13 :    reg_lcd_l1[8*12 +: 8] <= reg_lcd;
                        14 :    reg_lcd_l1[8*13 +: 8] <= reg_lcd;
                        15 :    reg_lcd_l1[8*14 +: 8] <= reg_lcd;
                        16 :    reg_lcd_l1[8*15 +: 8] <= reg_lcd;
                    endcase
                end
            else
                begin
                    reg_lcd_l1 <= reg_lcd_l1 << 8;
                    reg_lcd_l1[8*0 +: 8] <= ascii_lar;
                    reg_lcd_l1[8*15 +: 8] <= reg_lcd;
                end
        end
end

// lcd output
always@(posedge rst or posedge clk_100hz)
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
                        lcd_rs <= 1'b0; 
                        lcd_rw <= 1'b0; 
                        lcd_data <= 8'b00111100;
                    end
                disp_onoff :
                    begin
                        lcd_rs <= 1'b0; 
                        lcd_rw <= 1'b0; 
                        lcd_data <= 8'b00001100;
                    end
                entry_mode :
                    begin
                        lcd_rs <= 1'b0;  
                        lcd_rw <= 1'b0; 
                        lcd_data <= 8'b00001100;
                    end
                line1 :
                    begin
                        lcd_rw <= 1'b0;
                        
                        case (cnt)
                            0 : begin
                                    lcd_rs <= 1'b0;  
                                    lcd_data <= 8'b10000000;
                                end
                            1 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*0 +: 8];
                                end
                            2 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*1 +: 8];
                                end
                            3 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*2 +: 8];
                                end
                            4 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*3 +: 8];
                                end
                            5 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*4 +: 8];
                                end
                            6 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*5 +: 8];
                                end
                            7 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*6 +: 8];
                                end
                            8 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*7 +: 8];
                                end
                            9 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*8 +: 8];
                                end
                            10 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*9 +: 8];
                                end
                            11 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*10 +: 8];
                                end
                            12 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*11 +: 8];
                                end
                            13 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*12 +: 8];
                                end
                            14 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*13 +: 8];
                                end
                            15 : begin
                                    lcd_rs <= 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*14 +: 8];
                                end
                            16 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data <= reg_lcd_l1[8*15 +: 8];
                                end
                            default : begin
                                    lcd_rs <= 1'b1;   
                                    lcd_data <= 8'b00000001;
                                end
                        endcase
                    end
                line2 :
                    begin
                        lcd_rw <= 1'b0;

                        case (cnt)
                            0 : begin
                                    lcd_rs <= 1'b0; 
                                    lcd_data <= 8'b11000000;
                                end
                            1 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*0 +: 8];
                                end
                            2 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*1 +: 8];
                                end
                            3 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*2 +: 8];
                                end
                            4 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*3 +: 8];
                                end
                            5 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*4 +: 8];
                                end
                            6 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*5 +: 8];
                                end
                            7 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*6 +: 8];
                                end
                            8 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*7 +: 8];
                                end
                            9 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*8 +: 8];
                                end
                            10 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*9 +: 8];
                                end
                            11 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*10 +: 8];
                                end
                            12 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*11 +: 8];
                                end
                            13 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*12 +: 8];
                                end
                            14 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*13 +: 8];
                                end
                            15 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*14 +: 8];
                                end
                            16 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*15 +: 8];
                                end
                            default : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= 8'b00100000; 
                                end
                        endcase
                    end                        
                delay_t :
                    begin
                        lcd_rs <= 1'b0; 
                        lcd_rw <= 1'b0; 
                        lcd_data <= 89'b00000010;
                    end
                clear_disp :
                    begin
                        lcd_rs <= 1'b1; 
                        lcd_rw <= 1'b1; 
                        lcd_data <= 8'b00000000;
                    end
                default :
                    begin
                        lcd_rs <= 1'b1;  
                        lcd_rw <= 1'b1;  
                        lcd_data <= 8'b00000000;
                    end
            endcase
        end
end