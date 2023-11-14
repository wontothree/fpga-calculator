module state_machine (
    input rst, clk,
    output cnt,
    output reg [2:0] state
);
integer cnt;

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

endmodule