module calculator (
    input swp1, swp2, swp3, swp4, swp5, swp6, swp7, swp8, swp9, rst, swp0, lrd,
    input swd1, swd2, swd3, swd4, swd5, swd6, swd7, swd8,
    input clk, 

    output reg [7:0] seg,
    output reg [7:0] led,
    
    output wire lcd_e,
    output reg lcd_rs, lcd_rw, 
    output reg [7:0] lcd_data
);

// constant
parameter 
        ascii_0 = 8'b0011_0000,
        ascii_1 = 8'b0011_0001,
        ascii_2 = 8'b0011_0010,
        ascii_3 = 8'b0011_0011,
        ascii_4 = 8'b0011_0100,
        ascii_5 = 8'b0011_0101,
        ascii_6 = 8'b0011_0110,
        ascii_7 = 8'b0011_0111,
        ascii_8 = 8'b0011_1000,
        ascii_9 = 8'b0011_1001,
        
        ascii_min = 8'b0010_1101,
        ascii_sum = 8'b0010_1011,
        ascii_sub = 8'b0010_1101,
        ascii_mul = 8'b1101_0111, // 01111000
        ascii_div = 8'b1111_0111, // 0010_0101
        ascii_lpr = 8'b0010_1000,
        ascii_rpr = 8'b0010_1001,
        ascii_equ = 8'b0011_1101, 
        
        ascii_blk = 8'b0010_0000,
        ascii_lar = 8'b0001_0001,

        min = 3'b000,
        sum = 3'b001,
        sub = 3'b010,
        mul = 3'b011,
        div = 3'b100,
        lpr = 3'b101,
        rpr = 3'b110,
        equ = 3'b111;

// clock divider
integer cnt_100hz;
reg clk_100hz;
always @(posedge rst or posedge clk)
begin
    if (rst)
        begin
            cnt_100hz <= 0;  
            clk_100hz <= 1'b0;
        end
    else if (cnt_100hz >= 4)
        begin
            cnt_100hz <= 0; 
            clk_100hz <= ~clk_100hz;
        end
    else
        cnt_100hz <= cnt_100hz + 1;
end

// push switch
reg [3:0] reg_num;
reg [7:0] reg_num_ascii; // reg_lcd_swp
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin 
        reg_num <= 4'b0000;
        reg_num_ascii <= ascii_blk; 
        seg <= 8'b0000_0000;
    end
    else
    begin
        if (swp1)
        begin
            reg_num <= 4'b0001;
            reg_num_ascii <= ascii_1;
            seg <= 8'b0110_0000;
        end
        else if (swp2)
        begin
            reg_num <= 4'b0010;
            reg_num_ascii <= ascii_2;
            seg <= 8'b1101_1010;
        end
        else if (swp3)
        begin
            reg_num <= 4'b0011;
            reg_num_ascii <= ascii_3;
            seg <= 8'b1111_0010;
        end
        else if (swp4)
        begin
            reg_num <= 4'b0100;
            reg_num_ascii <= ascii_4;
            seg <= 8'b0110_0110;
         end
        else if (swp5)
        begin
            reg_num <= 4'b0101;
            reg_num_ascii <= ascii_5;
            seg <= 8'b1011_0110;
        end
        else if (swp6)
        begin
            reg_num <= 4'b0110;
            reg_num_ascii <= ascii_6;
            seg <= 8'b1011_1110;
        end
        else if (swp7)
        begin
            reg_num <= 4'b111;
            reg_num_ascii <= ascii_7;
            seg <= 8'b1110_0000;
        end
        else if (swp8)
        begin
            reg_num <= 4'b1000;
            reg_num_ascii <= ascii_8;
            seg <= 8'b1111_1110;
        end
        else if (swp9)
        begin
            reg_num <= 4'b1001;
            reg_num_ascii <= ascii_9;
            seg <= 8'b1111_0110;
        end
        else if (swp0)
        begin
            reg_num <= 4'b0000;
            reg_num_ascii <= ascii_0;
            seg <= 8'b1111_1100;
        end
    end
end

// dip switch
reg reg_trm_sgn;
reg [7:0] reg_opr;
reg [7:0] reg_opr_ascii; // reg_lcd_swd
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin 
        reg_opr <= sum; // sum
        reg_opr_ascii <= ascii_blk; 
        led <= 0; 
    end
    else
    begin
        if (swd1)
        begin 
            reg_trm_sgn <= 1;
            reg_opr_ascii <= ascii_min;
            led <= 8'b1000_0000;  
        end 
        else if (swd2)
        begin 
            reg_opr <= sum;
            reg_opr_ascii <= ascii_sum;    
            led <= 8'b0100_0000; 
        end 
        else if (swd3)
        begin 
            reg_opr <= sub;
            reg_opr_ascii <= ascii_sub;    
            led <= 8'b0010_0000; 
        end 
        else if (swd4)
        begin 
            reg_opr <= mul;
            reg_opr_ascii <= ascii_mul;    
            led <= 8'b0001_0000; 
        end 
        else if (swd5)
        begin 
            reg_opr <= div;
            reg_opr_ascii <= ascii_div;   
            led <= 8'b0000_1000;  
        end 
        else if (swd6)
        begin 
            reg_opr <= lpr;
            reg_opr_ascii <= ascii_lpr;    
            led <= 8'b0000_0100; 
        end 
        else if (swd7)
        begin 
            reg_opr <= rpr;
            reg_opr_ascii <= ascii_rpr;    
            led <= 8'b0000_0010; 
        end 
        else if (swd8)
        begin 
            reg_opr <= equ;
            reg_opr_ascii <= ascii_equ;    
            led <= 8'b0000_0001; 
        end 
    end
end

// Push switch preceding one shot code
reg reg_swp_pre;

wire swp;
wire swp_os_pre;
assign swp = swp1 | swp2 | swp3 | swp4 | swp5 | swp6 | swp7 | swp8 | swp9 | swp0;
assign swp_os_pre = swp & ~reg_swp_pre;

always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swp_pre <= 0;
    else reg_swp_pre <= swp;
end

// Push switch post one shot code
reg [1:0] reg_swp_pst;

wire swp_os_pst;
assign swp_os_pst = reg_swp_pst[0] & ~reg_swp_pst[1];

always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swp_pst <= 2'b00;
    else reg_swp_pst <= {reg_swp_pst[0], swp};
end

// Dip switch preceding one shot code
reg reg_swd_pre;

wire swd;
wire swd_os_pre;
assign swd = swd1 | swd2 | swd3 | swd4 | swd5 | swd6 | swd7 | swd8;
assign swd_os_pre = swd & ~reg_swd_pre;

always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swd_pre <= 0;
    else reg_swd_pre <= swd;
end

// Dip switch preceding one shot code
reg [1:0] reg_swd_pst;

wire swd_os_pst;
assign swd_os_pst = reg_swd_pst[0] & ~reg_swd_pst[1];

assign swd = swd1 | swd2 | swd3 | swd4 | swd5 | swd6 | swd7 | swd8;
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swd_pst <= 2'b00;
    else reg_swd_pst <= {reg_swd_pst[0], swd};
end

// Term
reg [31:0] reg_trm_mgn;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) 
    begin 
        reg_trm_sgn <= 0;
        reg_trm_mgn <= 0;
    end
    else if (swp_os_pst) 
    begin
        // if (reg_opr == min) reg_trm_sgn <= 1;
        reg_trm_mgn <= 10 * reg_trm_mgn + reg_num; // using post one shot code
    end
    else if (swd_os_pst) 
    begin 
        reg_trm_sgn <= 0;
        reg_trm_mgn <= 0;
    end
end

// Term
reg [31:0] reg_trm;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_trm <= 0;
    else if (swd_os_pre && reg_trm_sgn == 1) reg_trm <= ~reg_trm_mgn + 1;
    else reg_trm <= reg_trm_mgn;
end

// Operation
reg [31:0] reg_rlt;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_rlt <= 0;
    else if (reg_trm_sgn) // negative
    begin
        if (swd_os_pst)
        begin
           case (reg_opr)
               sum : reg_rlt <= reg_rlt + reg_trm;
               sub : reg_rlt <= reg_rlt - reg_trm;
               mul : reg_rlt <= reg_rlt * reg_trm;
               div : reg_rlt <= reg_rlt / reg_trm;
           endcase
        end
    end
    else // positvie
    begin
        if (swd_os_pre) // swd_os_pre
        begin
           case (reg_opr)
               sum : reg_rlt <= reg_rlt + reg_trm;
               sub : reg_rlt <= reg_rlt - reg_trm;
               mul : reg_rlt <= reg_rlt * reg_trm;
               div : reg_rlt <= reg_rlt / reg_trm;
           endcase
        end
    end
end

// lcd reg
reg [7:0] reg_lcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_lcd <= ascii_blk;
    else if (swp_os_pst) reg_lcd <= reg_num_ascii;
    else if (swd_os_pst) reg_lcd <= reg_opr_ascii;
end

// lcd position count
integer cnt_lcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) cnt_lcd <= 0;
    else if (swp_os_pst | swd_os_pst) cnt_lcd <= cnt_lcd + 1;
end

// Sign-magnitude form
reg reg_rlt_sgn;
reg [31:0] reg_rlt_mgn;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) 
    begin 
        reg_rlt_sgn <= 0;
        reg_rlt_mgn <= 0;
    end
    else if (swd8 == 1) //equ
    begin
        if (reg_rlt >= 32'b1000_0000_0000_0000_0000_0000_0000_0000) // negative
        begin 
            reg_rlt_mgn <= ~(reg_rlt - 1);
            reg_rlt_sgn <= 1;
        end
        else reg_rlt_mgn <= reg_rlt; // positive
    end
end

// Sifnal flow control - count order
integer cnt_ord;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) cnt_ord <= 0;
    else if (swd8) cnt_ord <= cnt_ord + 1;
end

// Binary 2 BCD
reg [39:0] reg_rlt_bcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_rlt_bcd <= 0;
    else if (cnt_ord >= 10 && cnt_ord < 42)
    begin
        if (reg_rlt_bcd[3:0] >= 4'b0101) reg_rlt_bcd[3:0] = reg_rlt_bcd[3:0] + 3;
        if (reg_rlt_bcd[7:4] >= 4'b0101) reg_rlt_bcd[7:4] = reg_rlt_bcd[7:4] + 3;
        if (reg_rlt_bcd[11:8] >= 4'b0101) reg_rlt_bcd[11:8] = reg_rlt_bcd[11:8] + 3;
        if (reg_rlt_bcd[15:12] >= 4'b0101) reg_rlt_bcd[15:12] = reg_rlt_bcd[15:12] + 3;
        if (reg_rlt_bcd[19:16] >= 4'b0101) reg_rlt_bcd[19:16] = reg_rlt_bcd[19:16] + 3;
        if (reg_rlt_bcd[23:20] >= 4'b0101) reg_rlt_bcd[23:20] = reg_rlt_bcd[23:20] + 3;
        if (reg_rlt_bcd[27:24] >= 4'b0101) reg_rlt_bcd[27:24] = reg_rlt_bcd[27:24] + 3;
        if (reg_rlt_bcd[31:28] >= 4'b0101) reg_rlt_bcd[31:28] = reg_rlt_bcd[31:28] + 3;
        reg_rlt_bcd <= {reg_rlt_bcd[38:0], reg_rlt_mgn[31+10-cnt_ord]};
    end
end

// lcd position assignment - input
reg [8*16-1 : 0] reg_lcd_l1;
integer i;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) 
    begin
        for (i = 0; i < 16; i = i + 1) 
            reg_lcd_l1[8*i +: 8] <= ascii_blk; 
    end
    else if (cnt_lcd >= 1 && cnt_lcd <= 16) reg_lcd_l1[8*(cnt_lcd-1) +: 8] <= reg_lcd;
    else if (swp_os_pre | swd_os_pre) reg_lcd_l1 <= {reg_lcd, reg_lcd_l1[127:16], ascii_lar}; // infinite input
end

// lcd position assignment - result
reg [8*16-1 : 0] reg_lcd_l2;
integer is_msd, cnt_blk;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        for (i = 0; i < 16; i = i + 1) 
        begin 
            reg_lcd_l2[8*i +: 8] <= ascii_blk;
            is_msd <= 0;
            cnt_blk <= 0;
        end
    end
    else if (cnt_ord)
    begin
        if (cnt_ord >= 50 && cnt_ord < 60)
        begin
            if (reg_rlt_bcd[4*(59-cnt_ord) +: 4] == 0 && is_msd == 0) 
            begin 
                reg_lcd_l2[8*(59-cnt_ord) +: 8] <= ascii_blk;
                cnt_blk <= cnt_blk + 1;
            end
            else
            begin
                reg_lcd_l2[8*(59-cnt_ord) +: 8] <= ascii_0 + reg_rlt_bcd[4*(59-cnt_ord) +: 4];
                is_msd <= 1;
            end
        end
        else if (cnt_ord == 60)
        begin
            if (reg_rlt_sgn) reg_lcd_l2[8*(10-cnt_blk) +: 8] <= ascii_sub;
        end
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

parameter
        delay           = 3'b000,
        function_set    = 3'b001,
        entry_mode      = 3'b010,
        disp_onoff      = 3'b011,
        line1           = 3'b100,
        line2           = 3'b101,
        delay_t         = 3'b110,
        clear_disp      = 3'b111;

// count
integer cnt;
reg [2:0] state;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
        cnt <= 0;
    else
        begin
            case (state)
                delay :
                    if (cnt >= 70) cnt <= 0;
                    else cnt <= cnt + 1;
                function_set :
                    if (cnt >= 30) cnt <= 0;
                    else cnt <= cnt + 1;
                disp_onoff :
                    if (cnt >= 30) cnt <= 0;
                    else cnt <= cnt + 1;
                entry_mode :
                    if (cnt >= 30) cnt <= 0;
                    else cnt <= cnt + 1;
                line1 :
                    if (cnt >= 20) cnt <= 0;
                    else cnt <= cnt + 1;
                line2 :
                    if (cnt >= 20) cnt <= 0;
                    else cnt <= cnt + 1;
                delay_t :
                    if (cnt >= 400) cnt <= 0;
                    else cnt <= cnt + 1;
                clear_disp :
                    if (cnt >= 200) cnt <= 0;
                    else cnt <= cnt + 1;
                default : cnt <= 0;
            endcase
        end
end

// state machine
always@(posedge rst or posedge clk_100hz)
begin
    if (rst) state = delay;
    else
    begin
        case (state)
            delay :             if (cnt == 70)  state <= function_set;
            function_set :      if (cnt == 30)  state <= disp_onoff;
            disp_onoff :        if (cnt == 30)  state <= entry_mode;
            entry_mode :        if (cnt == 30)  state <= line1;
            line1 :             if (cnt == 20)  state <= line2;
            line2 :             if (cnt == 20)  state <= delay_t;
            delay_t :           if (cnt == 400) state <= clear_disp;
            clear_disp :        if (cnt == 200) state <= line1;
            default :                           state <= delay;
        endcase
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
                                    lcd_data <= reg_lcd_l2[8*15 +: 8];
                                end
                            2 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*14 +: 8];
                                end
                            3 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*13 +: 8];
                                end
                            4 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*12 +: 8];
                                end
                            5 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*11 +: 8];
                                end
                            6 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*10 +: 8];
                                end
                            7 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*9 +: 8];
                                end
                            8 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*8 +: 8];
                                end
                            9 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*7 +: 8];
                                end
                            10 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*6 +: 8];
                                end
                            11 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*5 +: 8];
                                end
                            12 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*4 +: 8];
                                end
                            13 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*3 +: 8];
                                end
                            14 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*2 +: 8];
                                end
                            15 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*1 +: 8];
                                end
                            16 : begin
                                    lcd_rs <= 1'b1; 
                                    lcd_data <= reg_lcd_l2[8*0 +: 8];
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

assign lcd_e = clk_100hz;

endmodule
