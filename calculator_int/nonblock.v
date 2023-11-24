// Binary 2 BCD
reg [39:0] reg_rlt_bcd;
integer j;
always @(posedge rst or posedge clk_100hz)
begin
    if (rst) 
    begin 
        j <= 0;
        reg_rlt_bcd <= 0;
    end
    else if (swd8 && j >= 30 && j < 62)
    begin
        reg_rlt_bcd[3:0] <= {reg_rlt_bcd[2:0], reg_rlt_mgn[31+30-j]};
        reg_rlt_bcd[7:4] <= (reg_rlt_bcd[6:3] >= 4'b0101) ? reg_rlt_bcd[6:3] + 3 : reg_rlt_bcd[6:3];
        reg_rlt_bcd[11:8] <= (reg_rlt_bcd[10:7] >= 4'b0101) ? reg_rlt_bcd[10:7] + 3 : reg_rlt_bcd[10:7];
        reg_rlt_bcd[15:12] <= (reg_rlt_bcd[14:13] >= 4'b0101) ? reg_rlt_bcd[14:13] + 3 : reg_rlt_bcd[14:13];
        reg_rlt_bcd[19:16] <= (reg_rlt_bcd[18:15] >= 4'b0101) ? reg_rlt_bcd[18:15] + 3 : reg_rlt_bcd[18:15];
        reg_rlt_bcd[23:20] <= (reg_rlt_bcd[22:19] >= 4'b0101) ? reg_rlt_bcd[22:19] + 3 : reg_rlt_bcd[22:19];
        reg_rlt_bcd[27:24] <= (reg_rlt_bcd[26:23] >= 4'b0101) ? reg_rlt_bcd[26:23] + 3 : reg_rlt_bcd[26:23];
        reg_rlt_bcd[31:28] <= (reg_rlt_bcd[30:27] >= 4'b0101) ? reg_rlt_bcd[30:27] + 3 : reg_rlt_bcd[30:27];
        j = j + 1;

    end
    else if (swd8) j <= j + 1;
end