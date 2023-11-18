module textlcd(
    input swp1, swp2, swp3, swp4, swp5, swp6, swp7, swp8, swp9, rst, swp0, lrd,
    input [7:0] swd,
    input clk, 

    output reg [7:0] seg,
    output reg [7:0] led,
    
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


// push switch one shot code
assign pulse_swp = swp1 | swp2 | swp3 | swp4 | swp5 | swp6 | swp7 | swp8 | swp9 | swp0 | lrd;
reg reg_swp_os;
assign pulse_swp_os = pulse_swp & ~reg_swp_os;
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst)
        reg_swp_os = 0;
    else
        reg_swp_os = pulse_swp;
end

// push switch count
integer cnt_swp;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) cnt_swp = 0;
    else if (pulse_swp_os) cnt_swp = cnt_swp + 1;
end

// dip switch one shot code
assign pulse_swd = (swd == 8'b1000_0000) | (swd == 8'b0100_0000) | (swd == 8'b0010_0000) | (swd == 8'b0001_0000) | (swd == 8'b0000_1000) | (swd == 8'b0000_0010) | (swd == 8'b00000001);
reg reg_swd_os;
assign pulse_swd_os = pulse_swd & ~reg_swd_os;
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst)
        reg_swd_os = 0;
    else
        reg_swd_os = pulse_swd;
end

// dip switch count
integer cnt_swd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) cnt_swd = 0;
    else if (pulse_swd_os) cnt_swd = cnt_swd + 1;
end




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

// count
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
reg [2:0] state;
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
                                    lcd_rs = 1'b0;  lcd_data = 8'b10000000;
                                end
                            1 : begin
                                    lcd_rs = 1'b1;  lcd_data = 8'b00100000;
                                end
                            2 : begin
                                    lcd_rs = 1'b1;  lcd_data = 8'b01001000; // H
                                end
                            3 : begin
                                    lcd_rs = 1'b1;  lcd_data = 8'b01100101; // e
                                end
                            4 : begin
                                    lcd_rs = 1'b1;  lcd_data = 8'b01101100; // l
                                end
                            5 : begin
                                    lcd_rs = 1'b1;  lcd_data = 8'b01101100; // l
                                end
                            6 : begin
                                    lcd_rs = 1'b1;  lcd_data = 8'b01101111; // o
                                end
                            default : begin
                                            lcd_rs = 1'b1; lcd_rw = 1'b0;   lcd_data = 8'b00000001;
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
                                    lcd_rs = 1'b1; lcd_data = 8'b01110010; //r
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