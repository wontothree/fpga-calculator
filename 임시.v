뭐
for(i=0; i<=N; i++){
  for(j=0; j<=M; j++){
    //뭔가함
  }
}

이런 c코드가 있다면 베릴로그 식으로는

reg[31:0] i,j;
always @(posedge clk) begin
  if(rst) begin i<=0; j<=0; end

  else 
  begin
    //뭔가함
    if(j==M-1) j<=0 else j<=j+1

    if(j==M-1) if(i==N-1) i<=0; else i<=i+1
  end
end