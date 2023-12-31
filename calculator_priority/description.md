# Description

## Variable

|Declaration|Variable|Description|
|---|---|---|
|input|swp1, swp2, swp3, swp4, swp5, swp6, swp7, swp8, swp9, rst, swp0, lrd,|12개의 푸시 스위치는 0~9의 수와 reset 버튼, 그리고 load 버튼으로 구성된다.|
|input|input swd1, swd2, swd3, swd4, swd5, swd6, swd7, swd8,|음의 부호(-), 사칙연산(+, -, x, %), 왼쪽 괄호, 오른쪽 괄호, 등호(=)|
|input|clk|1Hz ~ 500Mz 진동수를 조절할 수 있다. 여기서는 대략 10kHz를 사용한다.|
|output reg [7:0]|seg|푸시 스위치로 입력된 수를 7-segment에 출력한다.|
|output reg [7:0]|led|딥 스위치로 입력된 연산을 LED에 출력한다.|
|Switch|---|---|
|reg [3:0]|reg_num|눌린 push 스위치에 해당하는 값이 저장된다.|
|reg [7:0]|reg_num_ascii|눌린 push 스위치에 해당하는 아스키 코드가 저장된다.|
|reg [2:0]|reg_opr|눌린 dip 스위치에 해당하는 값이 저장된다.|
|reg [7:0]|reg_opr_ascii|눌린 dip 스위치에 해당하는 아스키 코드가 저장된다.|
|One shot code|---|---|
|assign wire|swp_os_pre|push 스위치가 눌릴 때부터 가장 가까운 상승 에지까지 1이다.|
|assign wire|swp_os_pst|push 스위치가 눌리는 시점에 가장 가까운 상승 에지부터 다음 상승 에지까지 1이다.|
|assign wire|swd_os_pre|dip 스위치가 눌릴 때부터 가장 가까운 상승 에지까지 1이다.|
|assign wire|swd_os_pst|dip 스위치가 눌리는 시점에 가장 가까운 상승 에지부터 다음 상승 에지까지 1이다.|

|Declaration|Variable|Description|
|---|---|---|
|reg |reg_trm_sgn|항의 부호|
|reg [31:0]|reg_trm_mgn|항의 절대값|
|reg [31:0]|reg_trm|항의 값|
|Sign-magnitude form|---|---|
|reg [31:0]|reg_rlt|연산 결과를 저장한다.(입력) / -21_4748_3648 ~ 21_4748_3647의 숫자를 표현할 수 있다.|
|reg |reg_rlt_sgn|reg_rlt의 부호를 저장한다.|
|reg [31:0]|reg_rlt_mag|reg_rlt의 값을 저장한다. reg_rlt와 같은 32비트로 선언된다.|
|BCD transformation|---|---|
|reg [39:0]|reg_rlt_bcd|연산 결과를 bcd로 저장한다.(출력) / LCD line2의 16칸에 들어갈 10진수 값을 위한 코드이다. 1칸 당 상위 4비트에는 0000을 할당하고 하위 4비트에는 bcd를 할당하여, 총 8비트를 할당한다. bcd가 십진수 한 자리 당 4비트인데 반해, 1칸 당 8비트씩 할당하는 이유는 각 자릿수 값에 8'b0011_0000를 더함으로써 바로 ascii 코드로 바꿀 수 있기 때문이다.|
|---|---|---|
|reg [7:0]|reg_lcd|lcd에 띄울 아스키 값이 들어간다. reg_num_ascii 또는 reg_opr_ascii에 들어 있는 8비트 아스키 값이 들어간다.|

### Functional definition and Design specification

- 사칙 연산 : 자연수 → 정수 → 유리수 → 무리수 → 허수
- 무한대로 입력받기
- 가수, 기수, 지수 양식으로 표현하기
- delete button
- shift button을 이용해서 연산자를 push switch로 입력받기
- 커서 이동시키며 수정하기(원형큐)
- 시리얼 통신
- 화살표로 커서 이동시켜서 입력값 수정 기능

### 상태 정의

#### 상위 상태 머신

0. [state0] init <- 초기 상태
1. [state1] operand <- 피연산자 입력
2. [state2] operator <- 연산자 입력
3. [state3] result <- 등호 입력

#### 하위 상태 머신

[state1] operand

언제 입력될지 모른다, 결과가 입력에 의존한다. -> 밀리 상태 머신

[state2] operator

1. state1 : reg_trm_mgn를 갱신한다.
2. state2 : reg_trm_sgn을 고려하여 reg_trm을 결정한다.
3. state3 : reg_rlt를 갱신한다.

[state3] result

-> 무어 상태 기계(현재 상태에 의해서만 출력이 결정된다.)

1. state1 : reg_trm_mgn를 갱신한다.
2. state2 : reg_trm_sgn을 고려하여 reg_trm을 결정한다.
3. state3 : 최종 reg_rlt를 계산한다.
4. state4 : reg_rlt_mgn과 reg_rlt_sgn을 계산한다.

## 1. Module and constant

```v
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

assign lcd_e = clk_100hz;

endmodule

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
```

## 2. Clock divider

```v
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
    else cnt_100hz <= cnt_100hz + 1;
end
```

## 3. Switch

```v
// push switch
reg [3:0] reg_num;
reg [7:0] reg_num_ascii;
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
reg [7:0] reg_opr_ascii;
always@(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin 
        reg_trm_sgn <= 0;
        reg_opr <= 0;
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
            reg_opr_ascii <= ascii_equ;
            led <= 8'b0000_0001; 
        end 
    end
end
```

## 4. One shot code

```v
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


// one shot code of operator, minus, equal, (, )
wire os_operator;
reg [1:0] reg_os_operator;
assign sw_operator = swd1 |swd2 | swd3 | swd4 | swd5 | swd6 | swd7 | swd8;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_os_operator <= 2'b00;
    else reg_os_operator <= {reg_os_operator[0], sw_operator};
end

assign os_operator = reg_os_operator[0] & ~reg_os_operator[1];
```

## 5. State machine

```v
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
```

## 6. Operand state

```v
// operand
reg [31:0] reg_trm_mgn; // 32 bit
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) reg_trm_mgn <= 0;
    else if (os_operand) reg_trm_mgn <= 10 * reg_trm_mgn + reg_num;
end
```

## 7. Operator state

```v
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
            1 : begin // Calculate the reg_trm
                    if (reg_trm_sgn) reg_trm <= ~reg_trm_mgn + 1;
                    else reg_trm <= reg_trm_mgn;
                end
            2 : begin // Insert reg_trm in queue
                    que_inf[rear_inf[3:0]+1] <= reg_trm; 
                    rear_inf <= rear_inf + 1;
                end
            3 : begin // Insert reg_opr in queue
                    que_inf[rear_inf[3:0]+1] <= reg_opr;
                    rear_inf <= rear_inf + 1;
                end
            4 : begin // Initialize the reg_trm
                    reg_trm_sgn <= 0;
                    reg_trm_mgn <= 0;
                end
        endcase
    end 
end
```

## 8. Result state

```v
// result
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
            1 : begin // Calculate the reg_trm
                    if (reg_trm_sgn) reg_trm <= ~reg_trm_mgn + 1;
                    else reg_trm <= reg_trm_mgn;
                end
            2 : begin // Insert reg_trm in queue
                    que_inf[rear_inf[3:0]+1] <= reg_trm; 
                    rear_inf <= rear_inf + 1;
                end
            3 : begin // Initialize the reg_trm
                    reg_trm_sgn <= 0;
                    reg_trm_mgn <= 0;
                end
            30 : begin // Sign-magnitude form for bcd code
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
```

## 9. Result state : infix -> postfix -> result

```v
// infix -> postfix
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        top_inf2pof <= 0;
        for (i = 0; i < MAX_STACK_SIZE; i = i + 1) stk_inf2pof[i] <= 0;
        front_pof <= 0;
        rear_pof <= 0;
        for (i = 0; i < MAX_QUEUE_SIZE; i = i + 1) que_pof[i] <= 0;
    end
    else if (cnt_result >= 4 && cnt_result < 20)
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
            else
            begin
                if (top_inf2pof == 0) // Stack for transforming infix to postfix is empty
                begin 
                    stk_inf2pof[top_inf2pof[3:0]+1] <= que_inf[front_inf[3:0]+1]; // Infix que -> infix to postfix stack
                    front_inf <= front_inf + 1;
                    top_inf2pof <= top_inf2pof + 1; 
                end
                else
                begin
                    if (stk_inf2pof[top_inf2pof[3:0]] + 1 >= que_inf[front_inf[3:0]+1]) // ??? ? ?? ????, ???? ????? ????? ??? ?? ??
                    begin
                        que_pof[rear_pof[3:0]+1] <= stk_inf2pof[top_inf2pof[3:0]];
                        top_inf2pof <= top_inf2pof - 1;
                        rear_pof <= rear_pof + 1;
                    end
                    else
                    begin
                        stk_inf2pof[top_inf2pof[3:0]+1] <= que_inf[front_inf[3:0]+1];
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

// postfix -> result
always @(posedge rst or posedge clk_100hz)
begin
    if (rst)
    begin
        reg_rlt <= 0;
        top_pof2rlt <= 0;
        for (i = 0; i < MAX_STACK_SIZE; i = i + 1) stk_pof2rlt[i] <= 0;
    end
    else if (cnt_result >= 20 && cnt_result < 30)
    begin
        if (front_pof != rear_pof) // not empty
        begin
            if (que_pof[front_pof[3:0]+1] > 4'b1010) // operand
            begin
                stk_pof2rlt[top_pof2rlt[3:0]+1] <= que_pof[front_pof[3:0]+1];
                front_pof <= front_pof + 1;
                top_pof2rlt <= top_pof2rlt + 1;
            end
            else // operator
            begin
                if (que_pof[front_pof[3:0]+1] == 4'b0101) // sum
                begin
                    front_pof <= front_pof + 1;
                    stk_pof2rlt[top_pof2rlt[3:0]-1] <= stk_pof2rlt[top_pof2rlt[3:0]-1] + stk_pof2rlt[top_pof2rlt[3:0]];
                    top_pof2rlt <= top_pof2rlt - 1;
                end
                else if (que_pof[front_pof[3:0]+1] == 4'b0110) // sub
                begin
                    front_pof <= front_pof + 1;
                    stk_pof2rlt[top_pof2rlt[3:0]-1] <= stk_pof2rlt[top_pof2rlt[3:0]-1] - stk_pof2rlt[top_pof2rlt[3:0]];
                    top_pof2rlt <= top_pof2rlt - 1;
                end
                else if (que_pof[front_pof[3:0]+1] == 4'b1001) // mul
                begin
                    front_pof <= front_pof + 1;
                    stk_pof2rlt[top_pof2rlt[3:0]-1] <= stk_pof2rlt[top_pof2rlt[3:0]-1] * stk_pof2rlt[top_pof2rlt[3:0]];
                    top_pof2rlt <= top_pof2rlt-1;
                end
                // else if (que_pof[front_pof[3:0]+1] == 4'b1010) // div
                // begin
                //     //
                // end
            end
        end
        else reg_rlt <= stk_pof2rlt[1]; // empty
    end
end
```

## 10. Result state : Binary to BCD

```v
// Binary 2 BCD
parameter start_bcd = 60;
reg [39:0] reg_rlt_bcd;
always @(posedge rst or posedge clk_100hz)
begin
   if (rst) reg_rlt_bcd <= 0;
   else if (cnt_result >= start_bcd && cnt_result < start_bcd + 32)
   begin
       reg_rlt_bcd <= {reg_rlt_bcd[38:0], reg_rlt_mgn[31+start_bcd-cnt_result]};
       reg_rlt_bcd[4:1] <= (reg_rlt_bcd[3:0]>=4'b0101) ? reg_rlt_bcd[3:0] + 3 : reg_rlt_bcd[3:0];
       reg_rlt_bcd[4:1] <= (reg_rlt_bcd[3:0]>=4'b0101) ? reg_rlt_bcd[3:0] + 3 : reg_rlt_bcd[3:0];
       reg_rlt_bcd[8:5] <= (reg_rlt_bcd[7:4]>=4'b0101) ? reg_rlt_bcd[7:4] + 3 : reg_rlt_bcd[7:4];
       reg_rlt_bcd[12:9] <= (reg_rlt_bcd[11:8]>=4'b0101) ? reg_rlt_bcd[11:8] + 3 : reg_rlt_bcd[11:8];
       reg_rlt_bcd[16:13] <= (reg_rlt_bcd[15:12]>=4'b0101) ? reg_rlt_bcd[15:12] + 3 : reg_rlt_bcd[15:12];
       reg_rlt_bcd[20:17] <= (reg_rlt_bcd[19:16]>=4'b0101) ? reg_rlt_bcd[19:16] + 3 : reg_rlt_bcd[19:16];
       reg_rlt_bcd[24:21] <= (reg_rlt_bcd[23:20]>=4'b0101) ? reg_rlt_bcd[23:20] + 3 : reg_rlt_bcd[23:20];
       reg_rlt_bcd[28:25] <= (reg_rlt_bcd[27:24]>=4'b0101) ? reg_rlt_bcd[27:24] + 3 : reg_rlt_bcd[27:24];
       reg_rlt_bcd[31:28] <= (reg_rlt_bcd[23:20]>=4'b0101) ? reg_rlt_bcd[31:28] + 3 : reg_rlt_bcd[31:28];
   end
end 
```

## 11. Result state : LCD

```v
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
```

## 12. Operand state and operand state : LCD

```v
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
```

## 13. Display

```v

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
```
