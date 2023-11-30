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
        ascii_mul = 8'b0111_1000,
        ascii_div = 8'b1111_1101,
        ascii_lpr = 8'b0010_1000,
        ascii_rpr = 8'b0010_1001,
        ascii_equ = 8'b0011_1101, 
        
        ascii_blk = 8'b0010_0000,
        ascii_lar = 8'b0001_0001,

        min = 4'b0000, // 0
        lpr = 4'b0001, // 1
        rpr = 4'b0010, // 2
        sum = 4'b0101, // 5
        sub = 4'b0110, // 6
        mul = 4'b1001, // 9
        div = 4'b1010, // 10
        equ = 4'b1011; // 11

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
        reg_trm_sgn <= 0;
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
            // reg_opr <= equ;
            reg_opr_ascii <= ascii_equ; 
            led <= 8'b0000_0001; 
        end 
    end
end

// one shot code of operand
wire os_perand;
reg [1:0] reg_os_operand;
assign sw_operand = swp0 | swp1 | swp2 | swp3 | swp4 | swp5 | swp6 | swp7 | swp8 | swp9 | swd1;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_os_operand <= 2'b00;
    else reg_os_operand <= {reg_os_operand[0], sw_operand};
end

assign os_operand = reg_os_operand[0] & ~reg_os_operand[1];


// one shot code of operator
wire os_operator;
reg [1:0] reg_os_operator;
assign sw_operator = swd2 | swd3 | swd4 | swd5 | swd6 | swd7;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_os_operator <= 2'b00;
    else reg_os_operator <= {reg_os_operator[0], sw_operator};
end

assign os_operator = reg_os_operator[0] & ~reg_os_operator[1];


// State transition
parameter 
        init        = 4'b00,
        operand     = 4'b01,
        operator    = 4'b10,
        result      = 4'b11;

reg [2:0] state_calc;
always@(posedge rst or posedge clk_100hz)
begin
    if (rst) state_calc <= init;
    else
    begin
        case (state_calc)
            init :  if (os_operand) state_calc <= operand;
            operand : 
            begin 
                if (swd8) state_calc <= result;
                else if (os_operator) state_calc <= operator;
            end
            operator : if (os_operand) state_calc <= operand;
        endcase
    end
end

reg en_operand, en_operator, en_result;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        en_operand <= 0;
        en_operator <= 0;
        en_result <= 0;
    end
    else
    begin
        case (state_calc)
            operand : 
            begin 
                en_operand <= 1;
                en_operator <= 0;
                en_result <= 0;
            end
            operator : 
            begin 
                en_operand <= 0;
                en_operator <= 1;
                en_result <= 0;
            end
            result : 
            begin 
                en_operand <= 0;
                en_operator <= 0;
                en_result <= 1;
            end
        endcase
    end
end

integer cnt_operand, cnt_operator, cnt_result;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        cnt_operand <= 0;
        cnt_operator <= 0;
        cnt_result <= 0;
    end
    else if (en_operand) 
    begin 
        cnt_operand <= cnt_operand + 1;
        cnt_operator <= 0;
        cnt_result <= 0;
    end
    else if (en_operator) 
    begin 
        cnt_operand <= 0;
        cnt_operator <= cnt_operator + 1;
        cnt_result <= 0;
    end
    else if (en_result) 
    begin
        cnt_operand <= 0;
        cnt_operator <= 0;
        cnt_result <= cnt_result + 1;
    end
end

// operand
reg [31:0] reg_trm_mgn; // 32 bit
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_trm_mgn <= 0;
    else if (os_operand) reg_trm_mgn <= 10 * reg_trm_mgn + reg_num;
end


parameter
        MAX_QUEUE_SIZE = 16,
        MAX_STACK_SIZE = 8;

reg [3:0] front_inf, rear_inf, front_pof, rear_pof;
reg [2:0] top_inf2pof, top_pof2rlt;

reg signed [31:0] que_inf [0:MAX_QUEUE_SIZE-1]; // 중위식을 저장하는 큐
reg signed [31:0] stk_inf2pof [0:MAX_STACK_SIZE-1]; // 중위식을 후위식으로 변환하기 위한 스택
reg signed [31:0] que_pof [0:MAX_QUEUE_SIZE-1]; // 후위식을 저장하는 큐
reg signed [31:0] stk_pof2rlt [0:MAX_STACK_SIZE-1]; // 후위식을 계산하기 위한 스택

// operator
integer i;
reg [31:0] reg_trm;
reg [31:0] reg_rlt;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        reg_trm <= 0;
        reg_rlt <= 0;
        front_inf <= 0;
        rear_inf <= 0;
        for (i = 0; i < MAX_QUEUE_SIZE; i = i + 1) que_inf[i] <= 0;
    end
    else
    begin
        case (cnt_operator)
            2 : begin // Calculate the reg_trm
                    if (reg_trm_sgn) reg_trm <= ~reg_trm_mgn + 1;
                    else reg_trm <= reg_trm_mgn;
                end
            4 : begin // Insert reg_trm in queue
                    que_inf[rear_inf[3:0]+1] <= reg_trm; 
                    rear_inf <= rear_inf + 1;
                end
            6 : begin // Insert reg_opr in queue
                    que_inf[rear_inf[3:0]+1] <= reg_opr;
                    rear_inf <= rear_inf + 1;
                end
            8 : begin // Accumulate the result
                    case (reg_opr)
                        sum : reg_rlt <= reg_rlt + reg_trm;
                        sub : reg_rlt <= reg_rlt - reg_trm;
                        mul : reg_rlt <= reg_rlt * reg_trm;
                        div : reg_rlt <= reg_rlt / reg_trm;
                    endcase
                end
            10 : begin // Initialize the reg_trm
                    reg_trm_sgn <= 0;
                    reg_trm_mgn <= 0;
                end
        endcase

        case (cnt_result)
            2 : begin // Calculate the reg_trm
                    if (reg_trm_sgn) reg_trm <= ~reg_trm_mgn + 1;
                    else reg_trm <= reg_trm_mgn;
                end
            4 : begin // Insert reg_trm in queue
                    que_inf[rear_inf[3:0]+1] <= reg_trm; 
                    rear_inf <= rear_inf + 1;
                end
            6 : begin // Accumulate the result
                    case (reg_opr)
                        sum : reg_rlt <= reg_rlt + reg_trm;
                        sub : reg_rlt <= reg_rlt - reg_trm;
                        mul : reg_rlt <= reg_rlt * reg_trm;
                        div : reg_rlt <= reg_rlt / reg_trm;
                    endcase
                end
            8 : begin // Initialize the reg_trm
                    reg_trm_sgn <= 0;
                    reg_trm_mgn <= 0;
                end
        endcase
    end 
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 중위식 -> 후위식
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        top_inf2pof <= 0;
        front_pof <= 0;
        rear_pof <= 0;
        for (i = 0; i < MAX_STACK_SIZE; i = i + 1) stk_inf2pof[i] <= 0;
        for (i = 0; i < MAX_QUEUE_SIZE; i = i + 1) que_pof[i] <= 0;
    end
    else if (cnt_result >= 10 && cnt_result < 50)
    begin
        if (front_inf != rear_inf) // not empty
        begin
            if (que_inf[front_inf[3:0]+1] > 4'b1010) // operand
            begin
                que_pof[rear_pof[3:0]+1] <= que_inf[front_inf[3:0]+1]; // Infix que -> post que
                front_inf <= front_inf + 1; // Infix queue pop
                rear_pof <= rear_pof + 1; // Post queue push
            end
            // else if (
            // else if )
            else if (que_inf[front_inf[3:0]+1] <= 4'b1010) // operator
            begin
                if (top_inf2pof == 0) // Stack for transforming infix to postfix is empty
                begin 
                    stk_inf2pof[top_inf2pof[2:0]+1] <= que_inf[front_inf[3:0]+1]; // Infix que -> infix to postfix stack
                    front_inf <= front_inf + 1;
                    top_inf2pof <= top_inf2pof + 1; 
                end
                else
                begin
                    if (stk_inf2pof[top_inf2pof[2:0]] + 1 >= que_inf[front_inf[3:0]+1]) // 스택의 맨 위의 연산자가, 들어오는 연산자보다 우선순위가 높거나 같은 경우
                    begin
                        que_pof[rear_pof[3:0]+1] <= stk_inf2pof[top_inf2pof[2:0]];
                        top_inf2pof <= top_inf2pof + 1;
                        rear_pof <= rear_pof + 1;
                    end
                    else
                    begin
                        stk_inf2pof[top_inf2pof[2:0]+1] <= que_inf[front_inf[3:0]+1];
                        front_inf <= front_inf + 1;
                        top_inf2pof <= top_inf2pof + 1;
                    end
                end
            end
        end
        else // empty
        begin
            if (top_inf2pof != 0)
            begin
                que_pof[rear_pof[3:0]+1] <= stk_inf2pof[top_inf2pof[2:0]];
                top_inf2pof <= top_inf2pof - 1;
                rear_pof <= rear_pof + 1;
            end
        end
    end
end


reg reg_rlt_sgn;
reg [31:0] reg_rlt_mgn;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        reg_rlt_sgn <= 0;
        reg_rlt_mgn <= 0;
    end
    else
    begin
        case (cnt_result)
            50: begin // Sign-magnitude form for bcd code
                    if (reg_rlt >= 32'b1000_0000_0000_0000_0000_0000_0000_0000) // negative
                    begin 
                        reg_rlt_mgn <= ~(reg_rlt - 1);
                        reg_rlt_sgn <= 1;
                    end
                    else reg_rlt_mgn <= reg_rlt; // positive
                end
        endcase
    end 
end

// Binary 2 BCD
parameter start_bcd = 100;
reg [39:0] reg_rlt_bcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_rlt_bcd <= 0;
    else if (cnt_result >= start_bcd && cnt_result < start_bcd + 32)
    begin
        if (reg_rlt_bcd[3:0] >= 4'b0101) reg_rlt_bcd[3:0] = reg_rlt_bcd[3:0] + 3;
        if (reg_rlt_bcd[7:4] >= 4'b0101) reg_rlt_bcd[7:4] = reg_rlt_bcd[7:4] + 3;
        if (reg_rlt_bcd[11:8] >= 4'b0101) reg_rlt_bcd[11:8] = reg_rlt_bcd[11:8] + 3;
        if (reg_rlt_bcd[15:12] >= 4'b0101) reg_rlt_bcd[15:12] = reg_rlt_bcd[15:12] + 3;
        if (reg_rlt_bcd[19:16] >= 4'b0101) reg_rlt_bcd[19:16] = reg_rlt_bcd[19:16] + 3;
        if (reg_rlt_bcd[23:20] >= 4'b0101) reg_rlt_bcd[23:20] = reg_rlt_bcd[23:20] + 3;
        if (reg_rlt_bcd[27:24] >= 4'b0101) reg_rlt_bcd[27:24] = reg_rlt_bcd[27:24] + 3;
        if (reg_rlt_bcd[31:28] >= 4'b0101) reg_rlt_bcd[31:28] = reg_rlt_bcd[31:28] + 3;
        reg_rlt_bcd <= {reg_rlt_bcd[38:0], reg_rlt_mgn[31+start_bcd-cnt_result]};
    end
end

// Result LCD
localparam start_lcd = start_bcd + 32;
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
    else if (cnt_result >= start_lcd && cnt_result < start_lcd+10)
    begin
        if (reg_rlt_bcd[4*(start_lcd+9-cnt_result) +: 4] == 0 && is_msd == 0) 
        begin 
            reg_lcd_l2[8*(start_lcd+9-cnt_result) +: 8] <= ascii_blk;
            cnt_blk <= cnt_blk + 1;
        end
        else
        begin
            reg_lcd_l2[8*(start_lcd+9-cnt_result) +: 8] <= ascii_0 + reg_rlt_bcd[4*(start_lcd+9-cnt_result) +: 4];
            is_msd <= 1;
        end
    end
    else if (cnt_result == start_lcd+11) if (reg_rlt_sgn) reg_lcd_l2[8*(10-cnt_blk) +: 8] <= ascii_sub;
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// LCD reg(input) and lcd position count(input)
reg [7:0] reg_lcd;
integer cnt_lcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) 
    begin 
        reg_lcd <= ascii_blk;
        cnt_lcd <= 0;
    end
    if (os_operand) 
    begin 
        reg_lcd <= reg_num_ascii;
        cnt_lcd <= cnt_lcd + 1;
    end
    if (os_operator) 
    begin 
        reg_lcd <= reg_opr_ascii;
        cnt_lcd <= cnt_lcd + 1;
    end
    if (swd8)
    begin
        // reg_lcd <= reg_opr_ascii; // *************
        cnt_lcd <= cnt_lcd + 1;
    end
end

// lcd position assignment - input
reg [8*16-1 : 0] reg_lcd_l1;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) 
    begin
        for (i = 0; i < 16; i = i + 1) 
            reg_lcd_l1[8*i +: 8] <= ascii_blk; 
    end
    else if (cnt_lcd >= 1 && cnt_lcd <= 16) reg_lcd_l1[8*(cnt_lcd-1) +: 8] <= reg_lcd;
    else if (os_operand | os_operator) reg_lcd_l1 <= {reg_lcd, reg_lcd_l1[127:16], ascii_lar}; // infinite input
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

parameter
        delay           = 3'b000,
        function_set    = 3'b001,
        entry_mode      = 3'b010,
        disp_onoff      = 3'b011,
        line1           = 3'b100,
        line2           = 3'b101,
        delay_t         = 3'b110,
        clear_disp      = 3'b111;

integer cnt;
reg [2:0] state_lcd;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
        cnt <= 0;
    else
        begin
            case (state_lcd)
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

always@(posedge rst or posedge clk_100hz)
begin
    if (rst) state_lcd = delay;
    else
    begin
        case (state_lcd)
            delay :             if (cnt == 70)  state_lcd <= function_set;
            function_set :      if (cnt == 30)  state_lcd <= disp_onoff;
            disp_onoff :        if (cnt == 30)  state_lcd <= entry_mode;
            entry_mode :        if (cnt == 30)  state_lcd <= line1;
            line1 :             if (cnt == 20)  state_lcd <= line2;
            line2 :             if (cnt == 20)  state_lcd <= delay_t;
            delay_t :           if (cnt == 400) state_lcd <= clear_disp;
            clear_disp :        if (cnt == 200) state_lcd <= line1;
            default :                           state_lcd <= delay;
        endcase
    end
end

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
            case (state_lcd)
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

