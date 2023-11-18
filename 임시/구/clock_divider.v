module clock_divider(
    input rst, clk,
    output reg clk_100hz
);
integer cnt_100hz;

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

endmodule