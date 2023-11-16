module calculator1 (sw, led, seg, rst, clk, lcd_e, lcd_rs, lcd_rw, lcd_data);

input rst, clk;
output lcd_e, lcd_rs, lcd_rw;

input [11:0] sw;
output [3:0] led;
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

        zero = 8'b0011_0000,
        one = 8'b0011_0001,
        two = 8'b0011_0010,
        three = 8'b0011_0011,
        four = 8'b0011_0100,
        five = 8'b0011_0101,
        six = 8'b0011_0110,
        seven = 8'b0011_0111,
        eight = 8'b0011_1000,
        nine = 8'b0011_1001,
        
        plus = 8'b0010_1011,
        sub = 8'b0010_1101,
        mul = 8'b1101_0111,
        div = 8'b1111_0111,
        equ = 8'b0011_1101,
        
        blank = 8'b0010_0000;

integer cnt;
integer cnt_100hz;
reg clk_100hz;

integer swcnt;


// 건들이면 안 됨
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


//
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin led = 4'b0000; seg = 8'b0000_0000; reg_temp = blank; end
    else
        begin
              if (sw == 12'b0000_0000_0000) led = 4'b0000; 
              else if (sw == 12'b1000_0000_0000) begin led = 4'b0000; seg = 8'b1111_1100; reg_temp = zero; end // 0
              else if (sw == 12'b0100_0000_0000) begin led = 4'b0001; seg = 8'b0110_0000; reg_temp = one; end // 1
              else if (sw == 12'b0010_0000_0000) begin led = 4'b0010; seg = 8'b1101_1010; reg_temp = two; end // 2
              else if (sw == 12'b0001_0000_0000) begin led = 4'b0011; seg = 8'b1111_0010; reg_temp = three; end // 3
              else if (sw == 12'b0000_1000_0000) begin led = 4'b0100; seg = 8'b0110_0110; reg_temp = four; end // 4
              else if (sw == 12'b0000_0100_0000) begin led = 4'b0101; seg = 8'b1011_0110; reg_temp = five; end // 5
              else if (sw == 12'b0000_0010_0000) begin led = 4'b0110; seg = 8'b1011_1110; reg_temp = six; end // 6
              else if (sw == 12'b0000_0001_0000) begin led = 4'b0111; seg = 8'b1110_0000; reg_temp = seven; end // 7
              else if (sw == 12'b0000_0000_1000) begin led = 4'b1000; seg = 8'b1111_1110; reg_temp = eight; end // 8
              else if (sw == 12'b0000_0000_0100) begin led = 4'b1001; seg = 8'b1111_0110; reg_temp = nine; end // 9
              else if (sw == 12'b0000_0000_0010) begin led = 4'b0000; seg = 8'b1111_1110; reg_temp = blank; end // rst
              else if (sw == 12'b0000_0000_0001) begin led = 4'b1111; seg = 8'b1111_1110; reg_temp = blank; end // rst
              
//              case (sw)
//                12'b1000_0000_0000 : begin led = 4'b0000; seg = 8'b1111_1100; reg_temp = zero; end // 0
//                12'b0100_0000_0000 : begin led = 4'b0001; seg = 8'b0110_0000; reg_temp = one; end // 1
//                12'b0010_0000_0000 : begin led = 4'b0010; seg = 8'b1101_1010; reg_temp = two; end // 2
//                12'b0001_0000_0000 : begin led = 4'b0011; seg = 8'b1111_0010; reg_temp = three; end // 3
//                12'b0000_1000_0000 : begin led = 4'b0100; seg = 8'b0110_0110; reg_temp = four; end // 4
//                12'b0000_0100_0000 : begin led = 4'b0101; seg = 8'b1011_0110; reg_temp = five; end // 5
//                12'b0000_0010_0000 : begin led = 4'b0110; seg = 8'b1011_1110; reg_temp = six; end // 6
//                12'b0000_0001_0000 : begin led = 4'b0111; seg = 8'b1110_0000; reg_temp = seven; end // 7
//                12'b0000_0000_1000 : begin led = 4'b1000; seg = 8'b1111_1110; reg_temp = eight; end // 8
//                12'b0000_0000_0100 : begin led = 4'b1001; seg = 8'b1111_0110; reg_temp = nine; end // 9
//                12'b0000_0000_0010 : begin led = 4'b0000; seg = 8'b1111_1110; reg_temp = blank; end // rst
//                12'b0000_0000_0001 : begin led = 4'b1111; seg = 8'b1111_1110; reg_temp = blank; end // rst
//                default : led = 4'b0000;
//              endcase
        end
end
//

always @(posedge rst or posedge clk_100hz)
begin
    if (rst) swcnt = 0;
    else if (swcnt >= 2) swcnt = 0;
    else if (sw) swcnt = swcnt + 1;
end

always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_temp = blank;
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
                                    lcd_rs = 1'b1;  lcd_data = plus;
                                end
                            3 : begin
                                    lcd_rs = 1'b1;  lcd_data = reg_temp2;
                                end
                            4 : begin
                                    lcd_rs = 1'b1;  lcd_data = equ;
                                end
                            5 : begin
                                    lcd_rs = 1'b1;  lcd_data = blank;
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