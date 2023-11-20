module calculator (
    input [11:0] swp,
    input [7:0] swd,
    input rst, clk, 

    output reg [7:0] seg,
    output reg [7:0] led,
    
    output wire lcd_e,
    output reg lcd_rs, lcd_rw, 
    output reg [7:0] lcd_data
);

// constant
parameter 
        delay           = 3'b000,
        function_set    = 3'b001,
        entry_mode      = 3'b010,
        disp_onoff      = 3'b011,
        line1           = 3'b100,
        line2           = 3'b101,
        delay_t         = 3'b110,
        clear_disp      = 3'b111,

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
        
        ascii_sum = 8'b0010_1011,
        ascii_sub = 8'b0010_1101,
        ascii_mul = 8'b1101_0111,
        ascii_div = 8'b1111_0111,
        ascii_exp = 8'b0101_1110,
        ascii_lpr = 8'b0010_1000,
        ascii_rpr = 8'b0010_1001,
        ascii_equ = 8'b0011_1101,
        
        ascii_blk = 8'b0010_0000,
        ascii_lar = 8'b0001_0001,

	 	sum = 8'b1000_0000,
        sub = 8'b0100_0000,
        mul = 8'b0010_0000,
        div = 8'b0001_0000,
		exp = 8'b0000_1000,
        lpr = 8'b0000_0100,
        rpr = 8'b0000_0010,
        equ = 8'b0000_0001;


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

// state machine
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        state <= delay;
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

// push switch
reg [3:0] reg_num;
reg [7:0] reg_lcd_swp;
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin 
            reg_num <= 4'b0000;
            reg_lcd_swp <= ascii_blk; 
            seg <= 8'b0000_0000;
        end
    else
        begin
            case (swp)
                12'b1000_0000_0000 : 
                    begin
                        reg_num <= 4'b0001;
                        reg_lcd_swp <= ascii_1;
                        seg <= 8'b0110_0000;
                    end
                12'b0100_0000_0000 :
                    begin
                        reg_num <= 4'b0010;
                        reg_lcd_swp <= ascii_2;
                        seg <= 8'b1101_1010;
                    end
                12'b0010_0000_0000 :
                    begin
                        reg_num <= 4'b0011;
                        reg_lcd_swp <= ascii_3;
                        seg <= 8'b1111_0010;
                    end
                12'b0001_0000_0000 :
                    begin
                        reg_num <= 4'b0100;
                        reg_lcd_swp <= ascii_4;
                        seg <= 8'b0110_0110;
                    end
                12'b0000_1000_0000 :
                    begin
                        reg_num <= 4'b0101;
                        reg_lcd_swp <= ascii_5;
                        seg <= 8'b1011_0110;
                    end
                12'b0000_0100_0000 :
                    begin
                        reg_num <= 4'b0110;
                        reg_lcd_swp <= ascii_6;
                        seg <= 8'b1011_1110;
                    end
                12'b0000_0010_0000 :
                    begin
                        reg_num <= 4'b111;
                        reg_lcd_swp <= ascii_7;
                        seg <= 8'b1110_0000;
                    end
                12'b0000_0001_0000 :
                    begin
                        reg_num <= 4'b1000;
                        reg_lcd_swp <= ascii_8;
                        seg <= 8'b1111_1110;
                    end
                12'b0000_0000_1000 :
                    begin
                        reg_num <= 4'b1001;
                        reg_lcd_swp <= ascii_9;
                        seg <= 8'b1111_0110;
                    end
                12'b0000_0000_0010 :
                    begin
                        reg_num <= 4'b0000;
                        reg_lcd_swp <= ascii_0;
                        seg <= 8'b1111_1100;
                    end
            endcase
        end
end

// dip switch
reg [7:0] reg_opr;
reg [7:0] reg_lcd_swd;
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin 
            reg_opr <= sum; // logic 상 그럼
            reg_lcd_swd <= ascii_blk; 
            led <= 8'b0000_0000; 
        end
    else
        begin
            case (swd)
                8'b1000_0000 : 
                    begin 
                        reg_opr <= sum;
                        reg_lcd_swd <= ascii_sum;   
                        led <= 8'b1000_0000;  
                    end 
                8'b0100_0000 : 
                    begin 
                        reg_opr <= sub;
                        reg_lcd_swd <= ascii_sub;    
                        led <= 8'b0100_0000; 
                    end 
                8'b0010_0000 : 
                    begin 
                        reg_opr <= mul;
                        reg_lcd_swd <= ascii_mul;    
                        led <= 8'b0010_0000; 
                    end 
                8'b0001_0000 : 
                    begin 
                        reg_opr <= div;
                        reg_lcd_swd <= ascii_div;    
                        led <= 8'b0001_0000; 
                    end 
                8'b0000_1000 : 
                    begin 
                        reg_opr <= exp;
                        reg_lcd_swd <= ascii_exp;   
                        led <= 8'b0000_1000;  
                    end 
                8'b0000_0100 : 
                    begin 
                        reg_opr <= lpr;
                        reg_lcd_swd <= ascii_lpr;    
                        led <= 8'b0000_0100; 
                    end 
                8'b0000_0010 : 
                    begin 
                        reg_opr <= rpr;
                        reg_lcd_swd <= ascii_rpr;    
                        led <= 8'b0000_0010; 
                    end 
                8'b0000_0001 : 
                    begin 
                        reg_opr <= equ;
                        reg_lcd_swd <= ascii_equ;    
                        led <= 8'b0000_0001; 
                    end 
            endcase
        end
end

// push switch one shot code 
wire pul_swp;
wire pul_swp_os;
reg [1:0] reg_swp;
assign pul_swp =    (swp == 12'b1000_0000_0000) |
                    (swp == 12'b0100_0000_0000) |
                    (swp == 12'b0010_0000_0000) |
                    (swp == 12'b0001_0000_0000) |
                    (swp == 12'b0000_1000_0000) |
                    (swp == 12'b0000_0100_0000) |
                    (swp == 12'b0000_0010_0000) |
                    (swp == 12'b0000_0001_0000) |
                    (swp == 12'b0000_0000_1000) |
                    (swp == 12'b0000_0000_0010);
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swp <= 2'b00;
    else reg_swp <= {reg_swp[0], pul_swp};
end
assign pul_swp_os = reg_swp[0] & ~reg_swp[1];

// dip switch one shot code
wire pul_swd;
wire pul_swd_os;
reg [1:0] reg_swd;
assign pul_swd =    (swd == 8'b1000_0000) |
                    (swd == 8'b0100_0000) |
                    (swd == 8'b0010_0000) |
                    (swd == 8'b0001_0000) |
                    (swd == 8'b0000_1000) |
                    (swd == 8'b0000_0100) |
                    (swd == 8'b0000_0010) |
                    (swd == 8'b0000_0001);
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swd <= 2'b00;
    else reg_swd <= {reg_swd[0], pul_swd};
end
assign pul_swd_os = reg_swd[0] & ~reg_swd[1];



// push switch one shot code 2
assign pul_swp2 =   (swp == 12'b1000_0000_0000) |
                    (swp == 12'b0100_0000_0000) |
                    (swp == 12'b0010_0000_0000) |
                    (swp == 12'b0001_0000_0000) |
                    (swp == 12'b0000_1000_0000) |
                    (swp == 12'b0000_0100_0000) |
                    (swp == 12'b0000_0010_0000) |
                    (swp == 12'b0000_0001_0000) |
                    (swp == 12'b0000_0000_1000) |
                    (swp == 12'b0000_0000_0010);
reg reg_swp2;
assign pul_swp_os2 = pul_swp2 & ~reg_swp2;
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swp2 = 0;
    else reg_swp2 = pul_swp2;
end

// dip switch one shot code 2
assign pul_swd2 =   (swd == 8'b1000_0000) |
                    (swd == 8'b0100_0000) |
                    (swd == 8'b0010_0000) |
                    (swd == 8'b0001_0000) |
                    (swd == 8'b0000_1000) |
                    (swd == 8'b0000_0100) |
                    (swd == 8'b0000_0010) |
                    (swd == 8'b0000_0001);
reg reg_swd2;
assign pul_swd_os2 = pul_swd2 & ~reg_swd2;
always@ (posedge rst or posedge clk_100hz)
begin
    if (rst) reg_swd2 = 0;
    else reg_swd2 = pul_swd2;
end










// term
// summation and substraction operation
// reg [31:0] reg_trm;
// reg [31:0] reg_rlt;
// always @(posedge rst or posedge clk_100hz)
// begin
//     if (rst) 
//         begin
//             reg_trm     <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
//             reg_rlt  <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
//         end
//     else if (pul_swd_os)
//         begin
//             case (reg_opr)
//                 sum : reg_rlt <= reg_rlt + reg_trm;
//                 sub : reg_rlt <= reg_rlt - reg_trm;
//             endcase
//             reg_trm <= 0;
//         end
//     else if (pul_swp_os) reg_trm <= 10 * reg_trm + reg_num;
// end
// term
reg [31:0] reg_trm;
always @(posedge rst or posedge clk_100hz)
begin
   if (rst) reg_trm <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
   else if (pul_swp_os) reg_trm <= 10 * reg_trm + reg_num; // 반드시 후위 os를 사용해야 함 - 다른 걸로 하면 term 자체를 인식 못함
   else if (pul_swd_os) reg_trm <= 0;
end

// summation and subtraction operation
reg [31:0] reg_rlt;
always @(posedge rst or posedge clk_100hz)
begin
   if (rst) reg_rlt <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
   else if (pul_swd_os2) // 반드시 전위 os를 사용해야 함 - 다른 걸로 하면 result가 달라짐
       begin
           case (reg_opr)
               sum : reg_rlt <= reg_rlt + reg_trm;
               sub : reg_rlt <= reg_rlt - reg_trm;
           endcase
       end
end





// 
reg [7:0] reg_lcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_lcd <= ascii_blk;
    else if (pul_swp_os) reg_lcd <= reg_lcd_swp;
    else if (pul_swd_os) reg_lcd <= reg_lcd_swd;
end

// count lcd position
integer cnt_lcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) cnt_lcd <= 0;
    else if (pul_swp_os | pul_swd_os) cnt_lcd <= cnt_lcd + 1;
end

// lcd assignment
reg [7:0]
        reg_lcd_l1_01,
        reg_lcd_l1_02,
        reg_lcd_l1_03,
        reg_lcd_l1_04,
        reg_lcd_l1_05,
        reg_lcd_l1_06,
        reg_lcd_l1_07,
        reg_lcd_l1_08,
        reg_lcd_l1_09,
        reg_lcd_l1_10,
        reg_lcd_l1_11,
        reg_lcd_l1_12,
        reg_lcd_l1_13,
        reg_lcd_l1_14,
        reg_lcd_l1_15,
        reg_lcd_l1_16,

        reg_lcd_l2_01,
        reg_lcd_l2_02,
        reg_lcd_l2_03,
        reg_lcd_l2_04,
        reg_lcd_l2_05,
        reg_lcd_l2_06,
        reg_lcd_l2_07,
        reg_lcd_l2_08,
        reg_lcd_l2_09,
        reg_lcd_l2_10,
        reg_lcd_l2_11,
        reg_lcd_l2_12,
        reg_lcd_l2_13,
        reg_lcd_l2_14,
        reg_lcd_l2_15,
        reg_lcd_l2_16;
reg [31:0] reg_result_neg;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
        begin
            reg_lcd_l1_01 = ascii_blk;
            reg_lcd_l1_02 = ascii_blk;
            reg_lcd_l1_03 = ascii_blk;
            reg_lcd_l1_04 = ascii_blk;
            reg_lcd_l1_05 = ascii_blk;
            reg_lcd_l1_06 = ascii_blk;
            reg_lcd_l1_07 = ascii_blk;
            reg_lcd_l1_08 = ascii_blk;
            reg_lcd_l1_09 = ascii_blk;
            reg_lcd_l1_10 = ascii_blk;
            reg_lcd_l1_11 = ascii_blk;
            reg_lcd_l1_12 = ascii_blk;
            reg_lcd_l1_13 = ascii_blk;
            reg_lcd_l1_14 = ascii_blk;
            reg_lcd_l1_15 = ascii_blk;
            reg_lcd_l1_16 = ascii_blk;

            reg_lcd_l2_01 = ascii_blk;
            reg_lcd_l2_02 = ascii_blk;
            reg_lcd_l2_03 = ascii_blk;
            reg_lcd_l2_04 = ascii_blk;
            reg_lcd_l2_05 = ascii_blk;
            reg_lcd_l2_06 = ascii_blk;
            reg_lcd_l2_07 = ascii_blk;
            reg_lcd_l2_08 = ascii_blk;
            reg_lcd_l2_09 = ascii_blk;
            reg_lcd_l2_10 = ascii_blk;
            reg_lcd_l2_11 = ascii_blk;
            reg_lcd_l2_12 = ascii_blk;
            reg_lcd_l2_13 = ascii_blk;
            reg_lcd_l2_14 = ascii_blk;
            reg_lcd_l2_15 = ascii_blk;
            reg_lcd_l2_16 = ascii_blk;
        end
    else if (swd == 8'b0000_0001) // result
        begin
            if (reg_rlt >= 32'b1000_0000_0000_0000_0000_0000_0000_0000) // negative
                begin
                    reg_result_neg = ~(reg_rlt - 32'd1);

                    if (reg_result_neg < 32'd10)
                        begin
                            reg_lcd_l2_15 = ascii_sub;
                            case (reg_result_neg)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase
                        end
                    else if (reg_result_neg < 32'd100)
                        begin
                            reg_lcd_l2_14 = ascii_sub;
                            case (reg_result_neg % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_result_neg / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase        
                        end
                    else if (reg_result_neg < 32'd1000)
                        begin
                            reg_lcd_l2_13 = ascii_sub;
                            case (reg_result_neg % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_result_neg % 32'd100 / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase 

                            case (reg_result_neg / 32'd100)
                                0 : reg_lcd_l2_14 = ascii_0;
                                1 : reg_lcd_l2_14 = ascii_1;
                                2 : reg_lcd_l2_14 = ascii_2;
                                3 : reg_lcd_l2_14 = ascii_3;
                                4 : reg_lcd_l2_14 = ascii_4;
                                5 : reg_lcd_l2_14 = ascii_5;
                                6 : reg_lcd_l2_14 = ascii_6;
                                7 : reg_lcd_l2_14 = ascii_7;
                                8 : reg_lcd_l2_14 = ascii_8;
                                9 : reg_lcd_l2_14 = ascii_9;
                            endcase 
                        end
                    else if (reg_result_neg < 32'd10000)
                        begin
                            reg_lcd_l2_12 <= ascii_sub;
                            case (reg_result_neg % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_result_neg % 32'd100 / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase 

                            case (reg_result_neg % 32'd1000 / 32'd100)
                                0 : reg_lcd_l2_14 = ascii_0;
                                1 : reg_lcd_l2_14 = ascii_1;
                                2 : reg_lcd_l2_14 = ascii_2;
                                3 : reg_lcd_l2_14 = ascii_3;
                                4 : reg_lcd_l2_14 = ascii_4;
                                5 : reg_lcd_l2_14 = ascii_5;
                                6 : reg_lcd_l2_14 = ascii_6;
                                7 : reg_lcd_l2_14 = ascii_7;
                                8 : reg_lcd_l2_14 = ascii_8;
                                9 : reg_lcd_l2_14 = ascii_9;
                            endcase

                            case (reg_result_neg / 32'd1000)
                                0 : reg_lcd_l2_13 = ascii_0;
                                1 : reg_lcd_l2_13 = ascii_1;
                                2 : reg_lcd_l2_13 = ascii_2;
                                3 : reg_lcd_l2_13 = ascii_3;
                                4 : reg_lcd_l2_13 = ascii_4;
                                5 : reg_lcd_l2_13 = ascii_5;
                                6 : reg_lcd_l2_13 = ascii_6;
                                7 : reg_lcd_l2_13 = ascii_7;
                                8 : reg_lcd_l2_13 = ascii_8;
                                9 : reg_lcd_l2_13 = ascii_9;
                            endcase
                        end
                    else if (reg_result_neg < 32'd100000)
                        begin
                            reg_lcd_l2_11 <= ascii_sub;
                            case (reg_result_neg % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_result_neg % 32'd100 / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase 

                            case (reg_result_neg % 32'd1000 / 32'd100)
                                0 : reg_lcd_l2_14 = ascii_0;
                                1 : reg_lcd_l2_14 = ascii_1;
                                2 : reg_lcd_l2_14 = ascii_2;
                                3 : reg_lcd_l2_14 = ascii_3;
                                4 : reg_lcd_l2_14 = ascii_4;
                                5 : reg_lcd_l2_14 = ascii_5;
                                6 : reg_lcd_l2_14 = ascii_6;
                                7 : reg_lcd_l2_14 = ascii_7;
                                8 : reg_lcd_l2_14 = ascii_8;
                                9 : reg_lcd_l2_14 = ascii_9;
                            endcase

                            case (reg_result_neg % 32'd10000 / 32'd1000)
                                0 : reg_lcd_l2_13 = ascii_0;
                                1 : reg_lcd_l2_13 = ascii_1;
                                2 : reg_lcd_l2_13 = ascii_2;
                                3 : reg_lcd_l2_13 = ascii_3;
                                4 : reg_lcd_l2_13 = ascii_4;
                                5 : reg_lcd_l2_13 = ascii_5;
                                6 : reg_lcd_l2_13 = ascii_6;
                                7 : reg_lcd_l2_13 = ascii_7;
                                8 : reg_lcd_l2_13 = ascii_8;
                                9 : reg_lcd_l2_13 = ascii_9;
                            endcase

                            case (reg_result_neg / 32'd10000)
                                0 : reg_lcd_l2_12 = ascii_0;
                                1 : reg_lcd_l2_12 = ascii_1;
                                2 : reg_lcd_l2_12 = ascii_2;
                                3 : reg_lcd_l2_12 = ascii_3;
                                4 : reg_lcd_l2_12 = ascii_4;
                                5 : reg_lcd_l2_12 = ascii_5;
                                6 : reg_lcd_l2_12 = ascii_6;
                                7 : reg_lcd_l2_12 = ascii_7;
                                8 : reg_lcd_l2_12 = ascii_8;
                                9 : reg_lcd_l2_12 = ascii_9;
                            endcase
                        end
                end
            else // positive
                begin
                    if (reg_rlt < 32'd10)
                        begin
                            case (reg_rlt)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase
                        end
                    else if (reg_rlt < 32'd100)
                        begin
                            case (reg_rlt % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_rlt / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase        
                        end
                    else if (reg_rlt < 32'd1000)
                        begin
                            case (reg_rlt % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_rlt % 32'd100 / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase 

                            case (reg_rlt / 32'd100)
                                0 : reg_lcd_l2_14 = ascii_0;
                                1 : reg_lcd_l2_14 = ascii_1;
                                2 : reg_lcd_l2_14 = ascii_2;
                                3 : reg_lcd_l2_14 = ascii_3;
                                4 : reg_lcd_l2_14 = ascii_4;
                                5 : reg_lcd_l2_14 = ascii_5;
                                6 : reg_lcd_l2_14 = ascii_6;
                                7 : reg_lcd_l2_14 = ascii_7;
                                8 : reg_lcd_l2_14 = ascii_8;
                                9 : reg_lcd_l2_14 = ascii_9;
                            endcase 
                        end
                    else if (reg_rlt < 32'd10000)
                        begin
                            case (reg_rlt % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_rlt % 32'd100 / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase 

                            case (reg_rlt % 32'd1000 / 32'd100)
                                0 : reg_lcd_l2_14 = ascii_0;
                                1 : reg_lcd_l2_14 = ascii_1;
                                2 : reg_lcd_l2_14 = ascii_2;
                                3 : reg_lcd_l2_14 = ascii_3;
                                4 : reg_lcd_l2_14 = ascii_4;
                                5 : reg_lcd_l2_14 = ascii_5;
                                6 : reg_lcd_l2_14 = ascii_6;
                                7 : reg_lcd_l2_14 = ascii_7;
                                8 : reg_lcd_l2_14 = ascii_8;
                                9 : reg_lcd_l2_14 = ascii_9;
                            endcase

                            case (reg_rlt / 32'd1000)
                                0 : reg_lcd_l2_13 = ascii_0;
                                1 : reg_lcd_l2_13 = ascii_1;
                                2 : reg_lcd_l2_13 = ascii_2;
                                3 : reg_lcd_l2_13 = ascii_3;
                                4 : reg_lcd_l2_13 = ascii_4;
                                5 : reg_lcd_l2_13 = ascii_5;
                                6 : reg_lcd_l2_13 = ascii_6;
                                7 : reg_lcd_l2_13 = ascii_7;
                                8 : reg_lcd_l2_13 = ascii_8;
                                9 : reg_lcd_l2_13 = ascii_9;
                            endcase
                        end
                    else if (reg_rlt < 32'd100000)
                        begin
                            case (reg_rlt % 32'd10)
                                0 : reg_lcd_l2_16 = ascii_0;
                                1 : reg_lcd_l2_16 = ascii_1;
                                2 : reg_lcd_l2_16 = ascii_2;
                                3 : reg_lcd_l2_16 = ascii_3;
                                4 : reg_lcd_l2_16 = ascii_4;
                                5 : reg_lcd_l2_16 = ascii_5;
                                6 : reg_lcd_l2_16 = ascii_6;
                                7 : reg_lcd_l2_16 = ascii_7;
                                8 : reg_lcd_l2_16 = ascii_8;
                                9 : reg_lcd_l2_16 = ascii_9;
                            endcase

                            case (reg_rlt % 32'd100 / 32'd10)
                                0 : reg_lcd_l2_15 = ascii_0;
                                1 : reg_lcd_l2_15 = ascii_1;
                                2 : reg_lcd_l2_15 = ascii_2;
                                3 : reg_lcd_l2_15 = ascii_3;
                                4 : reg_lcd_l2_15 = ascii_4;
                                5 : reg_lcd_l2_15 = ascii_5;
                                6 : reg_lcd_l2_15 = ascii_6;
                                7 : reg_lcd_l2_15 = ascii_7;
                                8 : reg_lcd_l2_15 = ascii_8;
                                9 : reg_lcd_l2_15 = ascii_9;
                            endcase 

                            case (reg_rlt % 32'd1000 / 32'd100)
                                0 : reg_lcd_l2_14 = ascii_0;
                                1 : reg_lcd_l2_14 = ascii_1;
                                2 : reg_lcd_l2_14 = ascii_2;
                                3 : reg_lcd_l2_14 = ascii_3;
                                4 : reg_lcd_l2_14 = ascii_4;
                                5 : reg_lcd_l2_14 = ascii_5;
                                6 : reg_lcd_l2_14 = ascii_6;
                                7 : reg_lcd_l2_14 = ascii_7;
                                8 : reg_lcd_l2_14 = ascii_8;
                                9 : reg_lcd_l2_14 = ascii_9;
                            endcase

                            case (reg_rlt % 32'd10000 / 32'd1000)
                                0 : reg_lcd_l2_13 = ascii_0;
                                1 : reg_lcd_l2_13 = ascii_1;
                                2 : reg_lcd_l2_13 = ascii_2;
                                3 : reg_lcd_l2_13 = ascii_3;
                                4 : reg_lcd_l2_13 = ascii_4;
                                5 : reg_lcd_l2_13 = ascii_5;
                                6 : reg_lcd_l2_13 = ascii_6;
                                7 : reg_lcd_l2_13 = ascii_7;
                                8 : reg_lcd_l2_13 = ascii_8;
                                9 : reg_lcd_l2_13 = ascii_9;
                            endcase

                            case (reg_rlt / 32'd10000)
                                0 : reg_lcd_l2_12 = ascii_0;
                                1 : reg_lcd_l2_12 = ascii_1;
                                2 : reg_lcd_l2_12 = ascii_2;
                                3 : reg_lcd_l2_12 = ascii_3;
                                4 : reg_lcd_l2_12 = ascii_4;
                                5 : reg_lcd_l2_12 = ascii_5;
                                6 : reg_lcd_l2_12 = ascii_6;
                                7 : reg_lcd_l2_12 = ascii_7;
                                8 : reg_lcd_l2_12 = ascii_8;
                                9 : reg_lcd_l2_12 = ascii_9;
                            endcase
                        end
                end
        end
    else // input
        begin
            if (cnt_lcd <= 16)
                begin
                    case (cnt_lcd)
                        1 :     reg_lcd_l1_01 <= reg_lcd;
                        2 :     reg_lcd_l1_02 <= reg_lcd;
                        3 :     reg_lcd_l1_03 <= reg_lcd;
                        4 :     reg_lcd_l1_04 <= reg_lcd;
                        5 :     reg_lcd_l1_05 <= reg_lcd;
                        6 :     reg_lcd_l1_06 <= reg_lcd;
                        7 :     reg_lcd_l1_07 <= reg_lcd;
                        8 :     reg_lcd_l1_08 <= reg_lcd;
                        9 :     reg_lcd_l1_09 <= reg_lcd;
                        10 :    reg_lcd_l1_10 <= reg_lcd;
                        11 :    reg_lcd_l1_11 <= reg_lcd;
                        12 :    reg_lcd_l1_12 <= reg_lcd;
                        13 :    reg_lcd_l1_13 <= reg_lcd;
                        14 :    reg_lcd_l1_14 <= reg_lcd;
                        15 :    reg_lcd_l1_15 <= reg_lcd;
                        16 :    reg_lcd_l1_16 <= reg_lcd;
                    endcase
                end
            // else
            //     begin
            //         reg_lcd_l1_01 <= ascii_lar;
            //         reg_lcd_l1_02 <= reg_lcd_l1_03;
            //         reg_lcd_l1_03 <= reg_lcd_l1_04;
            //         reg_lcd_l1_04 <= reg_lcd_l1_05;
            //         reg_lcd_l1_05 <= reg_lcd_l1_06;
            //         reg_lcd_l1_06 <= reg_lcd_l1_07;
            //         reg_lcd_l1_07 <= reg_lcd_l1_08;
            //         reg_lcd_l1_08 <= reg_lcd_l1_09;
            //         reg_lcd_l1_09 <= reg_lcd_l1_10;
            //         reg_lcd_l1_10 <= reg_lcd_l1_11;
            //         reg_lcd_l1_11 <= reg_lcd_l1_12;
            //         reg_lcd_l1_12 <= reg_lcd_l1_13;
            //         reg_lcd_l1_13 <= reg_lcd_l1_14;
            //         reg_lcd_l1_14 <= reg_lcd_l1_15;
            //         reg_lcd_l1_16 <= reg_lcd;
            //     end
        end
end

// lcd output
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
                        lcd_rs = 1'b0; 
                        lcd_rw = 1'b0; 
                        lcd_data = 8'b00111100;
                    end
                disp_onoff :
                    begin
                        lcd_rs = 1'b0; 
                        lcd_rw = 1'b0; 
                        lcd_data = 8'b00001100;
                    end
                entry_mode :
                    begin
                        lcd_rs = 1'b0;  
                        lcd_rw = 1'b0; 
                        lcd_data = 8'b00001100;
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
                                    lcd_data = reg_lcd_l1_01;
                                end
                            2 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_02;
                                end
                            3 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_03;
                                end
                            4 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_04;
                                end
                            5 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_05;
                                end
                            6 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_06;
                                end
                            7 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_07;
                                end
                            8 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_08;
                                end
                            9 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_09;
                                end
                            10 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_10;
                                end
                            11 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_11;
                                end
                            12 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_12;
                                end
                            13 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_13;
                                end
                            14 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_14;
                                end
                            15 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_15;
                                end
                            16 : begin
                                    lcd_rs = 1'b1;  
                                    lcd_data = reg_lcd_l1_16;
                                end
                            default : begin
                                            lcd_rs = 1'b1;   
                                            lcd_data = 8'b00000001;
                                      end
                        endcase
                    end
                line2 :
                    begin
                        lcd_rw = 1'b0;

                        case (cnt)
                            0 : begin
                                    lcd_rs = 1'b0; 
                                    lcd_data = 8'b11000000;
                                end
                            1 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_01;
                                end
                            2 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_02;
                                end
                            3 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_03;
                                end
                            4 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_04;
                                end
                            5 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_05;
                                end
                            6 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_06;
                                end
                            7 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_07;
                                end
                            8 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_08;
                                end
                            9 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_09;
                                end
                            10 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_10;
                                end
                            11 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_11;
                                end
                            12 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_12;
                                end
                            13 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_13;
                                end
                            14 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_14;
                                end
                            15 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_15;
                                end
                            16 : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = reg_lcd_l2_16;
                                end
                            default : begin
                                    lcd_rs = 1'b1; 
                                    lcd_data = 8'b00100000; 
                                end
                        endcase
                    end                        
                delay_t :
                    begin
                        lcd_rs = 1'b0; 
                        lcd_rw = 1'b0; 
                        lcd_data = 89'b00000010;
                    end
                clear_disp :
                    begin
                        lcd_rs = 1'b1; 
                        lcd_rw = 1'b1; 
                        lcd_data = 8'b00000000;
                    end
                default :
                    begin
                        lcd_rs = 1'b1;  
                        lcd_rw = 1'b1;  
                        lcd_data = 8'b00000000;
                    end
            endcase
        end
end

assign lcd_e = clk_100hz;

endmodule
